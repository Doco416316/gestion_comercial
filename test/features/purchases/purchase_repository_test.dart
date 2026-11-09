import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/domain/purchase_calculation_service.dart';
import 'package:gestion_comercial/features/settings/data/exchange_rate_repository.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository repository;
  late SupplierRepository supplierRepository;
  late ExchangeRateRepository exchangeRateRepository;

  final purchaseDate = DateTime(2026, 1, 15);
  final rateDate = DateTime(2026, 1, 1);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PurchaseRepository(database);
    supplierRepository = SupplierRepository(database);
    exchangeRateRepository = ExchangeRateRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCurrency({
    required String code,
    bool isBase = false,
    bool isActive = true,
  }) async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: code,
            name: code,
            symbol: code,
            isBase: Value(isBase),
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> insertBaseCurrency() async {
    await insertCurrency(code: 'CUP', isBase: true);
  }

  Future<void> insertUsdCurrency() async {
    await insertBaseCurrency();
    await insertCurrency(code: 'USD');
  }

  Future<void> registerUsdRate({
    required Decimal rate,
    DateTime? effectiveAt,
  }) async {
    await exchangeRateRepository.registerRate(
      currencyCode: 'USD',
      rateToBase: rate,
      effectiveAt: effectiveAt ?? rateDate,
    );
  }

  Future<String> createSupplier({String name = 'Proveedor de prueba'}) {
    return supplierRepository.createSupplier(name: name);
  }

  Future<String> createProduct({
    String id = 'product-1',
    String sku = 'SKU-001',
    String name = 'Producto de prueba',
    String unit = 'unidad',
    bool isActive = true,
  }) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            sku: sku,
            name: name,
            unit: Value(unit),
            isActive: Value(isActive),
          ),
        );

    return id;
  }

  Future<String> createPurchase({
    String? supplierId,
    DateTime? date,
    String currencyCode = 'CUP',
    String? documentNumber,
    String? notes,
  }) async {
    final resolvedSupplierId = supplierId ?? await createSupplier();

    return repository.createDraft(
      supplierId: resolvedSupplierId,
      purchaseDate: date ?? purchaseDate,
      currencyCode: currencyCode,
      documentNumber: documentNumber,
      notes: notes,
    );
  }

  group('PurchaseRepository - borradores', () {
    test('crea un borrador correctamente', () async {
      await insertBaseCurrency();

      final supplierId = await createSupplier();

      final id = await repository.createDraft(
        supplierId: supplierId,
        purchaseDate: purchaseDate,
        currencyCode: 'CUP',
        documentNumber: 'FAC-001',
        notes: 'Compra de prueba',
      );

      final purchase = await repository.findById(id);

      expect(purchase, isNotNull);
      expect(purchase!.supplierId, supplierId);
      expect(purchase.status, 'draft');
      expect(purchase.currencyCode, 'CUP');
      expect(purchase.exchangeRateToBaseSnapshot, '1');
      expect(purchase.documentNumber, 'FAC-001');
      expect(purchase.notes, 'Compra de prueba');
      expect(purchase.subtotalMinorUnits, 0);
      expect(purchase.discountMinorUnits, 0);
      expect(purchase.taxMinorUnits, 0);
      expect(purchase.totalMinorUnits, 0);
      expect(purchase.confirmedAt, isNull);
      expect(purchase.cancelledAt, isNull);
    });

    test('normaliza el código de moneda', () async {
      await insertBaseCurrency();

      final id = await createPurchase(currencyCode: ' cup ');

      final purchase = await repository.findById(id);

      expect(purchase!.currencyCode, 'CUP');
    });

    test('normaliza los campos opcionales vacíos', () async {
      await insertBaseCurrency();

      final id = await createPurchase(documentNumber: ' ', notes: '   ');

      final purchase = await repository.findById(id);

      expect(purchase!.documentNumber, isNull);
      expect(purchase.notes, isNull);
    });

    test('rechaza un código de moneda inválido', () async {
      await insertBaseCurrency();

      final supplierId = await createSupplier();

      await expectLater(
        repository.createDraft(
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'US',
        ),
        throwsArgumentError,
      );
    });

    test('rechaza un proveedor inexistente', () async {
      await insertBaseCurrency();

      await expectLater(
        repository.createDraft(
          supplierId: 'proveedor-inexistente',
          purchaseDate: purchaseDate,
          currencyCode: 'CUP',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza un proveedor inactivo', () async {
      await insertBaseCurrency();

      final supplierId = await createSupplier();

      await supplierRepository.setActive(supplierId, false);

      await expectLater(
        repository.createDraft(
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'CUP',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza una moneda inexistente', () async {
      await insertBaseCurrency();

      final supplierId = await createSupplier();

      await expectLater(
        repository.createDraft(
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'EUR',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza una moneda inactiva', () async {
      await insertBaseCurrency();
      await insertCurrency(code: 'USD', isActive: false);

      final supplierId = await createSupplier();

      await expectLater(
        repository.createDraft(
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'USD',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('exige una tasa aplicable para monedas no base', () async {
      await insertUsdCurrency();

      final supplierId = await createSupplier();

      await expectLater(
        repository.createDraft(
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'USD',
        ),
        throwsA(isA<StateError>()),
      );

      final purchases = await repository.watchAll().first;

      expect(purchases, isEmpty);
    });

    test('guarda la tasa provisional aplicable al crear el borrador', () async {
      await insertUsdCurrency();
      await registerUsdRate(rate: Decimal.parse('400'));

      final id = await createPurchase(currencyCode: 'USD');

      final purchase = await repository.findById(id);

      expect(purchase!.exchangeRateToBaseSnapshot, '400');
    });

    test('consulta todas las compras', () async {
      await insertBaseCurrency();

      final firstId = await createPurchase(date: DateTime(2026, 1, 10));

      final secondId = await createPurchase(date: DateTime(2026, 2, 10));

      final purchases = await repository.watchAll().first;

      expect(purchases.length, 2);
      expect(purchases.first.id, secondId);
      expect(purchases.last.id, firstId);
    });

    test('filtra las compras por estado', () async {
      await insertBaseCurrency();

      final draftId = await createPurchase();

      final confirmedId = await createPurchase(date: DateTime(2026, 2, 10));

      await createProduct();

      await repository.addDetail(
        purchaseId: confirmedId,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(confirmedId);

      final drafts = await repository.watchByStatus('draft').first;
      final confirmed = await repository.watchByStatus('confirmed').first;

      expect(drafts.length, 1);
      expect(drafts.first.id, draftId);

      expect(confirmed.length, 1);
      expect(confirmed.first.id, confirmedId);
    });

    test('rechaza consultar por un estado inválido', () {
      expect(() => repository.watchByStatus('invalid'), throwsArgumentError);
    });

    test('devuelve null al consultar una compra inexistente', () async {
      final purchase = await repository.findById('inexistente');

      expect(purchase, isNull);
    });
  });

  group('PurchaseRepository - detalles', () {
    late String purchaseId;
    late String productId;

    setUp(() async {
      await insertBaseCurrency();

      purchaseId = await createPurchase();

      productId = await createProduct();
    });

    test('agrega un detalle correctamente', () async {
      final detailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
      );

      final details = await repository.getDetails(purchaseId);
      final purchase = await repository.findById(purchaseId);

      expect(details.length, 1);
      expect(details.first.id, detailId);
      expect(details.first.productId, productId);
      expect(details.first.skuSnapshot, 'SKU-001');
      expect(details.first.productNameSnapshot, 'Producto de prueba');
      expect(details.first.unitSnapshot, 'unidad');
      expect(details.first.quantityMilliUnits, 2000);
      expect(details.first.unitCostMinorUnits, 1000);
      expect(details.first.totalMinorUnits, 2000);

      expect(purchase!.subtotalMinorUnits, 2000);
      expect(purchase.discountMinorUnits, 0);
      expect(purchase.taxMinorUnits, 0);
      expect(purchase.totalMinorUnits, 2000);
    });

    test(
      'calcula correctamente un descuento fijo y un impuesto fijo',
      () async {
        final detailId = await repository.addDetail(
          purchaseId: purchaseId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitCostMinorUnits: 1000,
          discount: const PurchaseAdjustmentInput.fixed(150),
          tax: const PurchaseAdjustmentInput.fixed(50),
        );

        final detail = (await repository.getDetails(purchaseId)).first;
        final purchase = await repository.findById(purchaseId);

        expect(detail.id, detailId);
        expect(detail.discountType, 'fixed');
        expect(detail.discountMinorUnits, 150);
        expect(detail.taxType, 'fixed');
        expect(detail.taxMinorUnits, 50);
        expect(detail.totalMinorUnits, 1900);

        expect(purchase!.subtotalMinorUnits, 2000);
        expect(purchase.discountMinorUnits, 150);
        expect(purchase.taxMinorUnits, 50);
        expect(purchase.totalMinorUnits, 1900);
      },
    );

    test('calcula correctamente descuentos e impuestos porcentuales', () async {
      await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
        discount: PurchaseAdjustmentInput.percentage(Decimal.parse('10')),
        tax: PurchaseAdjustmentInput.percentage(Decimal.parse('5')),
      );

      final detail = (await repository.getDetails(purchaseId)).first;
      final purchase = await repository.findById(purchaseId);

      expect(detail.discountType, 'percentage');
      expect(detail.discountRate, '10');
      expect(detail.discountMinorUnits, 200);

      expect(detail.taxType, 'percentage');
      expect(detail.taxRate, '5');
      expect(detail.taxMinorUnits, 90);

      expect(detail.totalMinorUnits, 1890);

      expect(purchase!.subtotalMinorUnits, 2000);
      expect(purchase.discountMinorUnits, 200);
      expect(purchase.taxMinorUnits, 90);
      expect(purchase.totalMinorUnits, 1890);
    });

    test('rechaza cantidades iguales a cero', () async {
      await expectLater(
        repository.addDetail(
          purchaseId: purchaseId,
          productId: productId,
          quantityMilliUnits: 0,
          unitCostMinorUnits: 1000,
        ),
        throwsArgumentError,
      );

      expect(await repository.getDetails(purchaseId), isEmpty);
    });

    test('rechaza cantidades negativas', () async {
      await expectLater(
        repository.addDetail(
          purchaseId: purchaseId,
          productId: productId,
          quantityMilliUnits: -1000,
          unitCostMinorUnits: 1000,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza costos unitarios negativos', () async {
      await expectLater(
        repository.addDetail(
          purchaseId: purchaseId,
          productId: productId,
          quantityMilliUnits: 1000,
          unitCostMinorUnits: -1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza productos inexistentes', () async {
      await expectLater(
        repository.addDetail(
          purchaseId: purchaseId,
          productId: 'producto-inexistente',
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza productos inactivos', () async {
      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'inactive-product',
              sku: 'SKU-INACTIVE',
              name: 'Producto inactivo',
              unit: const Value('unidad'),
              isActive: const Value(false),
            ),
          );

      await expectLater(
        repository.addDetail(
          purchaseId: purchaseId,
          productId: 'inactive-product',
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('actualiza un detalle y recalcula la compra', () async {
      final detailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.updateDetail(
        purchaseId: purchaseId,
        detailId: detailId,
        productId: productId,
        quantityMilliUnits: 3000,
        unitCostMinorUnits: 2000,
        discount: const PurchaseAdjustmentInput.fixed(500),
      );

      final detail = (await repository.getDetails(purchaseId)).first;
      final purchase = await repository.findById(purchaseId);

      expect(detail.quantityMilliUnits, 3000);
      expect(detail.unitCostMinorUnits, 2000);
      expect(detail.discountMinorUnits, 500);
      expect(detail.totalMinorUnits, 5500);

      expect(purchase!.subtotalMinorUnits, 6000);
      expect(purchase.discountMinorUnits, 500);
      expect(purchase.totalMinorUnits, 5500);
    });

    test('rechaza actualizar un detalle de otra compra', () async {
      final otherPurchaseId = await createPurchase();

      final detailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await expectLater(
        repository.updateDetail(
          purchaseId: otherPurchaseId,
          detailId: detailId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitCostMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('elimina un detalle y actualiza los totales', () async {
      final firstDetailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
      );

      await repository.removeDetail(
        purchaseId: purchaseId,
        detailId: firstDetailId,
      );

      final details = await repository.getDetails(purchaseId);
      final purchase = await repository.findById(purchaseId);

      expect(details.length, 1);
      expect(details.first.quantityMilliUnits, 2000);
      expect(purchase!.subtotalMinorUnits, 2000);
      expect(purchase.totalMinorUnits, 2000);
    });

    test('rechaza eliminar un detalle de otra compra', () async {
      final otherPurchaseId = await createPurchase();

      final detailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await expectLater(
        repository.removeDetail(
          purchaseId: otherPurchaseId,
          detailId: detailId,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('al eliminar el último detalle los totales vuelven a cero', () async {
      final detailId = await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.removeDetail(purchaseId: purchaseId, detailId: detailId);

      final purchase = await repository.findById(purchaseId);

      expect(await repository.getDetails(purchaseId), isEmpty);
      expect(purchase!.subtotalMinorUnits, 0);
      expect(purchase.discountMinorUnits, 0);
      expect(purchase.taxMinorUnits, 0);
      expect(purchase.totalMinorUnits, 0);
    });

    test('recalcula una compra sin detalles y devuelve null', () async {
      final result = await repository.recalculateDraft(purchaseId);

      expect(result, isNull);
    });

    test('recalcula los importes de una compra con detalles', () async {
      await repository.addDetail(
        purchaseId: purchaseId,
        productId: productId,
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
        discount: const PurchaseAdjustmentInput.fixed(100),
      );

      final result = await repository.recalculateDraft(purchaseId);

      expect(result, isNotNull);
      expect(result!.subtotalMinorUnits, 2000);
      expect(result.discountMinorUnits, 100);
      expect(result.totalMinorUnits, 1900);
    });
  });

  group('PurchaseRepository - edición de cabecera', () {
    test('actualiza los datos generales de un borrador', () async {
      await insertBaseCurrency();

      final supplierId = await createSupplier();
      final newSupplierId = await createSupplier(name: 'Segundo proveedor');

      final id = await createPurchase(supplierId: supplierId);

      final newDate = DateTime(2026, 2, 10);

      await repository.updateDraftHeader(
        purchaseId: id,
        supplierId: newSupplierId,
        purchaseDate: newDate,
        currencyCode: 'CUP',
        documentNumber: 'FAC-UPDATED',
        notes: 'Notas actualizadas',
      );

      final purchase = await repository.findById(id);

      expect(purchase!.supplierId, newSupplierId);
      expect(purchase.purchaseDate, newDate);
      expect(purchase.currencyCode, 'CUP');
      expect(purchase.documentNumber, 'FAC-UPDATED');
      expect(purchase.notes, 'Notas actualizadas');
      expect(purchase.exchangeRateToBaseSnapshot, '1');
    });

    test('rechaza actualizar con proveedor inexistente', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await expectLater(
        repository.updateDraftHeader(
          purchaseId: id,
          supplierId: 'proveedor-inexistente',
          purchaseDate: purchaseDate,
          currencyCode: 'CUP',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('actualiza la tasa provisional al cambiar la moneda', () async {
      await insertUsdCurrency();
      await registerUsdRate(rate: Decimal.parse('400'));

      final id = await createPurchase();

      await repository.updateDraftHeader(
        purchaseId: id,
        supplierId: (await repository.findById(id))!.supplierId,
        purchaseDate: purchaseDate,
        currencyCode: 'USD',
      );

      final purchase = await repository.findById(id);

      expect(purchase!.currencyCode, 'USD');
      expect(purchase.exchangeRateToBaseSnapshot, '400');
    });
  });

  group('PurchaseRepository - confirmación', () {
    test('confirma una compra con detalles', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      final purchase = await repository.findById(id);

      expect(purchase!.status, 'confirmed');
      expect(purchase.confirmedAt, isNotNull);
      expect(purchase.exchangeRateToBaseSnapshot, '1');
      expect(purchase.subtotalMinorUnits, 2000);
      expect(purchase.totalMinorUnits, 2000);
    });

    test('no permite confirmar una compra sin detalles', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await expectLater(
        repository.confirmPurchase(id),
        throwsA(isA<StateError>()),
      );

      final purchase = await repository.findById(id);

      expect(purchase!.status, 'draft');
      expect(purchase.confirmedAt, isNull);
    });

    test('utiliza la tasa histórica aplicable al confirmar', () async {
      await insertUsdCurrency();

      await registerUsdRate(
        rate: Decimal.parse('400'),
        effectiveAt: DateTime(2026, 1, 1),
      );

      final id = await createPurchase(
        currencyCode: 'USD',
        date: DateTime(2026, 2, 10),
      );

      final draft = await repository.findById(id);

      expect(draft!.exchangeRateToBaseSnapshot, '400');

      await registerUsdRate(
        rate: Decimal.parse('410'),
        effectiveAt: DateTime(2026, 2, 1),
      );

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      final confirmed = await repository.findById(id);

      expect(confirmed!.status, 'confirmed');
      expect(confirmed.exchangeRateToBaseSnapshot, '410');
    });

    test('no permite modificar detalles después de confirmar', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      final detailId = await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await expectLater(
        repository.addDetail(
          purchaseId: id,
          productId: 'product-1',
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );

      await expectLater(
        repository.updateDetail(
          purchaseId: id,
          detailId: detailId,
          productId: 'product-1',
          quantityMilliUnits: 2000,
          unitCostMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );

      await expectLater(
        repository.removeDetail(purchaseId: id, detailId: detailId),
        throwsA(isA<StateError>()),
      );
    });

    test('no permite editar la cabecera después de confirmar', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      final purchase = await repository.findById(id);

      await expectLater(
        repository.updateDraftHeader(
          purchaseId: id,
          supplierId: purchase!.supplierId,
          purchaseDate: purchaseDate,
          currencyCode: 'CUP',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('no permite recalcular una compra confirmada', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await expectLater(
        repository.recalculateDraft(id),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza confirmar dos veces la misma compra', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await expectLater(
        repository.confirmPurchase(id),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('PurchaseRepository - anulación y eliminación', () {
    test('anula una compra confirmada y conserva el motivo', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await repository.cancelPurchase(
        purchaseId: id,
        reason: 'Error en el documento',
      );

      final purchase = await repository.findById(id);

      expect(purchase!.status, 'cancelled');
      expect(purchase.cancelledAt, isNotNull);
      expect(purchase.cancellationReason, 'Error en el documento');
    });

    test('normaliza el motivo de anulación', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await repository.cancelPurchase(
        purchaseId: id,
        reason: '  Error administrativo  ',
      );

      final purchase = await repository.findById(id);

      expect(purchase!.cancellationReason, 'Error administrativo');
    });

    test('rechaza un motivo de anulación vacío', () async {
      await expectLater(
        repository.cancelPurchase(purchaseId: 'cualquier-id', reason: '   '),
        throwsArgumentError,
      );
    });

    test('no permite anular una compra inexistente', () async {
      await expectLater(
        repository.cancelPurchase(
          purchaseId: 'compra-inexistente',
          reason: 'Motivo de prueba',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('no permite anular una compra en borrador', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await expectLater(
        repository.cancelPurchase(purchaseId: id, reason: 'Motivo de prueba'),
        throwsA(isA<StateError>()),
      );
    });

    test('no permite anular una compra que ya fue anulada', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await repository.cancelPurchase(
        purchaseId: id,
        reason: 'Primera anulación',
      );

      await expectLater(
        repository.cancelPurchase(purchaseId: id, reason: 'Segunda anulación'),
        throwsA(isA<StateError>()),
      );
    });

    test('elimina un borrador y sus detalles', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.deleteDraft(id);

      expect(await repository.findById(id), isNull);
      expect(await repository.getDetails(id), isEmpty);
    });

    test('no permite eliminar una compra confirmada', () async {
      await insertBaseCurrency();

      final id = await createPurchase();

      await createProduct();

      await repository.addDetail(
        purchaseId: id,
        productId: 'product-1',
        quantityMilliUnits: 1000,
        unitCostMinorUnits: 1000,
      );

      await repository.confirmPurchase(id);

      await expectLater(repository.deleteDraft(id), throwsA(isA<StateError>()));

      expect(await repository.findById(id), isNotNull);
    });

    test('no permite eliminar una compra inexistente', () async {
      await expectLater(
        repository.deleteDraft('compra-inexistente'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
