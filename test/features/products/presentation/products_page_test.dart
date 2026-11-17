import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';
import 'package:gestion_comercial/features/products/presentation/pages/products_page.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(
    this.stream, {
    this.onCreateProduct,
    this.onUpdateProduct,
  });

  final Stream<List<Product>> stream;
  final Future<String> Function({
    required String sku,
    required String name,
    String? description,
    String? category,
    String unit,
    bool trackInventory,
  })?
  onCreateProduct;
  final Future<void> Function({
    required String id,
    required String sku,
    required String name,
    required String? description,
    required String? category,
    required String unit,
    required bool trackInventory,
  })?
  onUpdateProduct;

  final List<
    ({
      String sku,
      String name,
      String? description,
      String? category,
      String unit,
      bool trackInventory,
    })
  >
  createCalls = [];
  final List<
    ({
      String id,
      String sku,
      String name,
      String? description,
      String? category,
      String unit,
      bool trackInventory,
    })
  >
  updateCalls = [];

  @override
  Stream<List<Product>> watchActiveProducts() => stream;

  @override
  Future<String> createProduct({
    required String sku,
    required String name,
    String? description,
    String? category,
    String unit = 'unidad',
    bool trackInventory = true,
  }) async {
    createCalls.add((
      sku: sku,
      name: name,
      description: description,
      category: category,
      unit: unit,
      trackInventory: trackInventory,
    ));
    return (await onCreateProduct?.call(
          sku: sku,
          name: name,
          description: description,
          category: category,
          unit: unit,
          trackInventory: trackInventory,
        )) ??
        'producto-nuevo';
  }

  @override
  Future<void> updateProduct({
    required String id,
    required String sku,
    required String name,
    required String? description,
    required String? category,
    required String unit,
    required bool trackInventory,
  }) async {
    updateCalls.add((
      id: id,
      sku: sku,
      name: name,
      description: description,
      category: category,
      unit: unit,
      trackInventory: trackInventory,
    ));
    await onUpdateProduct?.call(
      id: id,
      sku: sku,
      name: name,
      description: description,
      category: category,
      unit: unit,
      trackInventory: trackInventory,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> pumpPage(
  WidgetTester tester, {
  required ProductRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: ProductsPage()),
    ),
  );
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

  testWidgets('abre diálogo de creación al pulsar el FAB', (tester) async {
    await pumpPage(
      tester,
      repository: FakeProductRepository(Stream.value(const <Product>[])),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'SKU'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nombre'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Descripción'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Categoría'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Guardar'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('crea producto exitosamente', (tester) async {
    final fake = FakeProductRepository(Stream.value(const <Product>[]));
    await pumpPage(tester, repository: fake);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'SKU'), 'SKU-003');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Producto nuevo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Descripción'),
      'Descripción nueva',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Categoría'),
      'Categoría B',
    );
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(fake.createCalls, hasLength(1));
    final call = fake.createCalls.single;
    expect(call.sku, 'SKU-003');
    expect(call.name, 'Producto nuevo');
    expect(call.description, 'Descripción nueva');
    expect(call.category, 'Categoría B');
    expect(call.unit, 'unidad');
    expect(call.trackInventory, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Producto creado'), findsOneWidget);
  });

  testWidgets('muestra error al crear producto', (tester) async {
    final fake = FakeProductRepository(
      Stream.value(const <Product>[]),
      onCreateProduct:
          ({
            required String sku,
            required String name,
            String? description,
            String? category,
            String unit = 'unidad',
            bool trackInventory = true,
          }) async {
            throw StateError('Ya existe un producto con el código SKU $sku.');
          },
    );
    await pumpPage(tester, repository: fake);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'SKU'), 'SKU-003');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Producto nuevo',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ya existe un producto con el código SKU SKU-003.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('abre diálogo de edición con datos precargados', (tester) async {
    await pumpPage(
      tester,
      repository: FakeProductRepository(Stream.value([sampleProduct])),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Editar producto'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'SKU'))
          .controller!
          .text,
      'SKU-001',
    );
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Nombre'))
          .controller!
          .text,
      'Producto de prueba',
    );
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Categoría'))
          .controller!
          .text,
      'Categoría A',
    );
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('edita producto exitosamente', (tester) async {
    final fake = FakeProductRepository(Stream.value([sampleProduct]));
    await pumpPage(tester, repository: fake);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Producto editado',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(fake.updateCalls, hasLength(1));
    final call = fake.updateCalls.single;
    expect(call.id, 'product-1');
    expect(call.sku, 'SKU-001');
    expect(call.name, 'Producto editado');
    expect(call.description, '');
    expect(call.category, 'Categoría A');
    expect(call.unit, 'unidad');
    expect(call.trackInventory, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Producto actualizado'), findsOneWidget);
  });

  testWidgets('muestra error al editar producto', (tester) async {
    final fake = FakeProductRepository(
      Stream.value([sampleProduct]),
      onUpdateProduct:
          ({
            required String id,
            required String sku,
            required String name,
            required String? description,
            required String? category,
            required String unit,
            required bool trackInventory,
          }) async {
            throw StateError('No se pudo actualizar');
          },
    );
    await pumpPage(tester, repository: fake);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Producto editado',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo actualizar'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('deshabilita guardar durante la operación', (tester) async {
    final completer = Completer<void>();
    final fake = FakeProductRepository(
      Stream.value(const <Product>[]),
      onCreateProduct:
          ({
            required String sku,
            required String name,
            String? description,
            String? category,
            String unit = 'unidad',
            bool trackInventory = true,
          }) {
            return completer.future.then((_) => 'producto-nuevo');
          },
    );
    await pumpPage(tester, repository: fake);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'SKU'), 'SKU-003');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Producto nuevo',
    );
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Producto creado'), findsOneWidget);
  });
}
