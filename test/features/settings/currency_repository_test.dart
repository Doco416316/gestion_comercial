import 'package:decimal/decimal.dart';
//import 'package:drift/drift.dart' hide isNull, isNotNull;
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
}
