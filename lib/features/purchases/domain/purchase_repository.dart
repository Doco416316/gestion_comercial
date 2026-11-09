import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/purchase_calculation_service.dart';

/// Gestiona las compras y sus detalles.
///
/// En esta primera etapa implementa:
/// - Consultas de compras.
/// - Creación y edición de borradores.
/// - Gestión de detalles.
/// - Recalculo de importes.
/// - Confirmación y anulación de compras.
///
/// Las recepciones y los pagos se implementarán posteriormente.
class PurchaseRepository {
  PurchaseRepository(
    this._database, {
    PurchaseCalculationService? calculationService,
  }) : _calculationService = calculationService ?? PurchaseCalculationService();

  final AppDatabase _database;
  final PurchaseCalculationService _calculationService;

  static const Uuid _uuid = Uuid();

  static const Set<String> _validStatuses = {'draft', 'confirmed', 'cancelled'};

  // ============================================================
  // CONSULTAS
  // ============================================================

  /// Observa todas las compras, ordenadas por fecha descendente.
  Stream<List<Purchase>> watchAll() {
    return (_database.select(_database.purchases)
          ..orderBy([(purchase) => OrderingTerm.desc(purchase.purchaseDate)]))
        .watch();
  }

  /// Observa las compras de un estado determinado.
  Stream<List<Purchase>> watchByStatus(String status) {
    _validateStatus(status);

    return (_database.select(_database.purchases)
          ..where((purchase) => purchase.status.equals(status))
          ..orderBy([(purchase) => OrderingTerm.desc(purchase.purchaseDate)]))
        .watch();
  }

  /// Busca una compra por su identificador.
  Future<Purchase?> findById(String purchaseId) {
    return (_database.select(
      _database.purchases,
    )..where((purchase) => purchase.id.equals(purchaseId))).getSingleOrNull();
  }

  /// Observa los detalles de una compra.
  Stream<List<PurchaseDetail>> watchDetails(String purchaseId) {
    return (_database.select(
      _database.purchaseDetails,
    )..where((detail) => detail.purchaseId.equals(purchaseId))).watch();
  }

  /// Obtiene los detalles actuales de una compra.
  Future<List<PurchaseDetail>> getDetails(String purchaseId) {
    return (_database.select(
      _database.purchaseDetails,
    )..where((detail) => detail.purchaseId.equals(purchaseId))).get();
  }

  // ============================================================
  // CREACIÓN DE BORRADORES
  // ============================================================

  /// Crea una compra nueva en estado draft.
  ///
  /// La tasa almacenada es provisional. Se actualizará al confirmar
  /// la compra utilizando la tasa aplicable a la fecha de compra.
  Future<String> createDraft({
    required String supplierId,
    required DateTime purchaseDate,
    required String currencyCode,
    String? documentNumber,
    String? notes,
  }) async {
    final normalizedCurrency = _normalizeCurrencyCode(currencyCode);

    return _database.transaction(() async {
      await _requireActiveSupplier(supplierId);

      final currency = await _requireActiveCurrency(normalizedCurrency);

      final rate = await _getRateForDate(
        normalizedCurrency,
        purchaseDate,
        currencyIsBase: currency.isBase,
      );

      final purchaseId = _uuid.v4();

      await _database
          .into(_database.purchases)
          .insert(
            PurchasesCompanion.insert(
              id: purchaseId,
              supplierId: supplierId,
              documentNumber: Value(_normalizeOptional(documentNumber)),
              purchaseDate: purchaseDate,
              currencyCode: normalizedCurrency,
              exchangeRateToBaseSnapshot: rate.toString(),
              subtotalMinorUnits: 0,
              discountMinorUnits: const Value(0),
              taxMinorUnits: const Value(0),
              totalMinorUnits: 0,
              notes: Value(_normalizeOptional(notes)),
            ),
          );

      return purchaseId;
    });
  }

  /// Modifica los datos generales de un borrador.
  ///
  /// Si cambia la fecha o la moneda, se obtiene una nueva tasa
  /// provisional aplicable a esos datos.
  ///
  /// No permite cambiar la moneda si ya existen detalles,
  /// porque eso modificaría la interpretación de sus importes.
  Future<void> updateDraftHeader({
    required String purchaseId,
    required String supplierId,
    required DateTime purchaseDate,
    required String currencyCode,
    String? documentNumber,
    String? notes,
  }) async {
    final normalizedCurrency = _normalizeCurrencyCode(currencyCode);

    await _database.transaction(() async {
      final existingPurchase = await _requireDraftPurchase(purchaseId);

      await _requireActiveSupplier(supplierId);

      if (existingPurchase.currencyCode != normalizedCurrency) {
        final details = await (_database.select(
          _database.purchaseDetails,
        )..where((detail) => detail.purchaseId.equals(purchaseId))).get();

        if (details.isNotEmpty) {
          throw StateError(
            'No se puede cambiar la moneda de una compra '
            'que ya contiene detalles. Elimina los detalles '
            'antes de cambiar la moneda.',
          );
        }
      }

      final currency = await _requireActiveCurrency(normalizedCurrency);

      final rate = await _getRateForDate(
        normalizedCurrency,
        purchaseDate,
        currencyIsBase: currency.isBase,
      );

      await (_database.update(
        _database.purchases,
      )..where((purchase) => purchase.id.equals(purchaseId))).write(
        PurchasesCompanion(
          supplierId: Value(supplierId),
          purchaseDate: Value(purchaseDate),
          currencyCode: Value(normalizedCurrency),
          exchangeRateToBaseSnapshot: Value(rate.toString()),
          documentNumber: Value(_normalizeOptional(documentNumber)),
          notes: Value(_normalizeOptional(notes)),
        ),
      );
    });
  }

  // ============================================================
  // DETALLES DE COMPRA
  // ============================================================

  /// Agrega un detalle a un borrador y recalcula sus importes.
  Future<String> addDetail({
    required String purchaseId,
    required String productId,
    required int quantityMilliUnits,
    required int unitCostMinorUnits,
    PurchaseAdjustmentInput discount = const PurchaseAdjustmentInput.fixed(0),
    PurchaseAdjustmentInput tax = const PurchaseAdjustmentInput.fixed(0),
  }) async {
    return _database.transaction(() async {
      await _requireDraftPurchase(purchaseId);

      final product = await _requireActiveProduct(productId);

      // Validación previa mediante el servicio financiero.
      final calculatedLine = _calculationService.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: quantityMilliUnits,
          unitCostMinorUnits: unitCostMinorUnits,
          discount: discount,
          tax: tax,
        ),
      );

      final detailId = _uuid.v4();

      await _database
          .into(_database.purchaseDetails)
          .insert(
            PurchaseDetailsCompanion.insert(
              id: detailId,
              purchaseId: purchaseId,
              productId: productId,
              skuSnapshot: product.sku,
              productNameSnapshot: product.name,
              unitSnapshot: product.unit,
              quantityMilliUnits: quantityMilliUnits,
              unitCostMinorUnits: unitCostMinorUnits,
              discountMinorUnits: Value(calculatedLine.discountMinorUnits),
              discountType: Value(_adjustmentTypeToDatabase(discount.type)),
              discountRate: Value(_percentageToDatabase(discount)),
              taxMinorUnits: Value(calculatedLine.taxMinorUnits),
              taxType: Value(_adjustmentTypeToDatabase(tax.type)),
              taxRate: Value(_percentageToDatabase(tax)),
              totalMinorUnits: calculatedLine.totalMinorUnits,
            ),
          );

      await _recalculateDraft(purchaseId);

      return detailId;
    });
  }

  /// Modifica un detalle existente de un borrador.
  Future<void> updateDetail({
    required String purchaseId,
    required String detailId,
    required String productId,
    required int quantityMilliUnits,
    required int unitCostMinorUnits,
    PurchaseAdjustmentInput discount = const PurchaseAdjustmentInput.fixed(0),
    PurchaseAdjustmentInput tax = const PurchaseAdjustmentInput.fixed(0),
  }) async {
    await _database.transaction(() async {
      await _requireDraftPurchase(purchaseId);

      final existingDetail = await (_database.select(
        _database.purchaseDetails,
      )..where((detail) => detail.id.equals(detailId))).getSingleOrNull();

      if (existingDetail == null || existingDetail.purchaseId != purchaseId) {
        throw StateError('El detalle no pertenece a esta compra.');
      }

      final product = await _requireActiveProduct(productId);

      final calculatedLine = _calculationService.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: quantityMilliUnits,
          unitCostMinorUnits: unitCostMinorUnits,
          discount: discount,
          tax: tax,
        ),
      );

      await (_database.update(
        _database.purchaseDetails,
      )..where((detail) => detail.id.equals(detailId))).write(
        PurchaseDetailsCompanion(
          productId: Value(productId),
          skuSnapshot: Value(product.sku),
          productNameSnapshot: Value(product.name),
          unitSnapshot: Value(product.unit),
          quantityMilliUnits: Value(quantityMilliUnits),
          unitCostMinorUnits: Value(unitCostMinorUnits),
          discountMinorUnits: Value(calculatedLine.discountMinorUnits),
          discountType: Value(_adjustmentTypeToDatabase(discount.type)),
          discountRate: Value(_percentageToDatabase(discount)),
          taxMinorUnits: Value(calculatedLine.taxMinorUnits),
          taxType: Value(_adjustmentTypeToDatabase(tax.type)),
          taxRate: Value(_percentageToDatabase(tax)),
          totalMinorUnits: Value(calculatedLine.totalMinorUnits),
        ),
      );

      await _recalculateDraft(purchaseId);
    });
  }

  /// Elimina un detalle de un borrador.
  ///
  /// Si se elimina el último detalle, los importes de la compra
  /// vuelven a cero.
  Future<void> removeDetail({
    required String purchaseId,
    required String detailId,
  }) async {
    await _database.transaction(() async {
      await _requireDraftPurchase(purchaseId);

      final detail = await (_database.select(
        _database.purchaseDetails,
      )..where((row) => row.id.equals(detailId))).getSingleOrNull();

      if (detail == null || detail.purchaseId != purchaseId) {
        throw StateError('El detalle no pertenece a esta compra.');
      }

      await (_database.delete(
        _database.purchaseDetails,
      )..where((row) => row.id.equals(detailId))).go();

      await _recalculateDraft(purchaseId);
    });
  }

  // ============================================================
  // RECÁLCULO FINANCIERO
  // ============================================================

  /// Recalcula todas las líneas y el resumen de una compra.
  ///
  /// Solo puede utilizarse mientras la compra sea un borrador.
  Future<PurchaseCalculationResult?> recalculateDraft(String purchaseId) async {
    return _database.transaction(() async {
      await _requireDraftPurchase(purchaseId);
      return _recalculateDraft(purchaseId);
    });
  }

  Future<PurchaseCalculationResult?> _recalculateDraft(
    String purchaseId,
  ) async {
    final details = await (_database.select(
      _database.purchaseDetails,
    )..where((detail) => detail.purchaseId.equals(purchaseId))).get();

    if (details.isEmpty) {
      await (_database.update(
        _database.purchases,
      )..where((purchase) => purchase.id.equals(purchaseId))).write(
        const PurchasesCompanion(
          subtotalMinorUnits: Value(0),
          discountMinorUnits: Value(0),
          taxMinorUnits: Value(0),
          totalMinorUnits: Value(0),
        ),
      );

      return null;
    }

    final inputs = details.map(_detailToCalculationInput).toList();

    final result = _calculationService.calculatePurchase(inputs);

    // Guardar los importes calculados de cada línea.
    for (var index = 0; index < details.length; index++) {
      final detail = details[index];
      final calculatedLine = result.lines[index];

      await (_database.update(
        _database.purchaseDetails,
      )..where((row) => row.id.equals(detail.id))).write(
        PurchaseDetailsCompanion(
          discountMinorUnits: Value(calculatedLine.discountMinorUnits),
          taxMinorUnits: Value(calculatedLine.taxMinorUnits),
          totalMinorUnits: Value(calculatedLine.totalMinorUnits),
        ),
      );
    }

    // Guardar el resumen de la compra.
    await (_database.update(
      _database.purchases,
    )..where((purchase) => purchase.id.equals(purchaseId))).write(
      PurchasesCompanion(
        subtotalMinorUnits: Value(result.subtotalMinorUnits),
        discountMinorUnits: Value(result.discountMinorUnits),
        taxMinorUnits: Value(result.taxMinorUnits),
        totalMinorUnits: Value(result.totalMinorUnits),
      ),
    );

    return result;
  }

  PurchaseLineCalculationInput _detailToCalculationInput(
    PurchaseDetail detail,
  ) {
    return PurchaseLineCalculationInput(
      quantityMilliUnits: detail.quantityMilliUnits,
      unitCostMinorUnits: detail.unitCostMinorUnits,
      discount: _adjustmentFromDatabase(
        type: detail.discountType,
        fixedMinorUnits: detail.discountMinorUnits,
        percentageText: detail.discountRate,
      ),
      tax: _adjustmentFromDatabase(
        type: detail.taxType,
        fixedMinorUnits: detail.taxMinorUnits,
        percentageText: detail.taxRate,
      ),
    );
  }

  PurchaseAdjustmentInput _adjustmentFromDatabase({
    required String type,
    required int fixedMinorUnits,
    required String? percentageText,
  }) {
    switch (type) {
      case 'fixed':
        return PurchaseAdjustmentInput.fixed(fixedMinorUnits);

      case 'percentage':
        if (percentageText == null || percentageText.trim().isEmpty) {
          throw StateError(
            'El porcentaje almacenado en un detalle es inválido.',
          );
        }

        return PurchaseAdjustmentInput.percentage(
          Decimal.parse(percentageText),
        );

      default:
        throw StateError('Tipo de ajuste financiero desconocido: $type.');
    }
  }

  // ============================================================
  // CONFIRMACIÓN Y ANULACIÓN
  // ============================================================

  /// Confirma una compra.
  ///
  /// Antes de confirmar:
  /// - Verifica proveedor y moneda.
  /// - Verifica que los productos sigan activos.
  /// - Recalcula todos los importes.
  /// - Actualiza la tasa al valor histórico aplicable.
  ///
  /// Después de confirmar, los triggers de SQLite impiden
  /// modificar sus datos y detalles.
  Future<void> confirmPurchase(String purchaseId) async {
    await _database.transaction(() async {
      final purchase = await _requireDraftPurchase(purchaseId);

      await _requireActiveSupplier(purchase.supplierId);

      final currency = await _requireActiveCurrency(purchase.currencyCode);

      final details = await (_database.select(
        _database.purchaseDetails,
      )..where((detail) => detail.purchaseId.equals(purchaseId))).get();

      if (details.isEmpty) {
        throw StateError('No se puede confirmar una compra sin detalles.');
      }

      for (final detail in details) {
        await _requireActiveProduct(detail.productId);
      }

      // Recalcular antes de convertir el borrador en definitivo.
      await _recalculateDraft(purchaseId);

      final rate = await _getRateForDate(
        purchase.currencyCode,
        purchase.purchaseDate,
        currencyIsBase: currency.isBase,
      );

      await (_database.update(
        _database.purchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        PurchasesCompanion(
          exchangeRateToBaseSnapshot: Value(rate.toString()),
          status: const Value('confirmed'),
          confirmedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Anula una compra confirmada.
  ///
  /// SQLite impedirá la operación si existen pagos o recepciones.
  /// Una compra anulada nunca vuelve a ser borrador.
  Future<void> cancelPurchase({
    required String purchaseId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError('El motivo de anulación es obligatorio.');
    }

    await _database.transaction(() async {
      final purchase = await (_database.select(
        _database.purchases,
      )..where((row) => row.id.equals(purchaseId))).getSingleOrNull();

      if (purchase == null) {
        throw StateError('La compra no existe.');
      }

      if (purchase.status != 'confirmed') {
        throw StateError('Solo se pueden anular compras confirmadas.');
      }

      await (_database.update(
        _database.purchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        PurchasesCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(DateTime.now()),
          cancellationReason: Value(normalizedReason),
        ),
      );
    });
  }

  /// Elimina físicamente un borrador.
  ///
  /// Primero elimina sus detalles porque la relación de la base
  /// de datos utiliza una restricción de eliminación.
  Future<void> deleteDraft(String purchaseId) async {
    await _database.transaction(() async {
      await _requireDraftPurchase(purchaseId);

      await (_database.delete(
        _database.purchaseDetails,
      )..where((detail) => detail.purchaseId.equals(purchaseId))).go();

      await (_database.delete(
        _database.purchases,
      )..where((purchase) => purchase.id.equals(purchaseId))).go();
    });
  }

  // ============================================================
  // VALIDACIONES Y UTILIDADES
  // ============================================================

  Future<Purchase> _requireDraftPurchase(String purchaseId) async {
    final purchase = await (_database.select(
      _database.purchases,
    )..where((row) => row.id.equals(purchaseId))).getSingleOrNull();

    if (purchase == null) {
      throw StateError('La compra no existe.');
    }

    if (purchase.status != 'draft') {
      throw StateError(
        'La operación solo está permitida en compras en borrador.',
      );
    }

    return purchase;
  }

  Future<Supplier> _requireActiveSupplier(String supplierId) async {
    final supplier = await (_database.select(
      _database.suppliers,
    )..where((row) => row.id.equals(supplierId))).getSingleOrNull();

    if (supplier == null || !supplier.isActive) {
      throw StateError('El proveedor no existe o está inactivo.');
    }

    return supplier;
  }

  Future<Product> _requireActiveProduct(String productId) async {
    final product = await (_database.select(
      _database.products,
    )..where((row) => row.id.equals(productId))).getSingleOrNull();

    if (product == null || !product.isActive) {
      throw StateError('El producto no existe o está inactivo.');
    }

    return product;
  }

  Future<Currency> _requireActiveCurrency(String currencyCode) async {
    final currency = await (_database.select(
      _database.currencies,
    )..where((row) => row.code.equals(currencyCode))).getSingleOrNull();

    if (currency == null || !currency.isActive) {
      throw StateError('La moneda no existe o está inactiva.');
    }

    return currency;
  }

  /// Obtiene la tasa más reciente cuya fecha efectiva no supera
  /// la fecha de la operación.
  ///
  /// La moneda base siempre tiene una tasa igual a 1.
  Future<Decimal> _getRateForDate(
    String currencyCode,
    DateTime date, {
    required bool currencyIsBase,
  }) async {
    if (currencyIsBase) {
      return Decimal.one;
    }

    final rate =
        await (_database.select(_database.exchangeRates)
              ..where(
                (row) =>
                    row.currencyCode.equals(currencyCode) &
                    row.effectiveAt.isSmallerOrEqualValue(date),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.effectiveAt)])
              ..limit(1))
            .getSingleOrNull();

    if (rate == null) {
      throw StateError(
        'No existe una tasa de cambio aplicable para '
        '$currencyCode en la fecha ${date.toIso8601String()}.',
      );
    }

    final parsedRate = Decimal.parse(rate.rateToBase);

    if (parsedRate <= Decimal.zero) {
      throw StateError('La tasa de cambio almacenada no es válida.');
    }

    return parsedRate;
  }

  String _normalizeCurrencyCode(String value) {
    final normalized = value.trim().toUpperCase();

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) {
      throw ArgumentError('El código de moneda debe contener tres letras.');
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

  void _validateStatus(String status) {
    if (!_validStatuses.contains(status)) {
      throw ArgumentError('Estado de compra no válido: $status.');
    }
  }

  String _adjustmentTypeToDatabase(PurchaseAdjustmentType type) {
    return switch (type) {
      PurchaseAdjustmentType.fixed => 'fixed',
      PurchaseAdjustmentType.percentage => 'percentage',
    };
  }

  String? _percentageToDatabase(PurchaseAdjustmentInput adjustment) {
    if (adjustment.type == PurchaseAdjustmentType.fixed) {
      return null;
    }

    return adjustment.percentage?.toString();
  }
}
