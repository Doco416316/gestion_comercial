enum SalePaymentType { cash, credit }

enum SalePaymentStatus { unpaid, partial, paid }

/// Datos de pago inicial al registrar una venta.
class SalePaymentInput {
  const SalePaymentInput({
    required this.paymentType,
    required this.totalMinorUnits,
    required this.initialPaymentMinorUnits,
    this.customerId,
  });

  final SalePaymentType paymentType;
  final int totalMinorUnits;
  final int initialPaymentMinorUnits;
  final String? customerId;
}

/// Resumen de los importes pagados y pendientes de una venta.
class SalePaymentSummary {
  const SalePaymentSummary({
    required this.totalMinorUnits,
    required this.paidMinorUnits,
    required this.balanceMinorUnits,
    required this.status,
  });

  final int totalMinorUnits;
  final int paidMinorUnits;
  final int balanceMinorUnits;
  final SalePaymentStatus status;
}

/// Centraliza las reglas de pago de las ventas.
///
/// Los importes se expresan en unidades monetarias menores para evitar
/// errores de precisión con valores decimales.
class SalePaymentService {
  static final BigInt _maxSqliteInteger = BigInt.parse('9223372036854775807');

  /// Valida las condiciones de pago inicial y devuelve el saldo resultante.
  SalePaymentSummary calculateInitialPayment(SalePaymentInput input) {
    if (input.totalMinorUnits <= 0) {
      throw ArgumentError('El total de la venta debe ser mayor que cero.');
    }

    if (input.initialPaymentMinorUnits < 0) {
      throw ArgumentError('El pago inicial no puede ser negativo.');
    }

    if (input.initialPaymentMinorUnits > input.totalMinorUnits) {
      throw ArgumentError('El pago inicial no puede superar el total.');
    }

    switch (input.paymentType) {
      case SalePaymentType.cash:
        if (input.initialPaymentMinorUnits != input.totalMinorUnits) {
          throw ArgumentError(
            'Una venta de contado debe quedar pagada en su totalidad.',
          );
        }
      case SalePaymentType.credit:
        final customerId = input.customerId?.trim();
        if (customerId == null || customerId.isEmpty) {
          throw ArgumentError(
            'Las ventas a crédito requieren un cliente registrado.',
          );
        }
    }

    return summarize(
      totalMinorUnits: input.totalMinorUnits,
      paidMinorUnits: input.initialPaymentMinorUnits,
    );
  }

  /// Calcula el estado de pago a partir del total y los pagos acumulados.
  SalePaymentSummary summarize({
    required int totalMinorUnits,
    required int paidMinorUnits,
  }) {
    if (totalMinorUnits <= 0) {
      throw ArgumentError('El total de la venta debe ser mayor que cero.');
    }

    if (paidMinorUnits < 0 || paidMinorUnits > totalMinorUnits) {
      throw ArgumentError('El importe pagado no es válido.');
    }

    final balance = totalMinorUnits - paidMinorUnits;
    final status = switch (balance) {
      0 => SalePaymentStatus.paid,
      _ when paidMinorUnits == 0 => SalePaymentStatus.unpaid,
      _ => SalePaymentStatus.partial,
    };

    return SalePaymentSummary(
      totalMinorUnits: totalMinorUnits,
      paidMinorUnits: paidMinorUnits,
      balanceMinorUnits: balance,
      status: status,
    );
  }

  /// Valida un abono posterior y devuelve el nuevo resumen de la deuda.
  SalePaymentSummary registerPayment({
    required int totalMinorUnits,
    required int paidMinorUnits,
    required int paymentMinorUnits,
  }) {
    if (paymentMinorUnits <= 0) {
      throw ArgumentError('El abono debe ser mayor que cero.');
    }

    final newPaid =
        BigInt.from(paidMinorUnits) + BigInt.from(paymentMinorUnits);

    if (newPaid > BigInt.from(totalMinorUnits)) {
      throw ArgumentError('El abono supera el saldo pendiente.');
    }

    if (newPaid > _maxSqliteInteger) {
      throw RangeError('El importe supera el límite de almacenamiento.');
    }

    return summarize(
      totalMinorUnits: totalMinorUnits,
      paidMinorUnits: newPaid.toInt(),
    );
  }
}
