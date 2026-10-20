class ConversionRecord {
  const ConversionRecord({
    required this.amount,
    required this.result,
    required this.fromCurrency,
    required this.toCurrency,
  });

  final double amount;
  final double result;
  final String fromCurrency;
  final String toCurrency;
}

String formatAmount(double value) {
  if (value.abs() >= 1e21) {
    return value.toStringAsExponential(2).replaceAll('.', ',');
  }
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
  return '$whole,${parts.last}';
}
