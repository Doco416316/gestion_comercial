import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/inventory/data/inventory_repository.dart';
import 'package:gestion_comercial/features/inventory/presentation/pages/inventory_page.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.stream);

  final Stream<List<Product>> stream;

  @override
  Stream<List<Product>> watchActiveProducts() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeInventoryRepository implements InventoryRepository {
  FakeInventoryRepository({
    required this.stockStream,
    this.history = const <InventoryMovement>[],
    this.onRegister,
  });

  final Stream<int> stockStream;
  final List<InventoryMovement> history;
  final Future<String> Function({
    required String productId,
    required String movementType,
    required int quantityMilliUnits,
    required String reason,
    String? reference,
  })?
  onRegister;

  final List<
    ({
      String productId,
      String movementType,
      int quantityMilliUnits,
      String reason,
      String? reference,
    })
  >
  registerCalls = [];

  @override
  Stream<int> watchStock(String productId) => stockStream;

  @override
  Future<List<InventoryMovement>> getMovementHistory(String productId) async =>
      history;

  @override
  Future<String> registerMovement({
    required String productId,
    required String movementType,
    required int quantityMilliUnits,
    required String reason,
    String? reference,
  }) async {
    registerCalls.add((
      productId: productId,
      movementType: movementType,
      quantityMilliUnits: quantityMilliUnits,
      reason: reason,
      reference: reference,
    ));
    if (onRegister != null) {
      return onRegister!(
        productId: productId,
        movementType: movementType,
        quantityMilliUnits: quantityMilliUnits,
        reason: reason,
        reference: reference,
      );
    }
    return 'movement-id';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  final sampleProduct = Product(
    id: 'product-1',
    sku: 'SKU-001',
    name: 'Producto de prueba',
    description: null,
    category: 'Categoría A',
    unit: 'unidad',
    trackInventory: true,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  testWidgets('muestra spinner mientras carga', (tester) async {
    final controller = StreamController<List<Product>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(controller.stream),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(stockStream: Stream.value(0)),
          ),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra mensaje cuando no hay productos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value(const <Product>[])),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(stockStream: Stream.value(0)),
          ),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay productos en inventario'), findsOneWidget);
  });

  testWidgets('muestra error legible', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(
              Stream<List<Product>>.error(Exception('boom')),
            ),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(stockStream: Stream.value(0)),
          ),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra lista con stock', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([sampleProduct])),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(stockStream: Stream.value(1500)),
          ),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SKU-001'), findsOneWidget);
    expect(find.text('Producto de prueba'), findsOneWidget);
    expect(find.text('Stock: 1500 milésimas · unidad'), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('abre historial de movimientos', (tester) async {
    final movement = InventoryMovement(
      id: 'movement-1',
      productId: 'product-1',
      movementType: 'entry',
      quantityMilliUnits: 1000,
      reason: 'Compra inicial',
      reference: null,
      correctionOfId: null,
      createdAt: DateTime(2026, 1, 2),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([sampleProduct])),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(
              stockStream: Stream.value(1000),
              history: [movement],
            ),
          ),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text('Historial de movimientos'), findsOneWidget);
    expect(find.text('entry'), findsOneWidget);
    expect(find.text('Cantidad: 1000 milésimas'), findsOneWidget);
    expect(find.text('Motivo: Compra inicial'), findsOneWidget);
  });

  testWidgets('registra movimiento desde el FAB', (tester) async {
    final fakeInventory = FakeInventoryRepository(stockStream: Stream.value(0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([sampleProduct])),
          ),
          inventoryRepositoryProvider.overrideWithValue(fakeInventory),
        ],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Registrar movimiento'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SKU-001 - Producto de prueba').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Cantidad'), '500');
    await tester.enterText(
      find.widgetWithText(TextField, 'Motivo'),
      'Entrada inicial',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(fakeInventory.registerCalls, hasLength(1));
    final call = fakeInventory.registerCalls.single;
    expect(call.productId, 'product-1');
    expect(call.movementType, 'entry');
    expect(call.quantityMilliUnits, 500);
    expect(call.reason, 'Entrada inicial');
    expect(find.text('Movimiento registrado'), findsOneWidget);
  });
}
