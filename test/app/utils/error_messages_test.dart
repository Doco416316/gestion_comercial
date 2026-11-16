import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/utils/error_messages.dart';

void main() {
  test('devuelve el mensaje de ArgumentError', () {
    final error = ArgumentError('Dato inválido de prueba.');
    expect(readableErrorMessage(error), 'Dato inválido de prueba.');
  });

  test('devuelve el mensaje de StateError', () {
    final error = StateError('Estado inválido de prueba.');
    expect(readableErrorMessage(error), 'Estado inválido de prueba.');
  });

  test('devuelve mensaje para FormatException', () {
    expect(
      readableErrorMessage(const FormatException('bad')),
      'Formato inválido.',
    );
  });

  test('elimina el prefijo Exception', () {
    expect(
      readableErrorMessage(Exception('Error de prueba.')),
      'Error de prueba.',
    );
  });

  test('devuelve toString si no hay prefijo', () {
    expect(readableErrorMessage('error simple'), 'error simple');
  });
}
