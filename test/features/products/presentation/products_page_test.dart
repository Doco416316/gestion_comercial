import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';
import 'package:gestion_comercial/features/products/presentation/pages/products_page.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.stream);

  final Stream<List<Product>> stream;

  @override
  Stream<List<Product>> watchActiveProducts() => stream;

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

  final noInventoryProduct = Product(
    id: 'product-2',
    sku: 'SKU-002',
    name: 'Producto sin inventario',
    description: null,
    category: null,
    unit: 'unidad',
    trackInventory: false,
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
        ],
        child: const MaterialApp(home: ProductsPage()),
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
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay productos'), findsOneWidget);
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
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra lista con datos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([sampleProduct])),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('SKU-001'), findsOneWidget);
    expect(find.text('Producto de prueba'), findsOneWidget);
    expect(find.text('Categoría A'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2), findsOneWidget);
  });

  testWidgets('muestra producto sin categoría ni inventario', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([noInventoryProduct])),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SKU-002'), findsOneWidget);
    expect(find.text('Producto sin inventario'), findsOneWidget);
    expect(find.text('Sin categoría'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
