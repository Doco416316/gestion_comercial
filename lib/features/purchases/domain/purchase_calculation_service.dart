import 'package:decimal/decimal.dart';

enum PurchaseAdjustmentType { fixed, percentage }

/// Representa un descuento o impuesto introducido por el usuario.
///
/// Los importes fijos se expresan en unidades monetarias menores.
/// Los porcentajes se expresan como números porcentuales:
/// por ejemplo, 5 significa 5 %, no 0.05.
class PurchaseAdjustmentInput {
  final PurchaseAdjustmentType type;
  final int? fixedMinorUnits;
  final Decimal? percentage;

  const PurchaseAdjustmentInput.fixed(int amountMinorUnits)
    : type = PurchaseAdjustmentType.fixed,
      fixedMinorUnits = amountMinorUnits,
      percentage = null;

  const PurchaseAdjustmentInput.percentage(Decimal value)
    : type = PurchaseAdjustmentType.percentage,
      fixedMinorUnits = null,
      percentage = value;
}

/// Datos necesarios para calcular una línea de compra.
class PurchaseLineCalculationInput {
  final int quantityMilliUnits;
  final int unitCostMinorUnits;
  final PurchaseAdjustmentInput discount;
  final PurchaseAdjustmentInput tax;

  const PurchaseLineCalculationInput({
    required this.quantityMilliUnits,
    required this.unitCostMinorUnits,
    this.discount = const PurchaseAdjustmentInput.fixed(0),
    this.tax = const PurchaseAdjustmentInput.fixed(0),
  });
}

/// Resultado calculado de una línea de compra.
class PurchaseLineCalculationResult {
  final int grossAmountMinorUnits;
  final int discountMinorUnits;
  final int taxableBaseMinorUnits;
  final int taxMinorUnits;
  final int totalMinorUnits;

  final PurchaseAdjustmentType discountType;
  final Decimal? discountPercentage;

  final PurchaseAdjustmentType taxType;
  final Decimal? taxPercentage;

  const PurchaseLineCalculationResult({
    required this.grossAmountMinorUnits,
    required this.discountMinorUnits,
    required this.taxableBaseMinorUnits,
    required this.taxMinorUnits,
    required this.totalMinorUnits,
    required this.discountType,
    required this.discountPercentage,
    required this.taxType,
    required this.taxPercentage,
  });
}

/// Resultado consolidado de una compra.
class PurchaseCalculationResult {
  final int subtotalMinorUnits;
  final int discountMinorUnits;
  final int taxMinorUnits;
  final int totalMinorUnits;

  final List<PurchaseLineCalculationResult> lines;

  const PurchaseCalculationResult({
    required this.subtotalMinorUnits,
    required this.discountMinorUnits,
    required this.taxMinorUnits,
    required this.totalMinorUnits,
    required this.lines,
  });
}

/// Centraliza los cálculos financieros de las compras.
class PurchaseCalculationService {
  static final BigInt _maxSqliteInteger = BigInt.parse('9223372036854775807');

  static final BigInt _minSqliteInteger = BigInt.parse('-9223372036854775808');

  /// Calcula una línea individual.
  PurchaseLineCalculationResult calculateLine(
    PurchaseLineCalculationInput input,
  ) {
    if (input.quantityMilliUnits <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero.');
    }

    if (input.unitCostMinorUnits < 0) {
      throw ArgumentError('El costo unitario no puede ser negativo.');
    }

    // Cantidad en milésimas × costo en unidades monetarias menores.
    // Se desplaza tres posiciones para convertir la cantidad.
    final grossDecimal =
        Decimal.fromBigInt(BigInt.from(input.quantityMilliUnits)) *
        Decimal.fromBigInt(BigInt.from(input.unitCostMinorUnits));

    final grossAmount = _roundToSqliteInteger(grossDecimal.shift(-3));

    final discount = _calculateAdjustment(
      input.discount,
      grossAmount,
      isDiscount: true,
    );

    if (discount > grossAmount) {
      throw ArgumentError('El descuento no puede superar el importe bruto.');
    }

    final taxableBase = grossAmount - discount;

    final tax = _calculateAdjustment(input.tax, taxableBase, isDiscount: false);

    final total = _checkedAdd(taxableBase, tax);

    return PurchaseLineCalculationResult(
      grossAmountMinorUnits: grossAmount,
      discountMinorUnits: discount,
      taxableBaseMinorUnits: taxableBase,
      taxMinorUnits: tax,
      totalMinorUnits: total,
      discountType: input.discount.type,
      discountPercentage: input.discount.percentage,
      taxType: input.tax.type,
      taxPercentage: input.tax.percentage,
    );
  }

  /// Calcula el resumen de una compra a partir de sus líneas.
  PurchaseCalculationResult calculatePurchase(
    List<PurchaseLineCalculationInput> inputs,
  ) {
    if (inputs.isEmpty) {
      throw ArgumentError('La compra debe contener al menos un detalle.');
    }

    final lines = inputs.map(calculateLine).toList(growable: false);

    var subtotal = BigInt.zero;
    var discount = BigInt.zero;
    var tax = BigInt.zero;
    var total = BigInt.zero;

    for (final line in lines) {
      subtotal += BigInt.from(line.grossAmountMinorUnits);
      discount += BigInt.from(line.discountMinorUnits);
      tax += BigInt.from(line.taxMinorUnits);
      total += BigInt.from(line.totalMinorUnits);
    }

    return PurchaseCalculationResult(
      subtotalMinorUnits: _checkedInteger(subtotal),
      discountMinorUnits: _checkedInteger(discount),
      taxMinorUnits: _checkedInteger(tax),
      totalMinorUnits: _checkedInteger(total),
      lines: lines,
    );
  }

  int _calculateAdjustment(
    PurchaseAdjustmentInput adjustment,
    int baseMinorUnits, {
    required bool isDiscount,
  }) {
    switch (adjustment.type) {
      case PurchaseAdjustmentType.fixed:
        final amount = adjustment.fixedMinorUnits;

        if (amount == null || amount < 0) {
          throw ArgumentError(
            'El importe fijo debe ser mayor o igual que cero.',
          );
        }

        return amount;

      case PurchaseAdjustmentType.percentage:
        final percentage = adjustment.percentage;

        if (percentage == null || percentage < Decimal.zero) {
          throw ArgumentError('El porcentaje debe ser mayor o igual que cero.');
        }

        if (isDiscount && percentage > Decimal.fromInt(100)) {
          throw ArgumentError(
            'El descuento porcentual no puede superar el 100 %.',
          );
        }

        final amount = Decimal.fromInt(baseMinorUnits) * percentage.shift(-2);

        return _roundToSqliteInteger(amount);
    }
  }

  /// Redondea importes positivos al entero más cercano.
  ///
  /// En los empates utiliza HALF_UP.
  int _roundToSqliteInteger(Decimal value) {
    if (value < Decimal.zero) {
      throw ArgumentError('No se permiten importes negativos.');
    }

    final rounded = value.round().toBigInt();

    return _checkedInteger(rounded);
  }

  /// Comprueba que el resultado cabe en un INTEGER de SQLite.
  int _checkedInteger(BigInt value) {
    if (value < _minSqliteInteger || value > _maxSqliteInteger) {
      throw RangeError(
        'El importe supera el límite de almacenamiento de SQLite.',
      );
    }

    return value.toInt();
  }

  int _checkedAdd(int first, int second) {
    return _checkedInteger(BigInt.from(first) + BigInt.from(second));
  }
}
