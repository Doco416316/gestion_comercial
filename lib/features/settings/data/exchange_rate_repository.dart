import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class ExchangeRateRepository {
  ExchangeRateRepository(this._database);

  final AppDatabase _database;

  static const Uuid _uuid = Uuid();

  String _normalizeCurrencyCode(String code) {
    return code.trim().toUpperCase();
  }

  Future<String> registerRate({
    required String currencyCode,
    required Decimal rateToBase,
    required DateTime effectiveAt,
  }) async {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCode)) {
      throw ArgumentError('El código de moneda no es válido.');
    }

    if (rateToBase <= Decimal.zero) {
      throw ArgumentError('La tasa de cambio debe ser mayor que cero.');
    }

    return _database.transaction(() async {
      final currency = await (_database.select(
        _database.currencies,
      )..where((table) => table.code.equals(normalizedCode))).getSingleOrNull();

      if (currency == null) {
        throw StateError('La moneda indicada no existe.');
      }

      if (!currency.isActive) {
        throw StateError(
          'No se pueden registrar tasas para una moneda inactiva.',
        );
      }

      if (currency.isBase) {
        throw ArgumentError(
          'La moneda base tiene una tasa fija de 1 y no necesita registros.',
        );
      }

      final existingRate =
          await (_database.select(_database.exchangeRates)..where(
                (table) =>
                    table.currencyCode.equals(normalizedCode) &
                    table.effectiveAt.equals(effectiveAt),
              ))
              .getSingleOrNull();

      if (existingRate != null) {
        throw StateError(
          'Ya existe una tasa para esta moneda en la fecha indicada.',
        );
      }

      final id = _uuid.v4();

      await _database
          .into(_database.exchangeRates)
          .insert(
            ExchangeRatesCompanion.insert(
              id: id,
              currencyCode: normalizedCode,
              rateToBase: rateToBase.toString(),
              effectiveAt: effectiveAt,
            ),
          );

      return id;
    });
  }

  Stream<List<ExchangeRate>> watchRates(String currencyCode) {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);

    final query = _database.select(_database.exchangeRates)
      ..where((table) => table.currencyCode.equals(normalizedCode))
      ..orderBy([(table) => OrderingTerm.desc(table.effectiveAt)]);

    return query.watch();
  }

  Future<ExchangeRate?> findById(String id) {
    return (_database.select(
      _database.exchangeRates,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<ExchangeRate?> findApplicableRate({
    required String currencyCode,
    required DateTime date,
  }) {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);

    final query = _database.select(_database.exchangeRates)
      ..where(
        (table) =>
            table.currencyCode.equals(normalizedCode) &
            table.effectiveAt.isSmallerOrEqualValue(date),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.effectiveAt)])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<Decimal?> getRateToBaseForDate({
    required String currencyCode,
    required DateTime date,
  }) async {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);

    final currency = await (_database.select(
      _database.currencies,
    )..where((table) => table.code.equals(normalizedCode))).getSingleOrNull();

    if (currency == null) {
      return null;
    }

    if (currency.isBase) {
      return Decimal.one;
    }

    final applicableRate = await findApplicableRate(
      currencyCode: normalizedCode,
      date: date,
    );

    if (applicableRate == null) {
      return null;
    }

    return Decimal.parse(applicableRate.rateToBase);
  }
}
