import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../purchases/domain/purchase_calculation_service.dart';
import '../../settings/data/exchange_rate_repository.dart';
import '../domain/sale_payment_service.dart';

import '../../inventory/data/inventory_repository.dart';

/// Persistencia y reglas transaccionales del ciclo de vida de las ventas.
class SalesRepository {
  SalesRepository(
    this._db, {
    PurchaseCalculationService? calculationService,
    SalePaymentService? paymentService,
    ExchangeRateRepository? exchangeRateRepository,
  }) : _calculations = calculationService ?? PurchaseCalculationService(),
       _payments = paymentService ?? SalePaymentService(),
       _rates = exchangeRateRepository ?? ExchangeRateRepository(_db);

  final AppDatabase _db;
  final PurchaseCalculationService _calculations;
  final SalePaymentService _payments;
  final ExchangeRateRepository _rates;
  static const Uuid _uuid = Uuid();
  static final BigInt _maxInt = BigInt.parse('9223372036854775807');

  // Consultas
  Stream<List<Sale>> watchAll() =>
      (_db.select(_db.sales)..orderBy([
            (r) => OrderingTerm.desc(r.saleDate),
            (r) => OrderingTerm.desc(r.createdAt),
          ]))
          .watch();

  Stream<List<Sale>> watchByStatus(String status) {
    if (!{'draft', 'confirmed', 'cancelled'}.contains(status)) {
      throw ArgumentError('Estado de venta no válido: $status.');
    }
    return (_db.select(_db.sales)
          ..where((r) => r.status.equals(status))
          ..orderBy([(r) => OrderingTerm.desc(r.saleDate)]))
        .watch();
  }

  Future<Sale?> findById(String id) =>
      (_db.select(_db.sales)..where((r) => r.id.equals(id))).getSingleOrNull();
  Stream<List<SaleDetail>> watchDetails(String id) =>
      (_db.select(_db.saleDetails)..where((r) => r.saleId.equals(id))).watch();
  Future<List<SaleDetail>> getDetails(String id) =>
      (_db.select(_db.saleDetails)..where((r) => r.saleId.equals(id))).get();
  Stream<List<SalePayment>> watchPayments(String id) =>
      (_db.select(_db.salePayments)
            ..where((r) => r.saleId.equals(id))
            ..orderBy([
              (r) => OrderingTerm.asc(r.paymentDate),
              (r) => OrderingTerm.asc(r.createdAt),
            ]))
          .watch();
  Future<List<SalePayment>> getPayments(String id) =>
      (_db.select(_db.salePayments)
            ..where((r) => r.saleId.equals(id))
            ..orderBy([
              (r) => OrderingTerm.asc(r.paymentDate),
              (r) => OrderingTerm.asc(r.createdAt),
            ]))
          .get();

  // Borradores
  Future<String> createDraft({
    String? customerId,
    required DateTime saleDate,
    required String currencyCode,
    required SalePaymentType paymentType,
    String? documentNumber,
    String? notes,
  }) async {
    final code = _currencyCode(currencyCode);
    if (paymentType == SalePaymentType.credit &&
        (customerId == null || customerId.trim().isEmpty)) {
      throw ArgumentError(
        'Las ventas a crédito requieren un cliente registrado.',
      );
    }
    return _db.transaction(() async {
      if (customerId != null) {
        await _activeCustomer(customerId);
      }
      final currency = await _activeCurrency(code);
      final rate = await _rateForDate(code, saleDate, currency.isBase);
      final id = _uuid.v4();
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              id: id,
              customerId: Value(customerId),
              documentNumber: Value(_optional(documentNumber)),
              saleDate: saleDate,
              currencyCode: code,
              exchangeRateToBaseSnapshot: rate.toString(),
              subtotalMinorUnits: 0,
              discountMinorUnits: const Value(0),
              taxMinorUnits: const Value(0),
              totalMinorUnits: 0,
              paymentType: paymentType.name,
              notes: Value(_optional(notes)),
            ),
          );
      return id;
    });
  }

  Future<void> updateDraftHeader({
    required String saleId,
    String? customerId,
    required DateTime saleDate,
    required String currencyCode,
    required SalePaymentType paymentType,
    String? documentNumber,
    String? notes,
  }) async {
    final code = _currencyCode(currencyCode);
    if (paymentType == SalePaymentType.credit &&
        (customerId == null || customerId.trim().isEmpty)) {
      throw ArgumentError(
        'Las ventas a crédito requieren un cliente registrado.',
      );
    }
    await _db.transaction(() async {
      final sale = await _draft(saleId);
      if (sale.paymentType != paymentType.name) {
        throw StateError('No se puede cambiar el tipo de pago del borrador.');
      }
      if (customerId != null) {
        await _activeCustomer(customerId);
      }
      if (sale.currencyCode != code && (await getDetails(saleId)).isNotEmpty) {
        throw StateError(
          'Elimina los detalles antes de cambiar la moneda de la venta.',
        );
      }
      final currency = await _activeCurrency(code);
      final rate = await _rateForDate(code, saleDate, currency.isBase);
      await (_db.update(_db.sales)..where((r) => r.id.equals(saleId))).write(
        SalesCompanion(
          customerId: Value(customerId),
          saleDate: Value(saleDate),
          currencyCode: Value(code),
          exchangeRateToBaseSnapshot: Value(rate.toString()),
          documentNumber: Value(_optional(documentNumber)),
          notes: Value(_optional(notes)),
        ),
      );
    });
  }

  // Líneas y recálculo
  Future<String> addDetail({
    required String saleId,
    required String productId,
    required int quantityMilliUnits,
    required int unitPriceMinorUnits,
    PurchaseAdjustmentInput discount = const PurchaseAdjustmentInput.fixed(0),
    PurchaseAdjustmentInput tax = const PurchaseAdjustmentInput.fixed(0),
  }) async => _db.transaction(() async {
    await _draft(saleId);
    final product = await _activeProduct(productId);
    final line = _calculations.calculateLine(
      PurchaseLineCalculationInput(
        quantityMilliUnits: quantityMilliUnits,
        unitCostMinorUnits: unitPriceMinorUnits,
        discount: discount,
        tax: tax,
      ),
    );
    final id = _uuid.v4();
    await _db
        .into(_db.saleDetails)
        .insert(
          SaleDetailsCompanion.insert(
            id: id,
            saleId: saleId,
            productId: productId,
            skuSnapshot: product.sku,
            productNameSnapshot: product.name,
            unitSnapshot: product.unit,
            quantityMilliUnits: quantityMilliUnits,
            unitPriceMinorUnits: unitPriceMinorUnits,
            discountMinorUnits: Value(line.discountMinorUnits),
            discountType: Value(discount.type.name),
            discountRate: Value(_percentage(discount)),
            taxMinorUnits: Value(line.taxMinorUnits),
            taxType: Value(tax.type.name),
            taxRate: Value(_percentage(tax)),
            totalMinorUnits: line.totalMinorUnits,
          ),
        );
    await _recalculate(saleId);
    return id;
  });

  Future<void> updateDetail({
    required String saleId,
    required String detailId,
    required String productId,
    required int quantityMilliUnits,
    required int unitPriceMinorUnits,
    PurchaseAdjustmentInput discount = const PurchaseAdjustmentInput.fixed(0),
    PurchaseAdjustmentInput tax = const PurchaseAdjustmentInput.fixed(0),
  }) async => _db.transaction(() async {
    await _draft(saleId);
    final old = await (_db.select(
      _db.saleDetails,
    )..where((r) => r.id.equals(detailId))).getSingleOrNull();
    if (old == null || old.saleId != saleId) {
      throw StateError('El detalle no pertenece a esta venta.');
    }
    final product = await _activeProduct(productId);
    final line = _calculations.calculateLine(
      PurchaseLineCalculationInput(
        quantityMilliUnits: quantityMilliUnits,
        unitCostMinorUnits: unitPriceMinorUnits,
        discount: discount,
        tax: tax,
      ),
    );
    await (_db.update(
      _db.saleDetails,
    )..where((r) => r.id.equals(detailId))).write(
      SaleDetailsCompanion(
        productId: Value(productId),
        skuSnapshot: Value(product.sku),
        productNameSnapshot: Value(product.name),
        unitSnapshot: Value(product.unit),
        quantityMilliUnits: Value(quantityMilliUnits),
        unitPriceMinorUnits: Value(unitPriceMinorUnits),
        discountMinorUnits: Value(line.discountMinorUnits),
        discountType: Value(discount.type.name),
        discountRate: Value(_percentage(discount)),
        taxMinorUnits: Value(line.taxMinorUnits),
        taxType: Value(tax.type.name),
        taxRate: Value(_percentage(tax)),
        totalMinorUnits: Value(line.totalMinorUnits),
      ),
    );
    await _recalculate(saleId);
  });

  Future<void> removeDetail({
    required String saleId,
    required String detailId,
  }) async => _db.transaction(() async {
    await _draft(saleId);
    final detail = await (_db.select(
      _db.saleDetails,
    )..where((r) => r.id.equals(detailId))).getSingleOrNull();
    if (detail == null || detail.saleId != saleId) {
      throw StateError('El detalle no pertenece a esta venta.');
    }
    await (_db.delete(
      _db.saleDetails,
    )..where((r) => r.id.equals(detailId))).go();
    await _recalculate(saleId);
  });

  Future<void> deleteDraft(String saleId) async => _db.transaction(() async {
    await _draft(saleId);
    await (_db.delete(
      _db.saleDetails,
    )..where((r) => r.saleId.equals(saleId))).go();
    await (_db.delete(_db.sales)..where((r) => r.id.equals(saleId))).go();
  });

  Future<PurchaseCalculationResult?> recalculateDraft(String saleId) =>
      _db.transaction(() async {
        await _draft(saleId);
        return _recalculate(saleId);
      });

  Future<PurchaseCalculationResult?> _recalculate(String saleId) async {
    final details = await getDetails(saleId);
    if (details.isEmpty) {
      await (_db.update(_db.sales)..where((r) => r.id.equals(saleId))).write(
        const SalesCompanion(
          subtotalMinorUnits: Value(0),
          discountMinorUnits: Value(0),
          taxMinorUnits: Value(0),
          totalMinorUnits: Value(0),
        ),
      );
      return null;
    }
    final result = _calculations.calculatePurchase(
      details.map(_lineInput).toList(),
    );
    for (var i = 0; i < details.length; i++) {
      await (_db.update(
        _db.saleDetails,
      )..where((r) => r.id.equals(details[i].id))).write(
        SaleDetailsCompanion(
          discountMinorUnits: Value(result.lines[i].discountMinorUnits),
          taxMinorUnits: Value(result.lines[i].taxMinorUnits),
          totalMinorUnits: Value(result.lines[i].totalMinorUnits),
        ),
      );
    }
    await (_db.update(_db.sales)..where((r) => r.id.equals(saleId))).write(
      SalesCompanion(
        subtotalMinorUnits: Value(result.subtotalMinorUnits),
        discountMinorUnits: Value(result.discountMinorUnits),
        taxMinorUnits: Value(result.taxMinorUnits),
        totalMinorUnits: Value(result.totalMinorUnits),
      ),
    );
    return result;
  }

  // Confirmación y pagos
  Future<void> confirmSale({
    required String saleId,
    int initialPaymentMinorUnits = 0,
    String initialPaymentMethod = 'cash',
    DateTime? paymentDate,
    String? paymentReference,
    String? paymentNotes,
  }) async => _db.transaction(() async {
    final sale = await _draft(saleId);
    if (sale.customerId != null) {
      await _activeCustomer(sale.customerId!);
    }
    final currency = await _activeCurrency(sale.currencyCode);
    final details = await getDetails(saleId);
    if (details.isEmpty) {
      throw StateError('No se puede confirmar una venta sin detalles.');
    }
    final totals = await _recalculate(saleId);
    if (totals == null || totals.totalMinorUnits <= 0) {
      throw StateError('El total de la venta debe ser mayor que cero.');
    }
    final payment = _payments.calculateInitialPayment(
      SalePaymentInput(
        paymentType: _paymentType(sale.paymentType),
        totalMinorUnits: totals.totalMinorUnits,
        initialPaymentMinorUnits: initialPaymentMinorUnits,
        customerId: sale.customerId,
      ),
    );
    final rate = await _rateForDate(
      sale.currencyCode,
      sale.saleDate,
      currency.isBase,
    );

    // Cada movimiento de salida actualiza el saldo mediante los triggers de inventario.
    // Si cualquier línea no tiene existencias, la transacción revierte toda la venta.
    for (final detail in details) {
      final product = await _activeProduct(detail.productId);
      if (!product.trackInventory) {
        continue;
      }
      final movementId = _uuid.v4();
      await _db
          .into(_db.inventoryMovements)
          .insert(
            InventoryMovementsCompanion.insert(
              id: movementId,
              productId: detail.productId,
              movementType: 'exit',
              quantityMilliUnits: detail.quantityMilliUnits,
              reason: 'Venta confirmada',
              reference: Value('sale:$saleId;detail:${detail.id}'),
            ),
          );
      await (_db.update(_db.saleDetails)..where((r) => r.id.equals(detail.id)))
          .write(SaleDetailsCompanion(inventoryMovementId: Value(movementId)));
    }
    await (_db.update(_db.sales)..where((r) => r.id.equals(saleId))).write(
      SalesCompanion(
        exchangeRateToBaseSnapshot: Value(rate.toString()),
        status: const Value('confirmed'),
        confirmedAt: Value(DateTime.now()),
      ),
    );
    if (payment.paidMinorUnits > 0) {
      final method = _required(
        initialPaymentMethod,
        'El método de pago es obligatorio.',
      );
      if (method.length > 40) {
        throw ArgumentError(
          'El método de pago no puede superar los 40 caracteres.',
        );
      }
      await _insertPayment(
        saleId: saleId,
        amount: initialPaymentMinorUnits,
        currencyCode: sale.currencyCode,
        applied: payment.paidMinorUnits,
        rate: rate,
        date: paymentDate ?? DateTime.now(),
        method: method,
        reference: paymentReference,
        notes: paymentNotes,
      );
    }
  });

  /// Cancela una venta confirmada y compensa sus movimientos de inventario.
  ///
  /// Los pagos históricos se conservan. La devolución del dinero,
  /// si corresponde, deberá registrarse mediante una operación independiente.
  Future<void> cancelSale({
    required String saleId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError('El motivo de cancelación es obligatorio.');
    }

    if (normalizedReason.length > 250) {
      throw ArgumentError(
        'El motivo de cancelación no puede superar los 250 caracteres.',
      );
    }

    await _db.transaction(() async {
      final sale = await findById(saleId);

      if (sale == null) {
        throw StateError('La venta no existe.');
      }

      if (sale.status != 'confirmed') {
        throw StateError('Solo se pueden cancelar ventas confirmadas.');
      }

      final details = await getDetails(saleId);
      final inventoryRepository = InventoryRepository(_db);

      // Compensa cada salida de inventario de la venta.
      // Si alguna falla, la transacción completa se revierte.
      for (final detail in details) {
        final movementId = detail.inventoryMovementId;

        if (movementId == null) {
          continue;
        }

        await inventoryRepository.correctMovementInTransaction(
          originalMovementId: movementId,
          reason: normalizedReason,
          reference: 'sale:$saleId;cancellation;detail:${detail.id}',
        );
      }

      await (_db.update(
        _db.sales,
      )..where((row) => row.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(DateTime.now()),
          cancellationReason: Value(normalizedReason),
        ),
      );
    });
  }

  Future<String> registerPayment({
    required String saleId,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime paymentDate,
    required String paymentMethod,
    String? reference,
    String? notes,
  }) async {
    final code = _currencyCode(currencyCode);
    final method = _required(
      paymentMethod,
      'El método de pago es obligatorio.',
    );
    if (method.length > 40) {
      throw ArgumentError(
        'El método de pago no puede superar los 40 caracteres.',
      );
    }
    if (amountMinorUnits <= 0) {
      throw ArgumentError('El importe del abono debe ser mayor que cero.');
    }
    _checked(BigInt.from(amountMinorUnits));
    return _db.transaction(() async {
      final sale = await findById(saleId);
      if (sale == null) {
        throw StateError('La venta no existe.');
      }
      if (sale.status != 'confirmed') {
        throw StateError(
          'Solo se pueden registrar pagos en ventas confirmadas.',
        );
      }
      final paymentCurrency = await _activeCurrency(code);
      final saleCurrency = await _activeCurrency(sale.currencyCode);
      final paymentRate = await _rates.getRateToBaseForDate(
        currencyCode: code,
        date: paymentDate,
      );
      if (paymentRate == null || paymentRate <= Decimal.zero) {
        throw StateError(
          'No existe una tasa válida para la moneda del pago en esa fecha.',
        );
      }
      final saleRate = _positiveRate(sale.exchangeRateToBaseSnapshot);
      final applied = code == sale.currencyCode
          ? amountMinorUnits
          : _convert(
              amountMinorUnits,
              paymentRate,
              saleRate,
              paymentCurrency.decimalDigits,
              saleCurrency.decimalDigits,
            );
      if (applied <= 0) {
        throw StateError(
          'El importe convertido es demasiado pequeño para aplicarse.',
        );
      }
      final paid = await _sumPayments(saleId);
      _payments.registerPayment(
        totalMinorUnits: sale.totalMinorUnits,
        paidMinorUnits: _checked(paid),
        paymentMinorUnits: applied,
      );
      return _insertPayment(
        saleId: saleId,
        amount: amountMinorUnits,
        currencyCode: code,
        applied: applied,
        rate: paymentRate,
        date: paymentDate,
        method: method,
        reference: reference,
        notes: notes,
      );
    });
  }

  Future<int> getPaidAmount(String saleId) async =>
      _checked(await _sumPayments(saleId));

  Future<int> getOutstandingBalance(String saleId) async {
    final sale = await findById(saleId);
    if (sale == null) {
      throw StateError('La venta no existe.');
    }
    final balance =
        BigInt.from(sale.totalMinorUnits) - await _sumPayments(saleId);
    if (balance < BigInt.zero) {
      throw StateError('Los pagos superan el total de la venta.');
    }
    return _checked(balance);
  }

  Future<SalePaymentSummary> getPaymentSummary(String saleId) async {
    final sale = await findById(saleId);
    if (sale == null) {
      throw StateError('La venta no existe.');
    }
    return _payments.summarize(
      totalMinorUnits: sale.totalMinorUnits,
      paidMinorUnits: await getPaidAmount(saleId),
    );
  }

  Future<String> _insertPayment({
    required String saleId,
    required int amount,
    required String currencyCode,
    required int applied,
    required Decimal rate,
    required DateTime date,
    required String method,
    String? reference,
    String? notes,
  }) async {
    final id = _uuid.v4();
    await _db
        .into(_db.salePayments)
        .insert(
          SalePaymentsCompanion.insert(
            id: id,
            saleId: saleId,
            amountMinorUnits: amount,
            currencyCode: currencyCode,
            exchangeRateToBaseSnapshot: rate.toString(),
            appliedAmountMinorUnits: applied,
            paymentDate: date,
            paymentMethod: method,
            reference: Value(_optional(reference)),
            notes: Value(_optional(notes)),
          ),
        );
    return id;
  }

  // Validaciones y conversiones
  Future<Sale> _draft(String id) async {
    final sale = await findById(id);
    if (sale == null) {
      throw StateError('La venta no existe.');
    }
    if (sale.status != 'draft') {
      throw StateError(
        'La operación solo está permitida en ventas en borrador.',
      );
    }
    return sale;
  }

  Future<Customer> _activeCustomer(String id) async {
    final row = await (_db.select(
      _db.customers,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null || !row.isActive) {
      throw StateError('El cliente no existe o está inactivo.');
    }
    return row;
  }

  Future<Product> _activeProduct(String id) async {
    final row = await (_db.select(
      _db.products,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null || !row.isActive) {
      throw StateError('El producto no existe o está inactivo.');
    }
    return row;
  }

  Future<Currency> _activeCurrency(String code) async {
    final row = await (_db.select(
      _db.currencies,
    )..where((r) => r.code.equals(code))).getSingleOrNull();
    if (row == null || !row.isActive) {
      throw StateError('La moneda no existe o está inactiva.');
    }
    return row;
  }

  Future<Decimal> _rateForDate(String code, DateTime date, bool isBase) async {
    if (isBase) {
      return Decimal.one;
    }
    final row =
        await (_db.select(_db.exchangeRates)
              ..where(
                (r) =>
                    r.currencyCode.equals(code) &
                    r.effectiveAt.isSmallerOrEqualValue(date),
              )
              ..orderBy([(r) => OrderingTerm.desc(r.effectiveAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) {
      throw StateError(
        'No existe una tasa de cambio aplicable para $code en la fecha indicada.',
      );
    }
    final rate = Decimal.parse(row.rateToBase);
    if (rate <= Decimal.zero) {
      throw StateError('La tasa de cambio almacenada no es válida.');
    }
    return rate;
  }

  PurchaseLineCalculationInput _lineInput(SaleDetail d) =>
      PurchaseLineCalculationInput(
        quantityMilliUnits: d.quantityMilliUnits,
        unitCostMinorUnits: d.unitPriceMinorUnits,
        discount: _adjustment(
          d.discountType,
          d.discountMinorUnits,
          d.discountRate,
        ),
        tax: _adjustment(d.taxType, d.taxMinorUnits, d.taxRate),
      );

  PurchaseAdjustmentInput _adjustment(String type, int fixed, String? rate) =>
      switch (type) {
        'fixed' => PurchaseAdjustmentInput.fixed(fixed),
        'percentage' when rate != null && rate.trim().isNotEmpty =>
          PurchaseAdjustmentInput.percentage(Decimal.parse(rate)),
        _ => throw StateError(
          'Tipo o porcentaje de ajuste financiero inválido.',
        ),
      };

  int _convert(
    int amount,
    Decimal paymentRate,
    Decimal saleRate,
    int paymentDigits,
    int saleDigits,
  ) {
    final converted =
        Decimal.fromInt(amount) *
        paymentRate.shift(saleDigits - paymentDigits) /
        saleRate;
    return _checked(converted.round());
  }

  Future<BigInt> _sumPayments(String saleId) async {
    final rows = await (_db.select(
      _db.salePayments,
    )..where((r) => r.saleId.equals(saleId))).get();
    var total = BigInt.zero;
    for (final row in rows) {
      total += BigInt.from(row.appliedAmountMinorUnits);
      if (total > _maxInt) {
        throw RangeError('La suma de los pagos supera el límite de SQLite.');
      }
    }
    return total;
  }

  Decimal _positiveRate(String value) {
    try {
      final rate = Decimal.parse(value);
      if (rate <= Decimal.zero) {
        throw StateError('La tasa histórica de la venta no es válida.');
      }
      return rate;
    } on FormatException {
      throw StateError('La tasa histórica de la venta no es válida.');
    }
  }

  int _checked(BigInt value) {
    if (value < BigInt.zero || value > _maxInt) {
      throw RangeError(
        'El importe supera el límite de almacenamiento de SQLite.',
      );
    }
    return value.toInt();
  }

  String _currencyCode(String value) {
    final code = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw ArgumentError('El código de moneda debe contener tres letras.');
    }
    return code;
  }

  String _required(String value, String message) {
    final result = value.trim();
    if (result.isEmpty) {
      throw ArgumentError(message);
    }
    return result;
  }

  String? _optional(String? value) {
    final result = value?.trim();
    return result == null || result.isEmpty ? null : result;
  }

  String? _percentage(PurchaseAdjustmentInput input) =>
      input.type == PurchaseAdjustmentType.fixed
      ? null
      : input.percentage?.toString();
  SalePaymentType _paymentType(String value) => switch (value) {
    'cash' => SalePaymentType.cash,
    'credit' => SalePaymentType.credit,
    _ => throw StateError('Tipo de pago de venta desconocido: $value.'),
  };
}
