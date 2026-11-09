import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class CurrencyRepository {
  CurrencyRepository(this._database);

  final AppDatabase _database;

  Stream<List<Currency>> watchAll() {
    return (_database.select(
      _database.currencies,
    )..orderBy([(table) => OrderingTerm.asc(table.code)])).watch();
  }

  Future<Currency?> findByCode(String code) {
    return (_database.select(_database.currencies)
          ..where((table) => table.code.equals(_normalizeCode(code))))
        .getSingleOrNull();
  }

  String _normalizeCode(String code) {
    return code.trim().toUpperCase();
  }

  Future<void> create({
    required String code,
    required String name,
    required String symbol,
  }) async {
    final normalizedCode = _normalizeCode(code);
    final normalizedName = name.trim();
    final normalizedSymbol = symbol.trim();

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCode)) {
      throw ArgumentError('El código debe contener tres letras.');
    }

    if (normalizedName.isEmpty || normalizedSymbol.isEmpty) {
      throw ArgumentError('El nombre y el símbolo son obligatorios.');
    }

    if (normalizedName.length > 60 || normalizedSymbol.length > 8) {
      throw ArgumentError(
        'El nombre no puede superar 60 caracteres '
        'y el símbolo no puede superar 8.',
      );
    }

    await _database
        .into(_database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: normalizedCode,
            name: normalizedName,
            symbol: normalizedSymbol,
          ),
        );
  }

  Future<void> setActive(String code, bool active) async {
    final normalizedCode = _normalizeCode(code);

    await _database.transaction(() async {
      final currency = await findByCode(normalizedCode);

      if (currency == null) {
        throw StateError('La moneda indicada no existe.');
      }

      if (!active && currency.isBase) {
        throw StateError('No se puede desactivar la moneda base.');
      }

      await (_database.update(_database.currencies)
            ..where((table) => table.code.equals(normalizedCode)))
          .write(CurrenciesCompanion(isActive: Value(active)));
    });
  }

  Future<void> setBaseCurrency(String code) async {
    final normalizedCode = _normalizeCode(code);

    await _database.transaction(() async {
      final currency = await findByCode(normalizedCode);

      if (currency == null || !currency.isActive) {
        throw StateError('La moneda base debe existir y estar activa.');
      }

      // Si ya es la moneda base, no hay nada que cambiar.
      if (currency.isBase) {
        return;
      }

      // Una vez que existe historial financiero, la moneda base
      // no puede cambiarse porque alteraría el significado de
      // todas las tasas históricas.
      final hasExchangeRates = await (_database.select(
        _database.exchangeRates,
      )..limit(1)).getSingleOrNull();

      final hasPurchases = await (_database.select(
        _database.purchases,
      )..limit(1)).getSingleOrNull();

      final hasSupplierPayments = await (_database.select(
        _database.supplierPayments,
      )..limit(1)).getSingleOrNull();

      if (hasExchangeRates != null ||
          hasPurchases != null ||
          hasSupplierPayments != null) {
        throw StateError(
          'No se puede cambiar la moneda base porque ya existe '
          'historial financiero.',
        );
      }

      await _database
          .update(_database.currencies)
          .write(const CurrenciesCompanion(isBase: Value(false)));

      await (_database.update(_database.currencies)
            ..where((table) => table.code.equals(normalizedCode)))
          .write(const CurrenciesCompanion(isBase: Value(true)));
    });
  }
}
