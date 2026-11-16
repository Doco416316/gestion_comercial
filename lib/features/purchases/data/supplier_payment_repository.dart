import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../settings/data/exchange_rate_repository.dart';

/// Registra y consulta pagos realizados a proveedores.
///
/// Los pagos son registros financieros inmutables.
/// El importe entregado se conserva en su moneda original y el importe
/// aplicado se almacena en la moneda de la compra.
class SupplierPaymentRepository {
  SupplierPaymentRepository(
    this._database, {
    ExchangeRateRepository? exchangeRateRepository,
  }) : _exchangeRateRepository =
           exchangeRateRepository ?? ExchangeRateRepository(_database);

  final AppDatabase _database;
  final ExchangeRateRepository _exchangeRateRepository;

  static final BigInt _maxSqliteInteger = BigInt.parse('9223372036854775807');

  /// Registra un pago y calcula cuánto se aplica a la deuda de la compra.
  ///
  /// Si ambas monedas son iguales, el importe aplicado coincide exactamente
  /// con el importe entregado. Si son diferentes, convierte utilizando:
  ///
  /// importeAplicado =
  /// importeEntregado × tasaPago / tasaCompra
  ///
  /// El resultado se ajusta por los decimales de ambas monedas y se redondea
  /// con HALF_UP.
  Future<String> registerPayment({
    required String purchaseId,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime paymentDate,
    required String paymentMethod,
    String? reference,
    String? notes,
  }) async {
    final normalizedPurchaseId = _normalizeRequired(
      purchaseId,
      'El identificador de la compra es obligatorio.',
    );

    final normalizedCurrencyCode = _normalizeCurrencyCode(currencyCode);

    final normalizedPaymentMethod = _normalizeRequired(
      paymentMethod,
      'El método de pago es obligatorio.',
    );

    if (normalizedPaymentMethod.length > 40) {
      throw ArgumentError(
        'El método de pago no puede superar los 40 caracteres.',
      );
    }

    if (amountMinorUnits <= 0) {
      throw ArgumentError('El importe del pago debe ser mayor que cero.');
    }

    _checkedInteger(BigInt.from(amountMinorUnits));

    final normalizedReference = _normalizeOptional(reference);
    final normalizedNotes = _normalizeOptional(notes);

    return _database.transaction(() async {
      final purchase =
          await (_database.select(_database.purchases)
                ..where((table) => table.id.equals(normalizedPurchaseId)))
              .getSingleOrNull();

      if (purchase == null) {
        throw StateError('La compra indicada no existe.');
      }

      if (purchase.status != 'confirmed') {
        throw StateError(
          'Solo se pueden registrar pagos en compras confirmadas.',
        );
      }

      final paymentCurrency =
          await (_database.select(_database.currencies)
                ..where((table) => table.code.equals(normalizedCurrencyCode)))
              .getSingleOrNull();

      if (paymentCurrency == null) {
        throw StateError('La moneda del pago no está registrada.');
      }

      if (!paymentCurrency.isActive) {
        throw StateError('La moneda del pago está inactiva.');
      }

      final purchaseCurrencyCode = _normalizeCurrencyCode(
        purchase.currencyCode,
      );

      final purchaseCurrency =
          await (_database.select(_database.currencies)
                ..where((table) => table.code.equals(purchaseCurrencyCode)))
              .getSingleOrNull();

      if (purchaseCurrency == null) {
        throw StateError('La moneda de la compra no está registrada.');
      }

      if (purchaseCurrency.decimalDigits < 0 ||
          paymentCurrency.decimalDigits < 0) {
        throw StateError('La configuración decimal de la moneda no es válida.');
      }

      final purchaseRate = _parsePositiveRate(
        purchase.exchangeRateToBaseSnapshot,
        'La compra no tiene una tasa de cambio histórica válida.',
      );

      final paymentRate = await _exchangeRateRepository.getRateToBaseForDate(
        currencyCode: normalizedCurrencyCode,
        date: paymentDate,
      );

      if (paymentRate == null || paymentRate <= Decimal.zero) {
        throw StateError(
          'No existe una tasa de cambio válida para la moneda '
          'del pago en la fecha indicada.',
        );
      }

      final appliedAmountMinorUnits = _calculateAppliedAmount(
        amountMinorUnits: amountMinorUnits,
        paymentCurrencyCode: normalizedCurrencyCode,
        purchaseCurrencyCode: purchaseCurrencyCode,
        paymentRate: paymentRate,
        purchaseRate: purchaseRate,
        paymentDecimalDigits: paymentCurrency.decimalDigits,
        purchaseDecimalDigits: purchaseCurrency.decimalDigits,
      );

      if (appliedAmountMinorUnits <= 0) {
        throw StateError(
          'El importe convertido es demasiado pequeño para aplicarse.',
        );
      }

      final paidAmount = await _sumAppliedPayments(normalizedPurchaseId);
      final totalAmount = BigInt.from(purchase.totalMinorUnits);
      final outstandingBalance = totalAmount - paidAmount;

      if (outstandingBalance <= BigInt.zero) {
        throw StateError('La compra no tiene saldo pendiente.');
      }

      if (BigInt.from(appliedAmountMinorUnits) > outstandingBalance) {
        throw StateError(
          'El pago supera el saldo pendiente de la compra. '
          'Saldo disponible: ${outstandingBalance.toString()}.',
        );
      }

      final paymentId = const Uuid().v4();

      await _database
          .into(_database.supplierPayments)
          .insert(
            SupplierPaymentsCompanion.insert(
              id: paymentId,
              purchaseId: normalizedPurchaseId,
              amountMinorUnits: amountMinorUnits,
              currencyCode: normalizedCurrencyCode,
              exchangeRateToBaseSnapshot: paymentRate.toString(),
              appliedAmountMinorUnits: appliedAmountMinorUnits,
              paymentDate: paymentDate,
              paymentMethod: normalizedPaymentMethod,
              reference: Value(normalizedReference),
              notes: Value(normalizedNotes),
            ),
          );

      return paymentId;
    });
  }

  /// Observa los pagos de una compra, ordenados cronológicamente.
  Stream<List<SupplierPayment>> watchByPurchase(String purchaseId) {
    final normalizedPurchaseId = _normalizeRequired(
      purchaseId,
      'El identificador de la compra es obligatorio.',
    );

    final query = _database.select(_database.supplierPayments)
      ..where((table) => table.purchaseId.equals(normalizedPurchaseId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.paymentDate),
        (table) => OrderingTerm.asc(table.createdAt),
      ]);

    return query.watch();
  }

  /// Obtiene los pagos de una compra, ordenados cronológicamente.
  Future<List<SupplierPayment>> getByPurchase(String purchaseId) {
    final normalizedPurchaseId = _normalizeRequired(
      purchaseId,
      'El identificador de la compra es obligatorio.',
    );

    final query = _database.select(_database.supplierPayments)
      ..where((table) => table.purchaseId.equals(normalizedPurchaseId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.paymentDate),
        (table) => OrderingTerm.asc(table.createdAt),
      ]);

    return query.get();
  }

  /// Devuelve el total aplicado a la deuda, expresado en la moneda
  /// de la compra, no la suma de los importes entregados en sus monedas.
  Future<int> getPaidAmount(String purchaseId) async {
    final normalizedPurchaseId = _normalizeRequired(
      purchaseId,
      'El identificador de la compra es obligatorio.',
    );

    final paidAmount = await _sumAppliedPayments(normalizedPurchaseId);
    return _checkedInteger(paidAmount);
  }

  /// Devuelve el saldo pendiente en la moneda de la compra.
  Future<int> getOutstandingBalance(String purchaseId) async {
    final normalizedPurchaseId = _normalizeRequired(
      purchaseId,
      'El identificador de la compra es obligatorio.',
    );

    final purchase =
        await (_database.select(_database.purchases)
              ..where((table) => table.id.equals(normalizedPurchaseId)))
            .getSingleOrNull();

    if (purchase == null) {
      throw StateError('La compra indicada no existe.');
    }

    final totalAmount = BigInt.from(purchase.totalMinorUnits);
    final paidAmount = await _sumAppliedPayments(normalizedPurchaseId);
    final outstandingBalance = totalAmount - paidAmount;

    if (outstandingBalance < BigInt.zero) {
      throw StateError(
        'La suma de los pagos supera el total registrado de la compra.',
      );
    }

    return _checkedInteger(outstandingBalance);
  }

  Future<BigInt> _sumAppliedPayments(String purchaseId) async {
    final payments = await (_database.select(
      _database.supplierPayments,
    )..where((table) => table.purchaseId.equals(purchaseId))).get();

    var total = BigInt.zero;

    for (final payment in payments) {
      total += BigInt.from(payment.appliedAmountMinorUnits);

      if (total > _maxSqliteInteger) {
        throw RangeError(
          'La suma de los pagos supera el límite de almacenamiento de SQLite.',
        );
      }
    }

    return total;
  }

  int _calculateAppliedAmount({
    required int amountMinorUnits,
    required String paymentCurrencyCode,
    required String purchaseCurrencyCode,
    required Decimal paymentRate,
    required Decimal purchaseRate,
    required int paymentDecimalDigits,
    required int purchaseDecimalDigits,
  }) {
    // Una deuda y un pago expresados en la misma moneda se compensan
    // directamente, sin alterar el importe por cambios posteriores de tasa.
    if (paymentCurrencyCode == purchaseCurrencyCode) {
      return amountMinorUnits;
    }

    // Ajustamos la tasa de pago a las unidades menores de la moneda
    // de compra antes de dividir. La división devuelve un Rational,
    // cuyo round() aplica HALF_UP sin perder precisión.
    final adjustedPaymentRate = paymentRate.shift(
      purchaseDecimalDigits - paymentDecimalDigits,
    );

    final convertedAmount =
        Decimal.fromInt(amountMinorUnits) * adjustedPaymentRate / purchaseRate;

    if (convertedAmount.numerator < BigInt.zero) {
      throw StateError('El importe convertido no puede ser negativo.');
    }

    return _checkedInteger(convertedAmount.round());
  }

  Decimal _parsePositiveRate(String value, String errorMessage) {
    try {
      final rate = Decimal.parse(value);

      if (rate <= Decimal.zero) {
        throw StateError(errorMessage);
      }

      return rate;
    } on FormatException {
      throw StateError(errorMessage);
    }
  }

  int _checkedInteger(BigInt value) {
    if (value < BigInt.zero || value > _maxSqliteInteger) {
      throw RangeError(
        'El importe supera el límite de almacenamiento de SQLite.',
      );
    }

    return value.toInt();
  }

  String _normalizeCurrencyCode(String value) {
    final normalized = value.trim().toUpperCase();

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) {
      throw ArgumentError('El código de moneda no es válido.');
    }

    return normalized;
  }

  String _normalizeRequired(String value, String errorMessage) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError(errorMessage);
    }

    return normalized;
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
