import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/sales/data/sales_repository.dart';
import 'package:gestion_comercial/features/sales/domain/sale_payment_service.dart';

void main() {
  late AppDatabase db;
  late SalesRepository repository;
  final date = DateTime(2026, 1, 15);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SalesRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> seedBaseCurrency() async {
    await db
        .into(db.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'CUP',
            name: 'Peso cubano',
            symbol: 'CUP',
            isBase: const Value(true),
          ),
        );
  }

  Future<void> seedForeignCurrency() async {
    await db
        .into(db.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'USD',
            name: 'Dólar estadounidense',
            symbol: 'USD',
          ),
        );
  }

  Future<void> seedExchangeRate({
    required String currencyCode,
    required String rate,
    required DateTime effectiveAt,
  }) async {
    await db
        .into(db.exchangeRates)
        .insert(
          ExchangeRatesCompanion.insert(
            id: 'rate-$currencyCode',
            currencyCode: currencyCode,
            rateToBase: rate,
            effectiveAt: effectiveAt,
          ),
        );
  }

  Future<String> seedCustomer() async {
    const id = 'customer-1';
    await db
        .into(db.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            customerType: 'individual',
            name: 'Cliente de prueba',
          ),
        );
    return id;
  }

  Future<String> seedProduct({bool trackInventory = true}) async {
    const id = 'product-1';
    await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            sku: 'SKU-001',
            name: 'Producto de prueba',
            trackInventory: Value(trackInventory),
          ),
        );
    return id;
  }

  Future<void> seedStock(String productId, int quantity) async {
    await db
        .into(db.inventoryMovements)
        .insert(
          InventoryMovementsCompanion.insert(
            id: 'opening-stock',
            productId: productId,
            movementType: 'entry',
            quantityMilliUnits: quantity,
            reason: 'Existencia inicial',
          ),
        );
  }

  Future<String> draft({
    String? customerId,
    SalePaymentType type = SalePaymentType.credit,
  }) async {
    return repository.createDraft(
      customerId: customerId,
      saleDate: date,
      currencyCode: 'CUP',
      paymentType: type,
    );
  }

  group('SalesRepository - borradores y detalles', () {
    test('rechaza crédito sin cliente registrado', () async {
      await seedBaseCurrency();
      await expectLater(draft(), throwsArgumentError);
    });

    test('permite venta de contado sin cliente', () async {
      await seedBaseCurrency();
      final id = await draft(type: SalePaymentType.cash);
      expect((await repository.findById(id))!.customerId, isNull);
    });

    test(
      'crea borrador y recalcula los importes al agregar una línea',
      () async {
        await seedBaseCurrency();
        final productId = await seedProduct(trackInventory: false);
        final saleId = await draft(customerId: await seedCustomer());
        await repository.addDetail(
          saleId: saleId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitPriceMinorUnits: 5000,
        );
        final sale = await repository.findById(saleId);
        expect(sale!.subtotalMinorUnits, 10000);
        expect(sale.totalMinorUnits, 10000);
        expect(await repository.getDetails(saleId), hasLength(1));
      },
    );

    test('eliminar la última línea devuelve los importes a cero', () async {
      await seedBaseCurrency();
      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());
      final detailId = await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 1000,
      );
      await repository.removeDetail(saleId: saleId, detailId: detailId);
      final sale = await repository.findById(saleId);
      expect(sale!.totalMinorUnits, 0);
    });
  });

  group('SalesRepository - confirmación e inventario', () {
    test(
      'confirma contado, registra pago total y descuenta inventario',
      () async {
        await seedBaseCurrency();
        final productId = await seedProduct();
        await seedStock(productId, 5000);
        final saleId = await draft(type: SalePaymentType.cash);
        await repository.addDetail(
          saleId: saleId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitPriceMinorUnits: 3000,
        );
        await repository.confirmSale(
          saleId: saleId,
          initialPaymentMinorUnits: 6000,
        );
        final sale = await repository.findById(saleId);
        final balance = await (db.select(
          db.inventoryBalances,
        )..where((r) => r.productId.equals(productId))).getSingle();
        expect(sale!.status, 'confirmed');
        expect(await repository.getPaidAmount(saleId), 6000);
        expect(await repository.getOutstandingBalance(saleId), 0);
        expect(balance.quantityMilliUnits, 3000);
      },
    );

    test(
      'revierte toda la confirmación si no hay existencias suficientes',
      () async {
        await seedBaseCurrency();
        final productId = await seedProduct();
        await seedStock(productId, 1000);
        final saleId = await draft(type: SalePaymentType.cash);
        await repository.addDetail(
          saleId: saleId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitPriceMinorUnits: 3000,
        );
        await expectLater(
          repository.confirmSale(
            saleId: saleId,
            initialPaymentMinorUnits: 6000,
          ),
          throwsA(anything),
        );
        expect((await repository.findById(saleId))!.status, 'draft');
        expect(await repository.getDetails(saleId), hasLength(1));
        expect(await repository.getPayments(saleId), isEmpty);
      },
    );

    test('no confirma contado si no se paga el total', () async {
      await seedBaseCurrency();
      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(type: SalePaymentType.cash);
      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 5000,
      );
      await expectLater(
        repository.confirmSale(saleId: saleId, initialPaymentMinorUnits: 1000),
        throwsArgumentError,
      );
      expect((await repository.findById(saleId))!.status, 'draft');
    });

    test('no permite confirmar venta sin detalles', () async {
      await seedBaseCurrency();
      final saleId = await draft(customerId: await seedCustomer());
      await expectLater(
        repository.confirmSale(saleId: saleId),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SalesRepository - pagos a crédito', () {
    test('registra pago inicial parcial y abono posterior', () async {
      await seedBaseCurrency();
      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());
      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 10000,
      );
      await repository.confirmSale(
        saleId: saleId,
        initialPaymentMinorUnits: 2500,
      );
      expect(await repository.getOutstandingBalance(saleId), 7500);
      await repository.registerPayment(
        saleId: saleId,
        amountMinorUnits: 2500,
        currencyCode: 'CUP',
        paymentDate: date.add(const Duration(days: 5)),
        paymentMethod: 'cash',
      );
      final summary = await repository.getPaymentSummary(saleId);
      expect(summary.paidMinorUnits, 5000);
      expect(summary.balanceMinorUnits, 5000);
      expect(summary.status, SalePaymentStatus.partial);
    });

    test('convierte un abono en moneda extranjera y guarda su tasa', () async {
      await seedBaseCurrency();
      await seedForeignCurrency();

      await seedExchangeRate(
        currencyCode: 'USD',
        rate: '25',
        effectiveAt: date,
      );

      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());

      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 10000,
      );

      await repository.confirmSale(saleId: saleId);

      await repository.registerPayment(
        saleId: saleId,
        amountMinorUnits: 200,
        currencyCode: 'USD',
        paymentDate: date.add(const Duration(days: 5)),
        paymentMethod: 'cash',
      );

      final payments = await repository.getPayments(saleId);

      expect(payments, hasLength(1));
      expect(payments.single.amountMinorUnits, 200);
      expect(payments.single.currencyCode, 'USD');
      expect(payments.single.exchangeRateToBaseSnapshot, '25');
      expect(payments.single.appliedAmountMinorUnits, 5000);

      final summary = await repository.getPaymentSummary(saleId);

      expect(summary.paidMinorUnits, 5000);
      expect(summary.balanceMinorUnits, 5000);
    });

    test('rechaza pago extranjero si no existe tasa histórica', () async {
      await seedBaseCurrency();
      await seedForeignCurrency();

      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());

      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 10000,
      );

      await repository.confirmSale(saleId: saleId);

      await expectLater(
        repository.registerPayment(
          saleId: saleId,
          amountMinorUnits: 200,
          currencyCode: 'USD',
          paymentDate: date.add(const Duration(days: 5)),
          paymentMethod: 'cash',
        ),
        throwsA(isA<StateError>()),
      );

      expect(await repository.getPayments(saleId), isEmpty);
      expect(await repository.getOutstandingBalance(saleId), 10000);
    });

    test('rechaza abono que supera el saldo pendiente', () async {
      await seedBaseCurrency();
      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());
      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 1000,
      );
      await repository.confirmSale(saleId: saleId);
      await expectLater(
        repository.registerPayment(
          saleId: saleId,
          amountMinorUnits: 1001,
          currencyCode: 'CUP',
          paymentDate: date,
          paymentMethod: 'cash',
        ),
        throwsArgumentError,
      );
      expect(await repository.getPayments(saleId), isEmpty);
    });

    test('no permite modificar detalles después de confirmar', () async {
      await seedBaseCurrency();
      final productId = await seedProduct(trackInventory: false);
      final saleId = await draft(customerId: await seedCustomer());
      await repository.addDetail(
        saleId: saleId,
        productId: productId,
        quantityMilliUnits: 1000,
        unitPriceMinorUnits: 1000,
      );
      await repository.confirmSale(saleId: saleId);
      await expectLater(
        repository.addDetail(
          saleId: saleId,
          productId: productId,
          quantityMilliUnits: 1000,
          unitPriceMinorUnits: 1000,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SalesRepository - cancelación', () {
    test(
      'cancela venta, repone inventario y conserva pagos históricos',
      () async {
        await seedBaseCurrency();

        final productId = await seedProduct();
        await seedStock(productId, 5000);

        final saleId = await draft(customerId: await seedCustomer());

        await repository.addDetail(
          saleId: saleId,
          productId: productId,
          quantityMilliUnits: 2000,
          unitPriceMinorUnits: 10000,
        );

        await repository.confirmSale(
          saleId: saleId,
          initialPaymentMinorUnits: 2500,
        );

        final details = await repository.getDetails(saleId);
        final originalMovementId = details.single.inventoryMovementId!;

        await repository.cancelSale(
          saleId: saleId,
          reason: '  Cancelación solicitada por el cliente  ',
        );

        // La venta queda cancelada y conserva su motivo.
        final sale = await repository.findById(saleId);
        expect(sale!.status, 'cancelled');
        expect(sale.cancelledAt, isNotNull);
        expect(
          sale.cancellationReason,
          'Cancelación solicitada por el cliente',
        );

        // El inventario vuelve a su cantidad original.
        final balance = await (db.select(
          db.inventoryBalances,
        )..where((row) => row.productId.equals(productId))).getSingle();

        expect(balance.quantityMilliUnits, 5000);

        // Se conservan el movimiento original y su compensación.
        final movements = await (db.select(
          db.inventoryMovements,
        )..where((row) => row.productId.equals(productId))).get();

        expect(movements, hasLength(3));

        final original = movements.singleWhere(
          (row) => row.id == originalMovementId,
        );

        final correction = movements.singleWhere(
          (row) => row.correctionOfId == originalMovementId,
        );

        expect(original.movementType, 'exit');
        expect(correction.movementType, 'entry');
        expect(correction.quantityMilliUnits, 2000);
        expect(correction.reason, 'Cancelación solicitada por el cliente');

        // El pago histórico permanece intacto.
        final payments = await repository.getPayments(saleId);
        expect(payments, hasLength(1));
        expect(payments.single.amountMinorUnits, 2500);

        // Una venta cancelada no admite nuevos pagos.
        await expectLater(
          repository.registerPayment(
            saleId: saleId,
            amountMinorUnits: 1000,
            currencyCode: 'CUP',
            paymentDate: date,
            paymentMethod: 'cash',
          ),
          throwsA(isA<StateError>()),
        );

        // Tampoco permite una segunda cancelación.
        await expectLater(
          repository.cancelSale(saleId: saleId, reason: 'Segundo intento'),
          throwsA(isA<StateError>()),
        );

        expect(await repository.getPayments(saleId), hasLength(1));
      },
    );

    test(
      'revierte todas las compensaciones si falla una cancelación parcial',
      () async {
        await seedBaseCurrency();

        final firstProductId = await seedProduct();
        await seedStock(firstProductId, 5000);

        const secondProductId = 'product-2';

        await db
            .into(db.products)
            .insert(
              ProductsCompanion.insert(
                id: secondProductId,
                sku: 'SKU-002',
                name: 'Segundo producto de prueba',
                trackInventory: const Value(true),
              ),
            );

        await db
            .into(db.inventoryMovements)
            .insert(
              InventoryMovementsCompanion.insert(
                id: 'opening-stock-2',
                productId: secondProductId,
                movementType: 'entry',
                quantityMilliUnits: 5000,
                reason: 'Existencia inicial',
              ),
            );

        final saleId = await draft(customerId: await seedCustomer());

        await repository.addDetail(
          saleId: saleId,
          productId: firstProductId,
          quantityMilliUnits: 2000,
          unitPriceMinorUnits: 10000,
        );

        await repository.addDetail(
          saleId: saleId,
          productId: secondProductId,
          quantityMilliUnits: 1000,
          unitPriceMinorUnits: 15000,
        );

        await repository.confirmSale(saleId: saleId);

        final details = await repository.getDetails(saleId);
        expect(details, hasLength(2));

        // El último movimiento procesado provocará el error.
        final failingMovementId = details.last.inventoryMovementId!;

        final movementsBefore = await (db.select(db.inventoryMovements)).get();

        final firstBalanceBefore = await (db.select(
          db.inventoryBalances,
        )..where((row) => row.productId.equals(firstProductId))).getSingle();

        final secondBalanceBefore = await (db.select(
          db.inventoryBalances,
        )..where((row) => row.productId.equals(secondProductId))).getSingle();

        await db.customStatement('''
      CREATE TRIGGER fail_sale_cancellation_test
      BEFORE INSERT ON inventory_movements
      WHEN NEW.correction_of_id = '$failingMovementId'
      BEGIN
        SELECT RAISE(ABORT, 'Fallo controlado de cancelación');
      END
    ''');

        try {
          await expectLater(
            repository.cancelSale(
              saleId: saleId,
              reason: 'Cancelación de prueba',
            ),
            throwsA(isA<Exception>()),
          );
        } finally {
          await db.customStatement(
            'DROP TRIGGER IF EXISTS fail_sale_cancellation_test',
          );
        }

        // La venta debe seguir confirmada.
        final sale = await repository.findById(saleId);

        expect(sale!.status, 'confirmed');
        expect(sale.cancelledAt, isNull);
        expect(sale.cancellationReason, isNull);

        // No debe quedar ninguna compensación parcial.
        final movementsAfter = await (db.select(db.inventoryMovements)).get();

        expect(movementsAfter, hasLength(movementsBefore.length));

        expect(
          movementsAfter.where((row) => row.correctionOfId != null),
          isEmpty,
        );

        // Ninguno de los dos saldos debe haber cambiado.
        final firstBalanceAfter = await (db.select(
          db.inventoryBalances,
        )..where((row) => row.productId.equals(firstProductId))).getSingle();

        final secondBalanceAfter = await (db.select(
          db.inventoryBalances,
        )..where((row) => row.productId.equals(secondProductId))).getSingle();

        expect(
          firstBalanceAfter.quantityMilliUnits,
          firstBalanceBefore.quantityMilliUnits,
        );

        expect(
          secondBalanceAfter.quantityMilliUnits,
          secondBalanceBefore.quantityMilliUnits,
        );

        // No deben existir pagos nuevos.
        expect(await repository.getPayments(saleId), isEmpty);
      },
    );
  });
}
