import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'conversion_record.dart';
import 'currency_rate.dart';
import 'currency_repository.dart';

class ConverterState extends ChangeNotifier {
  ConverterState({CurrencyRepository? repository})
    : _repository = repository ?? CurrencyRepository();

  static const currencyNames = {
    'RUB': 'Российский рубль',
    'USD': 'Доллар США',
    'EUR': 'Евро',
    'CNY': 'Китайский юань',
    'KZT': 'Казахстанский тенге',
    'TRY': 'Турецкая лира',
    'AED': 'Дирхам ОАЭ',
    'GBP': 'Британский фунт',
    'VND': 'Вьетнамский донг',
    'THB': 'Тайский бат',
    'LKR': 'Шри-ланкийская рупия',
  };

  static Iterable<String> get currencies => currencyNames.keys;

  final CurrencyRepository _repository;
  final List<ConversionRecord> _history = [];
  String _fromCurrency = 'EUR';
  String _toCurrency = 'RUB';
  String _amount = '';
  bool _isLoading = false;
  CurrencyRate? _rate;
  double? _result;
  String? _error;
  bool _disposed = false;

  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  bool get isLoading => _isLoading;
  CurrencyRate? get rate => _rate;
  double? get result => _result;
  String? get error => _error;
  List<ConversionRecord> get history => List.unmodifiable(_history);

  void setAmount(String value) {
    if (isLoading || value == _amount) return;
    _amount = value;
    _resetResult();
  }

  void setCurrency(String value, {required bool source}) {
    final selected = source ? _fromCurrency : _toCurrency;
    if (isLoading || value == selected || !currencyNames.containsKey(value)) {
      return;
    }
    if (source) {
      _fromCurrency = value;
    } else {
      _toCurrency = value;
    }
    _resetResult();
  }

  void swapCurrencies() {
    if (isLoading) return;
    final previous = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = previous;
    _resetResult();
  }

  void _resetResult() {
    _result = null;
    _rate = null;
    _error = null;
    notifyListeners();
  }

  double _parseAmount() {
    final text = _amount.trim();
    if (text.isEmpty) {
      throw const FormatException('Введите сумму для конвертации.');
    }
    if (!RegExp(r'^-?(?:\d+(?:[.,]\d*)?|[.,]\d+)$').hasMatch(text)) {
      throw const FormatException(
        'Введите корректное число, например 100 или 10,50.',
      );
    }
    final amount = double.tryParse(text.replaceAll(',', '.'));
    if (amount == null || !amount.isFinite) {
      throw const FormatException(
        'Сумма слишком большая. Введите меньшее число.',
      );
    }
    if (amount < 0) {
      throw const FormatException('Сумма не может быть отрицательной.');
    }
    return amount;
  }

  Future<void> convert() async {
    if (isLoading || _disposed) return;
    _result = null;
    _rate = null;
    _error = null;
    try {
      final amount = _parseAmount();
      _isLoading = true;
      notifyListeners();
      final rate = await _repository.getRate(_fromCurrency, _toCurrency);
      if (_disposed) return;
      final result = amount * rate.value;
      if (!result.isFinite) {
        throw const FormatException(
          'Результат слишком большой. Введите меньшую сумму.',
        );
      }
      _rate = rate;
      _result = result;
      _history.insert(
        0,
        ConversionRecord(
          amount: amount,
          result: result,
          fromCurrency: _fromCurrency,
          toCurrency: _toCurrency,
        ),
      );
      if (_history.length > 10) _history.removeLast();
    } on ApiException catch (error) {
      _error = error.message;
    } on FormatException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Не удалось выполнить конвертацию. Попробуйте ещё раз.';
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.dispose();
    super.dispose();
  }
}
