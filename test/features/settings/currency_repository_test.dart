import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/settings/data/currency_repository.dart';
import 'package:gestion_comercial/features/settings/data/exchange_rate_repository.dart';

void main() {
  late AppDatabase database;
  late CurrencyRepository repository;
  late ExchangeRateRepository exchangeRateRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CurrencyRepository(database);
    exchangeRateRepository = ExchangeRateRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> createCurrencies() async {
    await repository.create(code: 'CUP', name: 'Peso cubano', symbol: 'CUP');

    await repository.create(
      code: 'USD',
      name: 'Dólar estadounidense',
      symbol: 'USD',
    );

    await repository.create(code: 'EUR', name: 'Euro', symbol: 'EUR');
  }

  test(
    'Bloquea el cambio de precisión cuando existen precios de productos',
    () async {
      await createCurrencies();

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              sku: 'P-001',
              name: 'Producto de prueba',
            ),
          );

      await database
          .into(database.productPrices)
          .insert(
            ProductPricesCompanion.insert(
              productId: 'product-1',
              currencyCode: 'USD',
              amountMinorUnits: 1500,
            ),
          );

      await expectLater(
        repository.updateDetails(
          code: 'USD',
          name: 'Dólar',
          symbol: r'$',
          decimalDigits: 0,
        ),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('Bloquea el cambio de precisión cuando existen compras', () async {
    await createCurrencies();

    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: 'supplier-1',
            name: 'Proveedor de prueba',
          ),
        );

    await database
        .into(database.purchases)
        .insert(
          PurchasesCompanion.insert(
            id: 'purchase-1',
            supplierId: 'supplier-1',
            purchaseDate: DateTime(2026, 1, 1),
            currencyCode: 'USD',
            exchangeRateToBaseSnapshot: '400',
            subtotalMinorUnits: 10000,
            totalMinorUnits: 10000,
          ),
        );

    await expectLater(
      repository.updateDetails(
        code: 'USD',
        name: 'Dólar',
        symbol: r'$',
        decimalDigits: 0,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Bloquea la precisión según la moneda del pago al proveedor', () async {
    await createCurrencies();

    final date = DateTime(2026, 1, 1);

    // Crear un producto para utilizarlo en el detalle de la compra.
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-1',
            sku: 'P-001',
            name: 'Producto de prueba',
          ),
        );

    // Crear la compra inicialmente como borrador.
    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: 'supplier-1',
            name: 'Proveedor de prueba',
          ),
        );

    await database
        .into(database.purchases)
        .insert(
          PurchasesCompanion.insert(
            id: 'purchase-1',
            supplierId: 'supplier-1',
            purchaseDate: date,
            currencyCode: 'CUP',
            exchangeRateToBaseSnapshot: '1',
            subtotalMinorUnits: 10000,
            totalMinorUnits: 10000,
          ),
        );

    // Agregar un detalle válido para poder confirmar la compra.
    await database
        .into(database.purchaseDetails)
        .insert(
          PurchaseDetailsCompanion.insert(
            id: 'purchase-detail-1',
            purchaseId: 'purchase-1',
            productId: 'product-1',
            skuSnapshot: 'P-001',
            productNameSnapshot: 'Producto de prueba',
            unitSnapshot: 'unit',
            quantityMilliUnits: 1000,
            unitCostMinorUnits: 10000,
            totalMinorUnits: 10000,
          ),
        );

    // Confirmar la compra después de agregar el detalle.
    await (database.update(
      database.purchases,
    )..where((table) => table.id.equals('purchase-1'))).write(
      PurchasesCompanion(
        status: const Value('confirmed'),
        confirmedAt: Value(date),
      ),
    );

    // Registrar un pago en USD, aunque la compra esté en CUP.
    await database
        .into(database.supplierPayments)
        .insert(
          SupplierPaymentsCompanion.insert(
            id: 'supplier-payment-1',
            purchaseId: 'purchase-1',
            amountMinorUnits: 500,
            currencyCode: 'USD',
            exchangeRateToBaseSnapshot: '400',
            appliedAmountMinorUnits: 500,
            paymentDate: DateTime(2026, 1, 2),
            paymentMethod: 'cash',
          ),
        );

    // La precisión de USD debe quedar bloqueada por el pago registrado.
    await expectLater(
      repository.updateDetails(
        code: 'USD',
        name: 'Dólar',
        symbol: r'$',
        decimalDigits: 0,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Bloquea el cambio de precisión cuando existen ventas', () async {
    await createCurrencies();

    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: 'sale-1',
            saleDate: DateTime(2026, 1, 1),
            currencyCode: 'USD',
            exchangeRateToBaseSnapshot: '400',
            subtotalMinorUnits: 10000,
            totalMinorUnits: 10000,
            paymentType: 'credit',
          ),
        );

    await expectLater(
      repository.updateDetails(
        code: 'USD',
        name: 'Dólar',
        symbol: r'$',
        decimalDigits: 0,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Bloquea la precisión según la moneda del pago recibido', () async {
    await createCurrencies();

    final date = DateTime(2026, 1, 1);

    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: 'sale-1',
            saleDate: date,
            currencyCode: 'CUP',
            exchangeRateToBaseSnapshot: '1',
            subtotalMinorUnits: 10000,
            totalMinorUnits: 10000,
            paymentType: 'credit',
            status: const Value('confirmed'),
            confirmedAt: Value(date),
          ),
        );

    await database
        .into(database.salePayments)
        .insert(
          SalePaymentsCompanion.insert(
            id: 'sale-payment-1',
            saleId: 'sale-1',
            amountMinorUnits: 500,
            currencyCode: 'USD',
            exchangeRateToBaseSnapshot: '400',
            appliedAmountMinorUnits: 500,
            paymentDate: date,
            paymentMethod: 'cash',
          ),
        );

    await expectLater(
      repository.updateDetails(
        code: 'USD',
        name: 'Dólar',
        symbol: r'$',
        decimalDigits: 0,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'Permite cambiar nombre y símbolo si la precisión permanece igual',
    () async {
      await createCurrencies();

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              sku: 'P-001',
              name: 'Producto de prueba',
            ),
          );

      await database
          .into(database.productPrices)
          .insert(
            ProductPricesCompanion.insert(
              productId: 'product-1',
              currencyCode: 'USD',
              amountMinorUnits: 1500,
            ),
          );

      await repository.updateDetails(
        code: 'USD',
        name: 'Dólar estadounidense',
        symbol: r'US$',
        decimalDigits: 2,
      );

      final currency = await repository.findByCode('USD');

      expect(currency!.name, 'Dólar estadounidense');
      expect(currency.symbol, r'US$');
      expect(currency.decimalDigits, 2);
    },
  );

  test('Registra una moneda correctamente', () async {
    await repository.create(code: 'CUP', name: 'Peso cubano', symbol: '\$');

    final currency = await repository.findByCode('CUP');

    expect(currency, isNotNull);
    expect(currency!.name, 'Peso cubano');
    expect(currency.symbol, '\$');
    expect(currency.isActive, isTrue);
    expect(currency.isBase, isFalse);
  });

  test('Normaliza el código de moneda', () async {
    await repository.create(
      code: ' usd ',
      name: 'Dólar estadounidense',
      symbol: '\$',
    );

    final currency = await repository.findByCode(' usd ');

    expect(currency, isNotNull);
    expect(currency!.code, 'USD');
  });

  test('Rechaza códigos de moneda incorrectos', () async {
    expect(
      () => repository.create(code: 'US', name: 'Dólar', symbol: '\$'),
      throwsArgumentError,
    );
  });

  test('Rechaza nombre o símbolo vacío', () async {
    expect(
      () => repository.create(code: 'USD', name: ' ', symbol: '\$'),
      throwsArgumentError,
    );

    expect(
      () => repository.create(code: 'USD', name: 'Dólar', symbol: ' '),
      throwsArgumentError,
    );
  });

  test('Permite establecer una única moneda base', () async {
    await createCurrencies();

    await repository.setBaseCurrency('CUP');
    await repository.setBaseCurrency('USD');

    final currencies = await repository.watchAll().first;
    final baseCurrencies = currencies.where((currency) => currency.isBase);

    expect(baseCurrencies.length, 1);
    expect(baseCurrencies.first.code, 'USD');
  });

  test('Permite cambiar la moneda base si no existe historial', () async {
    await createCurrencies();

    await repository.setBaseCurrency('CUP');
    await repository.setBaseCurrency('EUR');

    final cup = await repository.findByCode('CUP');
    final eur = await repository.findByCode('EUR');

    expect(cup!.isBase, isFalse);
    expect(eur!.isBase, isTrue);
  });

  test('No permite establecer como base una moneda inactiva', () async {
    await createCurrencies();

    await repository.setActive('EUR', false);

    expect(() => repository.setBaseCurrency('EUR'), throwsA(isA<StateError>()));

    final currency = await repository.findByCode('EUR');

    expect(currency!.isBase, isFalse);
  });

  test(
    'No permite cambiar la moneda base después de registrar una tasa',
    () async {
      await createCurrencies();
      await repository.setBaseCurrency('CUP');

      await exchangeRateRepository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: DateTime(2026, 1, 1),
      );

      await expectLater(
        repository.setBaseCurrency('EUR'),
        throwsA(isA<StateError>()),
      );

      final cup = await repository.findByCode('CUP');
      final eur = await repository.findByCode('EUR');

      expect(cup!.isBase, isTrue);
      expect(eur!.isBase, isFalse);
    },
  );

  test(
    'Permite conservar la misma moneda base aunque exista historial',
    () async {
      await createCurrencies();
      await repository.setBaseCurrency('CUP');

      await exchangeRateRepository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: DateTime(2026, 1, 1),
      );

      await repository.setBaseCurrency('CUP');

      final cup = await repository.findByCode('CUP');

      expect(cup!.isBase, isTrue);
    },
  );

  test(
    'No permite cambiar la moneda base después de registrar una compra',
    () async {
      await createCurrencies();
      await repository.setBaseCurrency('CUP');

      await database
          .into(database.suppliers)
          .insert(
            SuppliersCompanion.insert(
              id: 'supplier-1',
              name: 'Proveedor de prueba',
            ),
          );

      await database
          .into(database.purchases)
          .insert(
            PurchasesCompanion.insert(
              id: 'purchase-1',
              supplierId: 'supplier-1',
              purchaseDate: DateTime(2026, 1, 1),
              currencyCode: 'USD',
              exchangeRateToBaseSnapshot: '400',
              subtotalMinorUnits: 10000,
              totalMinorUnits: 10000,
            ),
          );

      await expectLater(
        repository.setBaseCurrency('EUR'),
        throwsA(isA<StateError>()),
      );

      final cup = await repository.findByCode('CUP');

      expect(cup!.isBase, isTrue);
    },
  );

  test(
    'No permite cambiar la moneda base después de registrar una venta',
    () async {
      await createCurrencies();
      await repository.setBaseCurrency('CUP');

      final date = DateTime(2026, 1, 1);

      await database
          .into(database.sales)
          .insert(
            SalesCompanion.insert(
              id: 'sale-base-1',
              saleDate: date,
              currencyCode: 'USD',
              exchangeRateToBaseSnapshot: '400',
              subtotalMinorUnits: 10000,
              totalMinorUnits: 10000,
              paymentType: 'credit',
            ),
          );

      await expectLater(
        repository.setBaseCurrency('EUR'),
        throwsA(isA<StateError>()),
      );

      final cup = await repository.findByCode('CUP');
      final eur = await repository.findByCode('EUR');

      expect(cup!.isBase, isTrue);
      expect(eur!.isBase, isFalse);
    },
  );

  test('No permite desactivar la moneda base', () async {
    await createCurrencies();
    await repository.setBaseCurrency('CUP');

    await expectLater(
      repository.setActive('CUP', false),
      throwsA(isA<StateError>()),
    );

    final cup = await repository.findByCode('CUP');

    expect(cup!.isActive, isTrue);
  });

  test('No permite desactivar una moneda inexistente', () async {
    await expectLater(
      repository.setActive('USD', false),
      throwsA(isA<StateError>()),
    );
  });

  test('No permite modificar directamente una tasa histórica', () async {
    await createCurrencies();
    await repository.setBaseCurrency('CUP');

    await exchangeRateRepository.registerRate(
      currencyCode: 'USD',
      rateToBase: Decimal.parse('400'),
      effectiveAt: DateTime(2026, 1, 1),
    );

    await expectLater(
      database.customStatement(
        "UPDATE exchange_rates SET rate_to_base = '500'",
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('No permite eliminar directamente una tasa histórica', () async {
    await createCurrencies();
    await repository.setBaseCurrency('CUP');

    await exchangeRateRepository.registerRate(
      currencyCode: 'USD',
      rateToBase: Decimal.parse('400'),
      effectiveAt: DateTime(2026, 1, 1),
    );

    await expectLater(
      database.customStatement(
        "DELETE FROM exchange_rates WHERE currency_code = 'USD'",
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('Permite registrar la precisión decimal de una moneda', () async {
    await repository.create(
      code: 'JPY',
      name: 'Yen japonés',
      symbol: '¥',
      decimalDigits: 0,
    );

    final currency = await repository.findByCode('JPY');
    expect(currency!.decimalDigits, 0);
  });

  test(
    'Permite actualizar nombre, símbolo y precisión de una moneda',
    () async {
      await repository.create(code: 'USD', name: 'Dólar', symbol: r'$');

      await repository.updateDetails(
        code: 'USD',
        name: 'Dólar estadounidense',
        symbol: r'US$',
        decimalDigits: 2,
      );

      final currency = await repository.findByCode('USD');
      expect(currency!.name, 'Dólar estadounidense');
      expect(currency.symbol, r'US$');
      expect(currency.decimalDigits, 2);
    },
  );
}
