import 'dart:async';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> getRates(String currency) async {
    final code = currency.toLowerCase();
    final urls = [
      'https://latest.currency-api.pages.dev/v1/currencies/$code.json',
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$code.json',
    ];
    var message = 'Сервис курсов недоступен. Попробуйте ещё раз позже.';
    for (final url in urls) {
      try {
        final response = await _client
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return response.body;
        message = 'Сервис курсов недоступен. Попробуйте ещё раз позже.';
      } on TimeoutException {
        message = 'Сервер не ответил вовремя. Проверьте интернет и повторите попытку.';
      } on http.ClientException {
        message =
            'Не удалось загрузить курсы. Проверьте подключение к интернету.';
      }
    }
    throw ApiException(message);
  }

  void dispose() => _client.close();
}
