String formatMoney(
  int minorUnits, {
  required int decimalDigits,
  required String symbol,
}) {
  if (decimalDigits < 0) {
    throw ArgumentError('decimalDigits no puede ser negativo.');
  }

  final absolute = BigInt.from(minorUnits).abs();
  final divisor = BigInt.from(10).pow(decimalDigits);
  final integerPart = absolute ~/ divisor;
  final fractionalPart = (absolute % divisor).toString().padLeft(
    decimalDigits,
    '0',
  );

  final amount = decimalDigits == 0
      ? integerPart.toString()
      : '$integerPart.$fractionalPart';

  final signed = minorUnits < 0 && amount != '0' ? '-$amount' : amount;
  return '$symbol $signed';
}
