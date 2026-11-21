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
    int decimalDigits = 2,
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

    if (decimalDigits < 0 || decimalDigits > 4) {
      throw ArgumentError('La precisión decimal debe estar entre 0 y 4.');
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
            decimalDigits: Value(decimalDigits),
          ),
        );
  }

  Future<void> updateDetails({
    required String code,
    required String name,
    required String symbol,
    required int decimalDigits,
  }) async {
    final normalizedCode = _normalizeCode(code);
    final normalizedName = name.trim();
    final normalizedSymbol = symbol.trim();

    if (normalizedName.isEmpty || normalizedSymbol.isEmpty) {
      throw ArgumentError('El nombre y el símbolo son obligatorios.');
    }

    if (normalizedName.length > 60 || normalizedSymbol.length > 8) {
      throw ArgumentError('El nombre admite 60 caracteres y el símbolo 8.');
    }

    if (decimalDigits < 0 || decimalDigits > 4) {
      throw ArgumentError('La precisión decimal debe estar entre 0 y 4.');
    }

    await _database.transaction(() async {
      final currency = await findByCode(normalizedCode);

      if (currency == null) {
        throw StateError('La moneda indicada no existe.');
      }

      if (decimalDigits != currency.decimalDigits) {
        final hasHistory = await _hasFinancialHistory(normalizedCode);

        if (hasHistory) {
          throw StateError(
            'No se puede modificar la precisión decimal de esta moneda '
            'porque ya tiene operaciones o precios registrados.',
          );
        }
      }

      await (_database.update(
        _database.currencies,
      )..where((table) => table.code.equals(normalizedCode))).write(
        CurrenciesCompanion(
          name: Value(normalizedName),
          symbol: Value(normalizedSymbol),
          decimalDigits: Value(decimalDigits),
        ),
      );
    });
  }

  Future<bool> _hasFinancialHistory(String currencyCode) async {
    final productPrice =
        await (_database.select(_database.productPrices)
              ..where((table) => table.currencyCode.equals(currencyCode))
              ..limit(1))
            .getSingleOrNull();

    if (productPrice != null) return true;

    final purchase =
        await (_database.select(_database.purchases)
              ..where((table) => table.currencyCode.equals(currencyCode))
              ..limit(1))
            .getSingleOrNull();

    if (purchase != null) return true;

    final supplierPayment =
        await (_database.select(_database.supplierPayments)
              ..where((table) => table.currencyCode.equals(currencyCode))
              ..limit(1))
            .getSingleOrNull();

    if (supplierPayment != null) return true;

    final sale =
        await (_database.select(_database.sales)
              ..where((table) => table.currencyCode.equals(currencyCode))
              ..limit(1))
            .getSingleOrNull();

    if (sale != null) return true;

    final salePayment =
        await (_database.select(_database.salePayments)
              ..where((table) => table.currencyCode.equals(currencyCode))
              ..limit(1))
            .getSingleOrNull();

    return salePayment != null;
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

      final hasSales = await (_database.select(
        _database.sales,
      )..limit(1)).getSingleOrNull();

      final hasSalePayments = await (_database.select(
        _database.salePayments,
      )..limit(1)).getSingleOrNull();

      if (hasExchangeRates != null ||
          hasPurchases != null ||
          hasSupplierPayments != null ||
          hasSales != null ||
          hasSalePayments != null) {
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
