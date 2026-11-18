import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class InventoryStock {
  const InventoryStock({
    required this.product,
    required this.quantityMilliUnits,
  });

  final Product product;
  final int quantityMilliUnits;
}

class InventoryMovementEntry {
  const InventoryMovementEntry({required this.movement, required this.product});

  final InventoryMovement movement;
  final Product product;
}

class InventoryRepository {
  InventoryRepository(this._database);

  final AppDatabase _database;

  static const Uuid _uuid = Uuid();

  static const Set<String> _movementTypes = {
    'entry',
    'exit',
    'positive_adjustment',
    'negative_adjustment',
    'customer_return',
    'supplier_return',
  };

  static const Map<String, String> _inverseTypes = {
    'entry': 'exit',
    'exit': 'entry',
    'positive_adjustment': 'negative_adjustment',
    'negative_adjustment': 'positive_adjustment',
    'customer_return': 'supplier_return',
    'supplier_return': 'customer_return',
  };

  static const Set<String> _increasingTypes = {
    'entry',
    'positive_adjustment',
    'customer_return',
  };

  bool _increasesStock(String type) => _increasingTypes.contains(type);

  String _normalizeText(String value) => value.trim();

  Stream<List<InventoryStock>> watchInventory() {
    final query = _database.customSelect(
      '''
    SELECT
      products.*,
      COALESCE(inventory_balances.quantity_milli_units, 0)
        AS current_quantity_milli_units
    FROM products
    LEFT JOIN inventory_balances
      ON inventory_balances.product_id = products.id
    WHERE products.track_inventory = 1
      AND products.is_active = 1
    ORDER BY products.name ASC
    ''',
      readsFrom: {
        _database.products,
        _database.inventoryBalances,
        _database.inventoryMovements,
      },
    );

    return query.watch().map(
      (rows) => rows.map((row) {
        return InventoryStock(
          product: _database.products.map(row.data),
          quantityMilliUnits: row.data['current_quantity_milli_units'] as int,
        );
      }).toList(),
    );
  }

  Stream<List<InventoryMovementEntry>> watchRecentMovements({int limit = 100}) {
    final query =
        _database.select(_database.inventoryMovements).join([
            innerJoin(
              _database.products,
              _database.products.id.equalsExp(
                _database.inventoryMovements.productId,
              ),
            ),
          ])
          ..orderBy([
            OrderingTerm.desc(_database.inventoryMovements.createdAt),
            OrderingTerm.desc(_database.inventoryMovements.id),
          ])
          ..limit(limit);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => InventoryMovementEntry(
              movement: row.readTable(_database.inventoryMovements),
              product: row.readTable(_database.products),
            ),
          )
          .toList(),
    );
  }

  Future<int> getStock(String productId) async {
    final balance = await (_database.select(
      _database.inventoryBalances,
    )..where((table) => table.productId.equals(productId))).getSingleOrNull();

    return balance?.quantityMilliUnits ?? 0;
  }

  Stream<int> watchStock(String productId) {
    final query = _database.customSelect(
      '''
    SELECT quantity_milli_units
    FROM inventory_balances
    WHERE product_id = ?
    ''',
      variables: [Variable.withString(productId)],
      readsFrom: {_database.inventoryBalances, _database.inventoryMovements},
    );

    return query.watchSingleOrNull().map(
      (row) => row?.data['quantity_milli_units'] as int? ?? 0,
    );
  }

  Future<String> registerMovement({
    required String productId,
    required String movementType,
    required int quantityMilliUnits,
    required String reason,
    String? reference,
  }) async {
    final normalizedType = _normalizeText(movementType).toLowerCase();
    final normalizedReason = _normalizeText(reason);
    final normalizedReference = reference?.trim();

    if (!_movementTypes.contains(normalizedType)) {
      throw ArgumentError('El tipo de movimiento no es válido.');
    }

    if (quantityMilliUnits <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero.');
    }

    if (normalizedReason.isEmpty) {
      throw ArgumentError('El motivo del movimiento es obligatorio.');
    }

    final id = _uuid.v4();

    await _database.transaction(() async {
      final product = await (_database.select(
        _database.products,
      )..where((table) => table.id.equals(productId))).getSingleOrNull();

      if (product == null || !product.isActive) {
        throw StateError('El producto no existe o está inactivo.');
      }

      if (!product.trackInventory) {
        throw StateError('Este producto no tiene control de inventario.');
      }

      if (!_increasesStock(normalizedType)) {
        final currentStock = await getStock(productId);

        if (currentStock < quantityMilliUnits) {
          throw StateError('No hay existencias suficientes.');
        }
      }

      await _database
          .into(_database.inventoryMovements)
          .insert(
            InventoryMovementsCompanion.insert(
              id: id,
              productId: productId,
              movementType: normalizedType,
              quantityMilliUnits: quantityMilliUnits,
              reason: normalizedReason,
              reference: Value(
                normalizedReference == null || normalizedReference.isEmpty
                    ? null
                    : normalizedReference,
              ),
            ),
          );
    });

    return id;
  }

  Future<String> correctMovement({
    required String originalMovementId,
    required String reason,
    String? reference,
  }) async {
    final normalizedReason = reason.trim();
    final normalizedReference = reference?.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError('El motivo de la corrección es obligatorio.');
    }

    final correctionId = _uuid.v4();

    await _database.transaction(() async {
      final original =
          await (_database.select(_database.inventoryMovements)
                ..where((table) => table.id.equals(originalMovementId)))
              .getSingleOrNull();

      if (original == null) {
        throw StateError('El movimiento original no existe.');
      }

      if (original.correctionOfId != null) {
        throw StateError('No se permite corregir un movimiento compensatorio.');
      }

      final existingCorrection =
          await (_database.select(_database.inventoryMovements)..where(
                (table) => table.correctionOfId.equals(originalMovementId),
              ))
              .getSingleOrNull();

      if (existingCorrection != null) {
        throw StateError('Este movimiento ya tiene una corrección registrada.');
      }

      final inverseType = _inverseTypes[original.movementType];

      if (inverseType == null) {
        throw StateError('No se puede corregir este tipo de movimiento.');
      }

      if (!_increasesStock(inverseType)) {
        final currentStock = await getStock(original.productId);

        if (currentStock < original.quantityMilliUnits) {
          throw StateError(
            'No se puede corregir: las existencias actuales '
            'son insuficientes para compensar el movimiento.',
          );
        }
      }

      await _database
          .into(_database.inventoryMovements)
          .insert(
            InventoryMovementsCompanion.insert(
              id: correctionId,
              productId: original.productId,
              movementType: inverseType,
              quantityMilliUnits: original.quantityMilliUnits,
              reason: normalizedReason,
              reference: Value(
                normalizedReference == null || normalizedReference.isEmpty
                    ? null
                    : normalizedReference,
              ),
              correctionOfId: Value(originalMovementId),
            ),
          );
    });

    return correctionId;
  }

  Future<List<InventoryMovement>> getMovementHistory(String productId) {
    return (_database.select(_database.inventoryMovements)
          ..where((table) => table.productId.equals(productId))
          ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .get();
  }
}
