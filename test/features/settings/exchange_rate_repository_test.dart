import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/settings/data/exchange_rate_repository.dart';

void main() {
  late AppDatabase database;
  late ExchangeRateRepository repository;

  final date1 = DateTime(2026, 1, 1);
  final date2 = DateTime(2026, 2, 1);
  final date3 = DateTime(2026, 3, 1);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ExchangeRateRepository(database);
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

  Future<void> insertUsd() async {
    await insertCurrency(code: 'CUP', isBase: true);
    await insertCurrency(code: 'USD');
  }

  group('ExchangeRateRepository', () {
    test('registra una tasa correctamente', () async {
      await insertUsd();

      final id = await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date1,
      );

      final rate = await repository.findById(id);

      expect(rate, isNotNull);
      expect(rate!.currencyCode, 'USD');
      expect(rate.rateToBase, '400');
      expect(rate.effectiveAt, date1);
    });

    test('normaliza el código de moneda', () async {
      await insertUsd();

      final id = await repository.registerRate(
        currencyCode: ' usd ',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date1,
      );

      final rate = await repository.findById(id);

      expect(rate!.currencyCode, 'USD');
    });

    test('rechaza un código de moneda inválido', () async {
      await insertUsd();

      expect(
        () => repository.registerRate(
          currencyCode: 'US',
          rateToBase: Decimal.parse('400'),
          effectiveAt: date1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza tasas iguales a cero', () async {
      await insertUsd();

      expect(
        () => repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.zero,
          effectiveAt: date1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza tasas negativas', () async {
      await insertUsd();

      expect(
        () => repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('-10'),
          effectiveAt: date1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza monedas inexistentes', () async {
      await insertCurrency(code: 'CUP', isBase: true);

      expect(
        () => repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('400'),
          effectiveAt: date1,
        ),
        throwsStateError,
      );
    });

    test('rechaza monedas inactivas', () async {
      await insertCurrency(code: 'CUP', isBase: true);
      await insertCurrency(code: 'USD', isActive: false);

      expect(
        () => repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('400'),
          effectiveAt: date1,
        ),
        throwsStateError,
      );
    });

    test('no permite registrar una tasa para la moneda base', () async {
      await insertCurrency(code: 'CUP', isBase: true);

      expect(
        () => repository.registerRate(
          currencyCode: 'CUP',
          rateToBase: Decimal.one,
          effectiveAt: date1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza dos tasas con la misma fecha efectiva', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date1,
      );

      expect(
        () => repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('410'),
          effectiveAt: date1,
        ),
        throwsStateError,
      );
    });

    test('permite varias tasas para fechas diferentes', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date1,
      );

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('410'),
        effectiveAt: date2,
      );

      final rates = await repository.watchRates('USD').first;

      expect(rates.length, 2);
    });

    test('permite registrar tasas retroactivas y futuras', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('390'),
        effectiveAt: date1,
      );

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('420'),
        effectiveAt: date3,
      );

      final rates = await repository.watchRates('USD').first;

      expect(rates.length, 2);
    });

    test('obtiene la tasa más reciente aplicable a una fecha', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date1,
      );

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('410'),
        effectiveAt: date2,
      );

      final rate = await repository.findApplicableRate(
        currencyCode: 'USD',
        date: date3,
      );

      expect(rate, isNotNull);
      expect(rate!.rateToBase, '410');
    });

    test('no aplica una tasa antes de su fecha efectiva', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('400'),
        effectiveAt: date2,
      );

      final rate = await repository.findApplicableRate(
        currencyCode: 'USD',
        date: date1,
      );

      expect(rate, isNull);
    });

    test('obtiene una tasa retroactiva cuando corresponde', () async {
      await insertUsd();

      await repository.registerRate(
        currencyCode: 'USD',
        rateToBase: Decimal.parse('390'),
        effectiveAt: date1,
      );

      final value = await repository.getRateToBaseForDate(
        currencyCode: 'USD',
        date: date2,
      );

      expect(value, Decimal.parse('390'));
    });

    test('devuelve la tasa 1 para la moneda base', () async {
      await insertCurrency(code: 'CUP', isBase: true);

      final value = await repository.getRateToBaseForDate(
        currencyCode: 'CUP',
        date: date1,
      );

      expect(value, Decimal.one);
    });

    test('devuelve null si no existe una tasa aplicable', () async {
      await insertUsd();

      final value = await repository.getRateToBaseForDate(
        currencyCode: 'USD',
        date: date1,
      );

      expect(value, isNull);
    });

    test(
      'consulta las tasas ordenadas de más reciente a más antigua',
      () async {
        await insertUsd();

        await repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('400'),
          effectiveAt: date1,
        );

        await repository.registerRate(
          currencyCode: 'USD',
          rateToBase: Decimal.parse('410'),
          effectiveAt: date2,
        );

        final rates = await repository.watchRates('USD').first;

        expect(rates.first.effectiveAt, date2);
        expect(rates.last.effectiveAt, date1);
      },
    );
  });
}
