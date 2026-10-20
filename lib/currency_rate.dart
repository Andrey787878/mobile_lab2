class CurrencyRate {
  const CurrencyRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.value,
    this.date,
  });

  final String fromCurrency;
  final String toCurrency;
  final double value;
  final DateTime? date;

  factory CurrencyRate.fromJson(
    Map<String, dynamic> json,
    String fromCurrency,
    String toCurrency,
  ) {
    final dateText = json['date'];
    final date = dateText is String ? DateTime.tryParse(dateText) : null;
    final rates = json[fromCurrency.toLowerCase()];
    if (rates is! Map<String, dynamic>) {
      throw const FormatException('Сервис вернул некорректные данные о курсе.');
    }
    if (date == null || date.toIso8601String().substring(0, 10) != dateText) {
      throw const FormatException('Сервис вернул некорректную дату курса.');
    }
    final rate = rates[toCurrency.toLowerCase()];
    if (rate == null) {
      throw FormatException('В ответе сервиса нет курса для $toCurrency.');
    }
    if (rate is! num || !rate.isFinite || rate <= 0) {
      throw const FormatException('Сервис вернул некорректное значение курса.');
    }
    return CurrencyRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      value: rate.toDouble(),
      date: date,
    );
  }
}
