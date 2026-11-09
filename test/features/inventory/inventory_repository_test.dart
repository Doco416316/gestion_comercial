import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/inventory/data/inventory_repository.dart';

void main() {
  late AppDatabase database;
  late InventoryRepository repository;
  late String productId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = InventoryRepository(database);

    productId = 'producto-001';

    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: productId,
            sku: 'PROD-001',
            name: 'Producto de prueba',
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('El inventario comienza en cero', () async {
    final stock = await repository.getStock(productId);

    expect(stock, 0);
  });

  test('Registra una entrada correctamente', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 100000,
      reason: 'Inventario inicial',
    );

    expect(await repository.getStock(productId), 100000);
  });

  test('Calcula correctamente entradas y salidas', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 100000,
      reason: 'Compra',
    );

    await repository.registerMovement(
      productId: productId,
      movementType: 'exit',
      quantityMilliUnits: 25000,
      reason: 'Venta',
    );

    expect(await repository.getStock(productId), 75000);
  });

  test('Registra correctamente una devolución de cliente', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 100000,
      reason: 'Compra',
    );

    await repository.registerMovement(
      productId: productId,
      movementType: 'customer_return',
      quantityMilliUnits: 5000,
      reason: 'Devolución',
    );

    expect(await repository.getStock(productId), 105000);
  });

  test('Registra correctamente un ajuste negativo', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 100000,
      reason: 'Inventario inicial',
    );

    await repository.registerMovement(
      productId: productId,
      movementType: 'negative_adjustment',
      quantityMilliUnits: 2000,
      reason: 'Producto dañado',
    );

    expect(await repository.getStock(productId), 98000);
  });

  test('Rechaza una salida superior a las existencias', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra',
    );

    await expectLater(
      repository.registerMovement(
        productId: productId,
        movementType: 'exit',
        quantityMilliUnits: 15000,
        reason: 'Venta',
      ),
      throwsA(isA<StateError>()),
    );

    expect(await repository.getStock(productId), 10000);
  });

  test('Rechaza cantidades iguales o inferiores a cero', () async {
    await expectLater(
      repository.registerMovement(
        productId: productId,
        movementType: 'entry',
        quantityMilliUnits: 0,
        reason: 'Prueba',
      ),
      throwsArgumentError,
    );
  });

  test('Rechaza tipos de movimiento desconocidos', () async {
    await expectLater(
      repository.registerMovement(
        productId: productId,
        movementType: 'unknown',
        quantityMilliUnits: 1000,
        reason: 'Prueba',
      ),
      throwsArgumentError,
    );
  });

  test('Rechaza movimientos de productos inactivos', () async {
    await (database.update(database.products)
          ..where((table) => table.id.equals(productId)))
        .write(const ProductsCompanion(isActive: Value(false)));

    await expectLater(
      repository.registerMovement(
        productId: productId,
        movementType: 'entry',
        quantityMilliUnits: 1000,
        reason: 'Prueba',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Permite consultar el historial de movimientos', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra',
    );

    await repository.registerMovement(
      productId: productId,
      movementType: 'exit',
      quantityMilliUnits: 2000,
      reason: 'Venta',
    );

    final history = await repository.getMovementHistory(productId);

    expect(history.length, 2);
  });

  test('Corrige una entrada mediante un movimiento compensatorio', () async {
    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    final correctionId = await repository.correctMovement(
      originalMovementId: originalId,
      reason: 'Error en el registro',
    );

    expect(await repository.getStock(productId), 0);

    final history = await repository.getMovementHistory(productId);

    expect(history.length, 2);

    final correction = history.firstWhere(
      (movement) => movement.id == correctionId,
    );

    expect(correction.movementType, 'exit');
    expect(correction.quantityMilliUnits, 10000);
    expect(correction.correctionOfId, originalId);
  });

  test('Impide corregir dos veces el mismo movimiento', () async {
    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    await repository.correctMovement(
      originalMovementId: originalId,
      reason: 'Primera corrección',
    );

    await expectLater(
      repository.correctMovement(
        originalMovementId: originalId,
        reason: 'Segunda corrección',
      ),
      throwsA(isA<StateError>()),
    );

    expect(await repository.getStock(productId), 0);
  });

  test('Impide corregir una entrada si el stock es insuficiente', () async {
    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    await repository.registerMovement(
      productId: productId,
      movementType: 'exit',
      quantityMilliUnits: 8000,
      reason: 'Venta',
    );

    await expectLater(
      repository.correctMovement(
        originalMovementId: originalId,
        reason: 'Anular compra',
      ),
      throwsA(isA<StateError>()),
    );

    expect(await repository.getStock(productId), 2000);
  });

  test('SQLite impide modificar un movimiento existente', () async {
    final movementId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    await expectLater(
      (database.update(
        database.inventoryMovements,
      )..where((table) => table.id.equals(movementId))).write(
        const InventoryMovementsCompanion(
          reason: Value('Intento de modificación'),
        ),
      ),
      throwsA(isA<Exception>()),
    );

    expect(await repository.getStock(productId), 10000);
  });

  test('SQLite impide eliminar un movimiento existente', () async {
    final movementId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    await expectLater(
      (database.delete(
        database.inventoryMovements,
      )..where((table) => table.id.equals(movementId))).go(),
      throwsA(isA<Exception>()),
    );

    expect(await repository.getStock(productId), 10000);
  });

  test('SQLite impide dos correcciones para el mismo movimiento', () async {
    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    await database
        .into(database.inventoryMovements)
        .insert(
          InventoryMovementsCompanion.insert(
            id: 'correccion-001',
            productId: productId,
            movementType: 'exit',
            quantityMilliUnits: 10000,
            reason: 'Primera compensación',
            correctionOfId: Value(originalId),
          ),
        );

    await expectLater(
      database
          .into(database.inventoryMovements)
          .insert(
            InventoryMovementsCompanion.insert(
              id: 'correccion-002',
              productId: productId,
              movementType: 'exit',
              quantityMilliUnits: 10000,
              reason: 'Segunda compensación',
              correctionOfId: Value(originalId),
            ),
          ),
      throwsA(isA<Exception>()),
    );

    final history = await repository.getMovementHistory(productId);

    expect(history.length, 2);
  });

  test('SQLite impide corregir un movimiento compensatorio', () async {
    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Compra inicial',
    );

    // Insertamos directamente una primera compensación.
    await database
        .into(database.inventoryMovements)
        .insert(
          InventoryMovementsCompanion.insert(
            id: 'correccion-001',
            productId: productId,
            movementType: 'exit',
            quantityMilliUnits: 10000,
            reason: 'Primera compensación',
            correctionOfId: Value(originalId),
          ),
        );

    // Intentamos compensar la primera compensación.
    await expectLater(
      database
          .into(database.inventoryMovements)
          .insert(
            InventoryMovementsCompanion.insert(
              id: 'correccion-002',
              productId: productId,
              movementType: 'entry',
              quantityMilliUnits: 10000,
              reason: 'Segunda compensación',
              correctionOfId: const Value('correccion-001'),
            ),
          ),
      throwsA(isA<Exception>()),
    );

    final history = await repository.getMovementHistory(productId);

    expect(history.length, 2);
  });

  test('Impide que dos salidas simultáneas provoquen stock negativo', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Inventario inicial',
    );

    final results = await Future.wait([
      repository
          .registerMovement(
            productId: productId,
            movementType: 'exit',
            quantityMilliUnits: 7000,
            reason: 'Venta simultánea A',
          )
          .then<bool>((_) => true, onError: (Object _) => false),
      repository
          .registerMovement(
            productId: productId,
            movementType: 'exit',
            quantityMilliUnits: 7000,
            reason: 'Venta simultánea B',
          )
          .then<bool>((_) => true, onError: (Object _) => false),
    ]);

    expect(results.where((success) => success).length, 1);
    expect(results.where((success) => !success).length, 1);

    expect(await repository.getStock(productId), 3000);
  });

  test('Corregir una salida restaura las existencias', () async {
    await repository.registerMovement(
      productId: productId,
      movementType: 'entry',
      quantityMilliUnits: 10000,
      reason: 'Inventario inicial',
    );

    final originalId = await repository.registerMovement(
      productId: productId,
      movementType: 'exit',
      quantityMilliUnits: 4000,
      reason: 'Venta registrada por error',
    );

    expect(await repository.getStock(productId), 6000);

    await repository.correctMovement(
      originalMovementId: originalId,
      reason: 'Anulación de la venta',
    );

    expect(await repository.getStock(productId), 10000);
  });

  test(
    'Impide que el saldo de inventario supere el límite de SQLite',
    () async {
      const maxSqliteInteger = 9223372036854775807;

      // Registramos una entrada que alcanza exactamente el límite.
      await repository.registerMovement(
        productId: productId,
        movementType: 'entry',
        quantityMilliUnits: maxSqliteInteger,
        reason: 'Prueba de límite máximo',
      );

      expect(await repository.getStock(productId), maxSqliteInteger);

      // Intentamos superar el límite por una milésima.
      await expectLater(
        repository.registerMovement(
          productId: productId,
          movementType: 'entry',
          quantityMilliUnits: 1,
          reason: 'Intento de superar el límite',
        ),
        throwsA(isA<Exception>()),
      );

      // El saldo debe permanecer intacto.
      expect(await repository.getStock(productId), maxSqliteInteger);

      // El movimiento rechazado no debe quedar registrado.
      final history = await repository.getMovementHistory(productId);

      expect(history.length, 1);
    },
  );
}
