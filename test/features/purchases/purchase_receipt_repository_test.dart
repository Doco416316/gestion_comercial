import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_receipt_repository.dart';

import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository purchaseRepository;
  late PurchaseReceiptRepository receiptRepository;
  late SupplierRepository supplierRepository;

  final purchaseDate = DateTime(2026, 1, 15);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    purchaseRepository = PurchaseRepository(database);
    receiptRepository = PurchaseReceiptRepository(database);
    supplierRepository = SupplierRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertBaseCurrency() async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'CUP',
            name: 'Peso cubano',
            symbol: 'CUP',
            isBase: const Value(true),
          ),
        );
  }

  Future<String> createSupplier() {
    return supplierRepository.createSupplier(name: 'Proveedor de prueba');
  }

  Future<String> createProduct({
    required String id,
    bool trackInventory = true,
    bool isActive = true,
  }) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            sku: 'SKU-$id',
            name: 'Producto $id',
            trackInventory: Value(trackInventory),
            isActive: Value(isActive),
          ),
        );

    return id;
  }

  Future<String> createDraft() async {
    final supplierId = await createSupplier();

    return purchaseRepository.createDraft(
      supplierId: supplierId,
      purchaseDate: purchaseDate,
      currencyCode: 'CUP',
    );
  }

  Future<String> createConfirmedPurchase({
    required Map<String, int> productQuantities,
  }) async {
    final purchaseId = await createDraft();

    for (final entry in productQuantities.entries) {
      await purchaseRepository.addDetail(
        purchaseId: purchaseId,
        productId: entry.key,
        quantityMilliUnits: entry.value,
        unitCostMinorUnits: 1000,
      );
    }

    await purchaseRepository.confirmPurchase(purchaseId);

    return purchaseId;
  }

  Future<int> getStock(String productId) async {
    final balance = await (database.select(
      database.inventoryBalances,
    )..where((table) => table.productId.equals(productId))).getSingleOrNull();

    return balance?.quantityMilliUnits ?? 0;
  }

  Future<int> countReceipts() async {
    return (await database.select(database.purchaseReceipts).get()).length;
  }

  Future<int> countMovements() async {
    return (await database.select(database.inventoryMovements).get()).length;
  }

  group('PurchaseReceiptRepository - validaciones', () {
    test('rechaza un identificador de compra vacío', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: ' ',
          lines: const [
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: 1000,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rechaza una recepción sin líneas', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: 'purchase-1',
          lines: const [],
        ),
        throwsArgumentError,
      );
    });

    test('rechaza cantidades iguales a cero', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: 'purchase-1',
          lines: const [
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: 0,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rechaza cantidades negativas', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: 'purchase-1',
          lines: const [
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: -1000,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rechaza líneas duplicadas', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: 'purchase-1',
          lines: const [
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: 1000,
            ),
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: 500,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rechaza una compra inexistente', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: 'purchase-inexistente',
          lines: const [
            PurchaseReceiptLineInput(
              purchaseDetailId: 'detail-1',
              quantityMilliUnits: 1000,
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      expect(await countReceipts(), 0);
    });

    test('rechaza recibir una compra en borrador', () async {
      await insertBaseCurrency();

      final purchaseId = await createDraft();
      await createProduct(id: 'product-1');

      final detailId = await purchaseRepository.addDetail(
        purchaseId: purchaseId,
        productId: 'product-1',
        quantityMilliUnits: 2000,
        unitCostMinorUnits: 1000,
      );

      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: detailId,
              quantityMilliUnits: 1000,
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      expect(await countReceipts(), 0);
      expect(await countMovements(), 0);
    });
  });

  group('PurchaseReceiptRepository - recepciones', () {
    late String purchaseId;
    late String productId;
    late String purchaseDetailId;

    setUp(() async {
      await insertBaseCurrency();

      productId = await createProduct(id: 'product-1');

      purchaseId = await createConfirmedPurchase(
        productQuantities: {productId: 5000},
      );

      final details = await purchaseRepository.getDetails(purchaseId);
      purchaseDetailId = details.single.id;
    });

    test('registra una recepción completa', () async {
      final receiptId = await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 5000,
          ),
        ],
        reference: 'REC-001',
        notes: 'Entrega completa',
      );

      final receipts = await receiptRepository.getByPurchase(purchaseId);
      final receiptDetails = await receiptRepository.getReceiptDetails(
        receiptId,
      );

      expect(receipts.length, 1);
      expect(receipts.single.id, receiptId);
      expect(receipts.single.reference, 'REC-001');
      expect(receipts.single.notes, 'Entrega completa');

      expect(receiptDetails.length, 1);
      expect(receiptDetails.single.purchaseDetailId, purchaseDetailId);
      expect(receiptDetails.single.quantityMilliUnits, 5000);
      expect(receiptDetails.single.inventoryMovementId, isNotNull);

      expect(await getStock(productId), 5000);
      expect(await countMovements(), 1);
    });

    test('registra una recepción parcial', () async {
      final receiptId = await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 2000,
          ),
        ],
      );

      final details = await receiptRepository.getReceiptDetails(receiptId);
      final received = await receiptRepository.getReceivedQuantities(
        purchaseId,
      );

      expect(details.single.quantityMilliUnits, 2000);
      expect(received[purchaseDetailId], 2000);
      expect(await getStock(productId), 2000);
    });

    test('permite varias recepciones parciales', () async {
      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 2000,
          ),
        ],
      );

      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 1500,
          ),
        ],
      );

      final receipts = await receiptRepository.getByPurchase(purchaseId);
      final received = await receiptRepository.getReceivedQuantities(
        purchaseId,
      );

      expect(receipts.length, 2);
      expect(received[purchaseDetailId], 3500);
      expect(await getStock(productId), 3500);
      expect(await countMovements(), 2);
    });

    test('rechaza recibir más de la cantidad comprada', () async {
      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: purchaseDetailId,
              quantityMilliUnits: 5001,
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      expect(await countReceipts(), 0);
      expect(await countMovements(), 0);
      expect(await getStock(productId), 0);
    });

    test(
      'rechaza superar el saldo pendiente después de una recepción',
      () async {
        await receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: purchaseDetailId,
              quantityMilliUnits: 3000,
            ),
          ],
        );

        await expectLater(
          receiptRepository.createReceipt(
            purchaseId: purchaseId,
            lines: [
              PurchaseReceiptLineInput(
                purchaseDetailId: purchaseDetailId,
                quantityMilliUnits: 2001,
              ),
            ],
          ),
          throwsA(isA<StateError>()),
        );

        final received = await receiptRepository.getReceivedQuantities(
          purchaseId,
        );

        expect(received[purchaseDetailId], 3000);
        expect(await countReceipts(), 1);
        expect(await countMovements(), 1);
        expect(await getStock(productId), 3000);
      },
    );

    test('rechaza un detalle perteneciente a otra compra', () async {
      final otherPurchaseId = await createConfirmedPurchase(
        productQuantities: {productId: 1000},
      );

      final otherDetails = await purchaseRepository.getDetails(otherPurchaseId);

      await expectLater(
        receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: otherDetails.single.id,
              quantityMilliUnits: 500,
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      expect(await countReceipts(), 0);
      expect(await countMovements(), 0);
    });

    test(
      'registra movimiento entry y actualiza el saldo automáticamente',
      () async {
        await receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: purchaseDetailId,
              quantityMilliUnits: 2500,
            ),
          ],
        );

        final movements = await database
            .select(database.inventoryMovements)
            .get();

        expect(movements.length, 1);
        expect(movements.single.productId, productId);
        expect(movements.single.movementType, 'entry');
        expect(movements.single.quantityMilliUnits, 2500);
        expect(movements.single.correctionOfId, isNull);

        expect(await getStock(productId), 2500);
      },
    );

    test('normaliza referencia y notas vacías', () async {
      final receiptId = await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 1000,
          ),
        ],
        reference: '  ',
        notes: '   ',
      );

      final receipt = (await receiptRepository.getByPurchase(purchaseId))
          .single;

      expect(receipt.id, receiptId);
      expect(receipt.reference, isNull);
      expect(receipt.notes, isNull);
    });

    test('permite consultar las recepciones mediante stream', () async {
      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetailId,
            quantityMilliUnits: 1000,
          ),
        ],
      );

      final receipts = await receiptRepository
          .watchByPurchase(purchaseId)
          .first;

      expect(receipts.length, 1);
      expect(receipts.single.purchaseId, purchaseId);
    });
  });

  group('PurchaseReceiptRepository - productos sin inventario', () {
    test(
      'recibe productos que no controlan inventario sin movimiento',
      () async {
        await insertBaseCurrency();

        final productId = await createProduct(
          id: 'service-1',
          trackInventory: false,
        );

        final purchaseId = await createConfirmedPurchase(
          productQuantities: {productId: 3000},
        );

        final purchaseDetails = await purchaseRepository.getDetails(purchaseId);

        final receiptId = await receiptRepository.createReceipt(
          purchaseId: purchaseId,
          lines: [
            PurchaseReceiptLineInput(
              purchaseDetailId: purchaseDetails.single.id,
              quantityMilliUnits: 3000,
            ),
          ],
        );

        final details = await receiptRepository.getReceiptDetails(receiptId);

        expect(details.single.inventoryMovementId, isNull);
        expect(await countMovements(), 0);
        expect(await getStock(productId), 0);

        final received = await receiptRepository.getReceivedQuantities(
          purchaseId,
        );

        expect(received[purchaseDetails.single.id], 3000);
      },
    );

    test(
      'rechaza recibir un producto inactivo que controla inventario',
      () async {
        await insertBaseCurrency();

        final productId = await createProduct(id: 'inactive-1');

        final purchaseId = await createConfirmedPurchase(
          productQuantities: {productId: 2000},
        );

        final purchaseDetails = await purchaseRepository.getDetails(purchaseId);

        await (database.update(database.products)
              ..where((table) => table.id.equals(productId)))
            .write(const ProductsCompanion(isActive: Value(false)));

        await expectLater(
          receiptRepository.createReceipt(
            purchaseId: purchaseId,
            lines: [
              PurchaseReceiptLineInput(
                purchaseDetailId: purchaseDetails.single.id,
                quantityMilliUnits: 1000,
              ),
            ],
          ),
          throwsA(isA<StateError>()),
        );

        expect(await countReceipts(), 0);
        expect(await countMovements(), 0);
        expect(await getStock(productId), 0);
      },
    );
  });

  group('PurchaseReceiptRepository - inmutabilidad', () {
    test('no permite modificar un detalle de recepción', () async {
      await insertBaseCurrency();

      final productId = await createProduct(id: 'immutable-1');

      final purchaseId = await createConfirmedPurchase(
        productQuantities: {productId: 2000},
      );

      final purchaseDetails = await purchaseRepository.getDetails(purchaseId);

      final receiptId = await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetails.single.id,
            quantityMilliUnits: 1000,
          ),
        ],
      );

      final receiptDetails = await receiptRepository.getReceiptDetails(
        receiptId,
      );

      await expectLater(
        (database.update(
          database.purchaseReceiptDetails,
        )..where((table) => table.id.equals(receiptDetails.single.id))).write(
          const PurchaseReceiptDetailsCompanion(
            quantityMilliUnits: Value(1500),
          ),
        ),
        throwsA(isA<Exception>()),
      );

      final unchanged = await receiptRepository.getReceiptDetails(receiptId);

      expect(unchanged.single.quantityMilliUnits, 1000);
      expect(await getStock(productId), 1000);
    });

    test('no permite eliminar un detalle de recepción', () async {
      await insertBaseCurrency();

      final productId = await createProduct(id: 'immutable-2');

      final purchaseId = await createConfirmedPurchase(
        productQuantities: {productId: 2000},
      );

      final purchaseDetails = await purchaseRepository.getDetails(purchaseId);

      final receiptId = await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: purchaseDetails.single.id,
            quantityMilliUnits: 1000,
          ),
        ],
      );

      final receiptDetails = await receiptRepository.getReceiptDetails(
        receiptId,
      );

      await expectLater(
        (database.delete(
          database.purchaseReceiptDetails,
        )..where((table) => table.id.equals(receiptDetails.single.id))).go(),
        throwsA(isA<Exception>()),
      );

      expect(
        await receiptRepository.getReceiptDetails(receiptId),
        hasLength(1),
      );

      expect(await getStock(productId), 1000);
    });
  });

  group('PurchaseReceiptRepository - atomicidad', () {
    test(
      'no deja registros si una línea de la recepción es inválida',
      () async {
        await insertBaseCurrency();

        final validProductId = await createProduct(id: 'valid-product');

        final inactiveProductId = await createProduct(
          id: 'inactive-product',
          isActive: false,
        );

        // La compra se crea y confirma antes de desactivar el producto.
        // Para poder confirmar la compra, se utiliza inicialmente activo.
        await (database.update(database.products)
              ..where((table) => table.id.equals(inactiveProductId)))
            .write(const ProductsCompanion(isActive: Value(true)));

        final purchaseId = await createConfirmedPurchase(
          productQuantities: {validProductId: 1000, inactiveProductId: 1000},
        );

        final details = await purchaseRepository.getDetails(purchaseId);

        await (database.update(database.products)
              ..where((table) => table.id.equals(inactiveProductId)))
            .write(const ProductsCompanion(isActive: Value(false)));

        await expectLater(
          receiptRepository.createReceipt(
            purchaseId: purchaseId,
            lines: [
              PurchaseReceiptLineInput(
                purchaseDetailId: details
                    .firstWhere((detail) => detail.productId == validProductId)
                    .id,
                quantityMilliUnits: 1000,
              ),
              PurchaseReceiptLineInput(
                purchaseDetailId: details
                    .firstWhere(
                      (detail) => detail.productId == inactiveProductId,
                    )
                    .id,
                quantityMilliUnits: 1000,
              ),
            ],
          ),
          throwsA(isA<StateError>()),
        );

        // La validación de todas las líneas ocurre antes de insertar
        // la cabecera, los movimientos y los detalles.
        expect(await countReceipts(), 0);
        expect(await countMovements(), 0);
        expect(await getStock(validProductId), 0);
        expect(await getStock(inactiveProductId), 0);
      },
    );
  });
}
