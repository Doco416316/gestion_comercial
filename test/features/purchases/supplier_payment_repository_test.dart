import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/data/supplier_payment_repository.dart';
import 'package:gestion_comercial/features/settings/data/exchange_rate_repository.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository purchaseRepository;
  late SupplierPaymentRepository paymentRepository;
  late SupplierRepository supplierRepository;
  late ExchangeRateRepository exchangeRateRepository;

  final purchaseDate = DateTime(2026, 1, 15);
  final rateDate = DateTime(2026, 1, 1);
  final paymentDate = DateTime(2026, 1, 20);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    purchaseRepository = PurchaseRepository(database);
    supplierRepository = SupplierRepository(database);
    exchangeRateRepository = ExchangeRateRepository(database);
    paymentRepository = SupplierPaymentRepository(
      database,
      exchangeRateRepository: exchangeRateRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCurrency({
    required String code,
    bool isBase = false,
    bool isActive = true,
    int decimalDigits = 2,
  }) async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: code,
            name: code,
            symbol: code,
            decimalDigits: Value(decimalDigits),
            isBase: Value(isBase),
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> insertBaseCurrency() {
    return insertCurrency(code: 'CUP', isBase: true);
  }

  Future<void> insertUsdCurrency({int decimalDigits = 2}) async {
    await insertBaseCurrency();
    await insertCurrency(code: 'USD', decimalDigits: decimalDigits);
  }

  Future<void> registerRate({
    required String currencyCode,
    required String rate,
    DateTime? effectiveAt,
  }) {
    return exchangeRateRepository.registerRate(
      currencyCode: currencyCode,
      rateToBase: Decimal.parse(rate),
      effectiveAt: effectiveAt ?? rateDate,
    );
  }

  Future<String> createProduct() async {
    const id = 'product-1';

    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            sku: 'SKU-001',
            name: 'Producto de prueba',
            unit: const Value('unidad'),
          ),
        );

    return id;
  }

  Future<String> createPurchase({
    String currencyCode = 'CUP',
    int totalMinorUnits = 10000,
    bool confirm = true,
  }) async {
    final supplierId = await supplierRepository.createSupplier(
      name: 'Proveedor de prueba',
    );

    final purchaseId = await purchaseRepository.createDraft(
      supplierId: supplierId,
      purchaseDate: purchaseDate,
      currencyCode: currencyCode,
    );

    final productId = await createProduct();

    await purchaseRepository.addDetail(
      purchaseId: purchaseId,
      productId: productId,
      quantityMilliUnits: 1000,
      unitCostMinorUnits: totalMinorUnits,
    );

    if (confirm) {
      await purchaseRepository.confirmPurchase(purchaseId);
    }

    return purchaseId;
  }

  Future<String> pay({
    required String purchaseId,
    required int amountMinorUnits,
    required String currencyCode,
    DateTime? date,
  }) {
    return paymentRepository.registerPayment(
      purchaseId: purchaseId,
      amountMinorUnits: amountMinorUnits,
      currencyCode: currencyCode,
      paymentDate: date ?? paymentDate,
      paymentMethod: 'cash',
    );
  }

  group('SupplierPaymentRepository - registro de pagos', () {
    test('registra correctamente un pago en la misma moneda', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      final paymentId = await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 2500,
        currencyCode: 'USD',
      );

      final payments = await paymentRepository.getByPurchase(purchaseId);

      expect(payments, hasLength(1));
      expect(payments.first.id, paymentId);
      expect(payments.first.amountMinorUnits, 2500);
      expect(payments.first.currencyCode, 'USD');
      expect(payments.first.appliedAmountMinorUnits, 2500);

      expect(await paymentRepository.getPaidAmount(purchaseId), 2500);
      expect(await paymentRepository.getOutstandingBalance(purchaseId), 7500);
    });

    test(
      'convierte correctamente un pago entre monedas de dos decimales',
      () async {
        await insertUsdCurrency();
        await insertCurrency(code: 'EUR');

        await registerRate(currencyCode: 'USD', rate: '400');
        await registerRate(currencyCode: 'EUR', rate: '440');

        final purchaseId = await createPurchase(currencyCode: 'USD');

        await pay(
          purchaseId: purchaseId,
          amountMinorUnits: 100,
          currencyCode: 'EUR',
        );

        final payments = await paymentRepository.getByPurchase(purchaseId);

        expect(payments, hasLength(1));
        expect(payments.first.amountMinorUnits, 100);
        expect(payments.first.currencyCode, 'EUR');
        expect(payments.first.appliedAmountMinorUnits, 110);
      },
    );

    test('convierte correctamente desde una moneda sin decimales', () async {
      await insertUsdCurrency();
      await insertCurrency(code: 'JPY', decimalDigits: 0);

      await registerRate(currencyCode: 'USD', rate: '400');
      await registerRate(currencyCode: 'JPY', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 1,
        currencyCode: 'JPY',
      );

      final payments = await paymentRepository.getByPurchase(purchaseId);

      expect(payments.first.appliedAmountMinorUnits, 100);
    });

    test(
      'convierte correctamente desde una moneda de tres decimales',
      () async {
        await insertUsdCurrency();
        await insertCurrency(code: 'KWD', decimalDigits: 3);

        await registerRate(currencyCode: 'USD', rate: '400');
        await registerRate(currencyCode: 'KWD', rate: '400');

        final purchaseId = await createPurchase(currencyCode: 'USD');

        await pay(
          purchaseId: purchaseId,
          amountMinorUnits: 1000,
          currencyCode: 'KWD',
        );

        final payments = await paymentRepository.getByPurchase(purchaseId);

        expect(payments.first.appliedAmountMinorUnits, 100);
      },
    );

    test('aplica redondeo HALF_UP al convertir importes', () async {
      await insertUsdCurrency();
      await insertCurrency(code: 'EUR');

      await registerRate(currencyCode: 'USD', rate: '2');
      await registerRate(currencyCode: 'EUR', rate: '3');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 1,
        currencyCode: 'EUR',
      );

      final payments = await paymentRepository.getByPurchase(purchaseId);

      // 1 * 3 / 2 = 1.5; HALF_UP produce 2.
      expect(payments.first.appliedAmountMinorUnits, 2);
    });

    test('conserva la tasa histórica del pago', () async {
      await insertUsdCurrency();
      await insertCurrency(code: 'EUR');

      await registerRate(currencyCode: 'USD', rate: '400');
      await registerRate(currencyCode: 'EUR', rate: '440');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 100,
        currencyCode: 'EUR',
      );

      await registerRate(
        currencyCode: 'EUR',
        rate: '500',
        effectiveAt: DateTime(2026, 2, 1),
      );

      final payments = await paymentRepository.getByPurchase(purchaseId);

      expect(payments.first.exchangeRateToBaseSnapshot, '440');
      expect(payments.first.appliedAmountMinorUnits, 110);
    });

    test('rechaza un pago que supera el saldo pendiente', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(
          purchaseId: purchaseId,
          amountMinorUnits: 10001,
          currencyCode: 'USD',
        ),
        throwsA(isA<StateError>()),
      );

      expect(await paymentRepository.getByPurchase(purchaseId), isEmpty);
      expect(await paymentRepository.getPaidAmount(purchaseId), 0);
    });

    test('rechaza pagos para compras que todavía son borradores', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(
        currencyCode: 'USD',
        confirm: false,
      );

      await expectLater(
        pay(purchaseId: purchaseId, amountMinorUnits: 100, currencyCode: 'USD'),
        throwsA(isA<StateError>()),
      );

      expect(await paymentRepository.getByPurchase(purchaseId), isEmpty);
    });

    test('rechaza pagos cuando no existe una tasa aplicable', () async {
      await insertUsdCurrency();
      await insertCurrency(code: 'EUR');

      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(purchaseId: purchaseId, amountMinorUnits: 100, currencyCode: 'EUR'),
        throwsA(isA<StateError>()),
      );

      expect(await paymentRepository.getByPurchase(purchaseId), isEmpty);
    });
  });

  group('SupplierPaymentRepository - validaciones', () {
    test('rechaza un importe igual a cero', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(purchaseId: purchaseId, amountMinorUnits: 0, currencyCode: 'USD'),
        throwsArgumentError,
      );
    });

    test('rechaza un importe negativo', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(
          purchaseId: purchaseId,
          amountMinorUnits: -100,
          currencyCode: 'USD',
        ),
        throwsArgumentError,
      );
    });

    test('rechaza una moneda de pago inexistente', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(purchaseId: purchaseId, amountMinorUnits: 100, currencyCode: 'EUR'),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza una moneda de pago inactiva', () async {
      await insertUsdCurrency();
      await insertCurrency(code: 'EUR', isActive: false);

      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await expectLater(
        pay(purchaseId: purchaseId, amountMinorUnits: 100, currencyCode: 'EUR'),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza una compra inexistente', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      await expectLater(
        pay(
          purchaseId: 'compra-inexistente',
          amountMinorUnits: 100,
          currencyCode: 'USD',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SupplierPaymentRepository - consultas', () {
    test('devuelve cero pagado y saldo completo inicialmente', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      expect(await paymentRepository.getPaidAmount(purchaseId), 0);
      expect(await paymentRepository.getOutstandingBalance(purchaseId), 10000);
      expect(await paymentRepository.getByPurchase(purchaseId), isEmpty);
    });

    test('actualiza correctamente el saldo después de varios pagos', () async {
      await insertUsdCurrency();
      await registerRate(currencyCode: 'USD', rate: '400');

      final purchaseId = await createPurchase(currencyCode: 'USD');

      await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 3000,
        currencyCode: 'USD',
      );

      await pay(
        purchaseId: purchaseId,
        amountMinorUnits: 2000,
        currencyCode: 'USD',
      );

      expect(await paymentRepository.getPaidAmount(purchaseId), 5000);
      expect(await paymentRepository.getOutstandingBalance(purchaseId), 5000);
      expect(await paymentRepository.getByPurchase(purchaseId), hasLength(2));
    });
  });
}
