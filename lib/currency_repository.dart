import 'dart:convert';

import 'api_client.dart';
import 'currency_rate.dart';

class CurrencyRepository {
  CurrencyRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CurrencyRate> getRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) {
      return CurrencyRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        value: 1,
      );
    }
    final body = await _apiClient.getRates(fromCurrency);
    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw const FormatException('Сервис вернул некорректный JSON.');
    }
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Сервис вернул некорректные данные о курсе.');
    }
    return CurrencyRate.fromJson(json, fromCurrency, toCurrency);
  }

  void dispose() => _apiClient.dispose();
}
