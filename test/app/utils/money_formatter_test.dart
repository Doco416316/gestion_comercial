import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/utils/money_formatter.dart';

void main() {
  test('formatea importe con dos decimales', () {
    expect(formatMoney(1234, decimalDigits: 2, symbol: 'USD'), 'USD 12.34');
  });

  test('formatea importe negativo', () {
    expect(formatMoney(-1234, decimalDigits: 2, symbol: 'USD'), 'USD -12.34');
  });

  test('formatea importe con cero decimales', () {
    expect(formatMoney(1234, decimalDigits: 0, symbol: 'CUP'), 'CUP 1234');
  });

  test('formatea importe con tres decimales', () {
    expect(formatMoney(12345, decimalDigits: 3, symbol: 'EUR'), 'EUR 12.345');
  });

  test('formatea cero', () {
    expect(formatMoney(0, decimalDigits: 2, symbol: 'USD'), 'USD 0.00');
  });

  test('rechaza decimalDigits negativo', () {
    expect(
      () => formatMoney(100, decimalDigits: -1, symbol: 'USD'),
      throwsArgumentError,
    );
  });
}
