import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class ProductRepository {
  ProductRepository(this._database);

  final AppDatabase _database;
  static const Uuid _uuid = Uuid();

  String _normalizeSku(String sku) {
    return sku.trim().toUpperCase();
  }

  String? _normalizeOptionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Future<void> _ensureSkuAvailable(
    String sku, {
    String? excludingProductId,
  }) async {
    final existing = await findBySku(sku);

    if (existing != null && existing.id != excludingProductId) {
      throw StateError('Ya existe un producto con el código SKU $sku.');
    }
  }

  Future<String> createProduct({
    required String sku,
    required String name,
    String? description,
    String? category,
    String unit = 'unidad',
    bool trackInventory = true,
  }) async {
    final normalizedSku = _normalizeSku(sku);
    final normalizedName = name.trim();
    final normalizedUnit = unit.trim();

    if (normalizedSku.isEmpty || normalizedName.isEmpty) {
      throw ArgumentError('El código y el nombre son obligatorios.');
    }

    if (normalizedUnit.isEmpty) {
      throw ArgumentError('La unidad de medida es obligatoria.');
    }

    final id = _uuid.v4();

    await _database.transaction(() async {
      await _ensureSkuAvailable(normalizedSku);

      await _database
          .into(_database.products)
          .insert(
            ProductsCompanion.insert(
              id: id,
              sku: normalizedSku,
              name: normalizedName,
              description: Value(_normalizeOptionalText(description)),
              category: Value(_normalizeOptionalText(category)),
              unit: Value(normalizedUnit),
              trackInventory: Value(trackInventory),
            ),
          );
    });

    return id;
  }

  Future<void> updateProduct({
    required String id,
    required String sku,
    required String name,
    required String? description,
    required String? category,
    required String unit,
    required bool trackInventory,
  }) async {
    final normalizedSku = _normalizeSku(sku);
    final normalizedName = name.trim();
    final normalizedUnit = unit.trim();

    if (normalizedSku.isEmpty || normalizedName.isEmpty) {
      throw ArgumentError('El código y el nombre son obligatorios.');
    }

    if (normalizedUnit.isEmpty) {
      throw ArgumentError('La unidad de medida es obligatoria.');
    }

    await _database.transaction(() async {
      final existing = await findById(id);

      if (existing == null) {
        throw StateError('El producto que intentas actualizar no existe.');
      }

      await _ensureSkuAvailable(normalizedSku, excludingProductId: id);

      await (_database.update(
        _database.products,
      )..where((table) => table.id.equals(id))).write(
        ProductsCompanion(
          sku: Value(normalizedSku),
          name: Value(normalizedName),
          description: Value(_normalizeOptionalText(description)),
          category: Value(_normalizeOptionalText(category)),
          unit: Value(normalizedUnit),
          trackInventory: Value(trackInventory),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Stream<List<Product>> watchActiveProducts() {
    return (_database.select(_database.products)
          ..where((table) => table.isActive.equals(true))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch();
  }

  Future<Product?> findById(String id) {
    return (_database.select(
      _database.products,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<Product?> findBySku(String sku) {
    return (_database.select(_database.products)
          ..where((table) => table.sku.equals(_normalizeSku(sku))))
        .getSingleOrNull();
  }

  Future<void> setPrice({
    required String productId,
    required String currencyCode,
    required int amountMinorUnits,
  }) async {
    if (amountMinorUnits < 0) {
      throw ArgumentError('El precio no puede ser negativo.');
    }

    final normalizedCurrency = currencyCode.trim().toUpperCase();

    await _database.transaction(() async {
      final product = await findById(productId);

      if (product == null || !product.isActive) {
        throw StateError('El producto no existe o está inactivo.');
      }

      final currency =
          await (_database.select(_database.currencies)
                ..where((table) => table.code.equals(normalizedCurrency)))
              .getSingleOrNull();

      if (currency == null || !currency.isActive) {
        throw StateError('La moneda no existe o está inactiva.');
      }

      await _database
          .into(_database.productPrices)
          .insertOnConflictUpdate(
            ProductPricesCompanion.insert(
              productId: productId,
              currencyCode: normalizedCurrency,
              amountMinorUnits: amountMinorUnits,
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  Future<ProductPrice?> findPrice({
    required String productId,
    required String currencyCode,
  }) {
    return (_database.select(_database.productPrices)..where(
          (table) =>
              table.productId.equals(productId) &
              table.currencyCode.equals(currencyCode.trim().toUpperCase()),
        ))
        .getSingleOrNull();
  }

  Stream<List<ProductPrice>> watchPrices(String productId) {
    return (_database.select(_database.productPrices)
          ..where((table) => table.productId.equals(productId))
          ..orderBy([(table) => OrderingTerm.asc(table.currencyCode)]))
        .watch();
  }

  Future<void> setActive(String productId, bool active) async {
    await _database.transaction(() async {
      final product = await findById(productId);

      if (product == null) {
        throw StateError('El producto que intentas modificar no existe.');
      }

      await (_database.update(
        _database.products,
      )..where((table) => table.id.equals(productId))).write(
        ProductsCompanion(
          isActive: Value(active),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
