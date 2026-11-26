import 'dart:async';

import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/app/theme/app_theme.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/products/presentation/product_form_page.dart';
import 'package:gestion_comercial/features/products/presentation/product_list_page.dart';
import 'package:gestion_comercial/features/suppliers/presentation/supplier_form_page.dart';
import 'package:gestion_comercial/features/suppliers/presentation/supplier_list_page.dart';

void main() {
  late AppDatabase database;
  late GoRouter router;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    router = GoRouter(
      initialLocation: '/suppliers',
      routes: [
        GoRoute(
          path: '/suppliers',
          builder: (_, _) => const Scaffold(body: SupplierListPage()),
        ),
        GoRoute(
          path: '/suppliers/new',
          builder: (_, _) => const Scaffold(body: SupplierFormPage()),
        ),
        GoRoute(
          path: '/products',
          builder: (_, _) => const Scaffold(body: ProductListPage()),
        ),
        GoRoute(
          path: '/products/new',
          builder: (_, _) => const Scaffold(body: ProductFormPage()),
        ),
      ],
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> disposeApp(WidgetTester tester) async {
    // Desmontar primero la aplicación para liberar sus recursos.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    router.dispose();

    await tester.runAsync(() async {
      await database.close().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('No se pudo cerrar la base de datos.');
        },
      );
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  // Localiza los campos de texto reales de la interfaz.
  // TextFormField contiene internamente un TextField.

  Future<void> enterFieldText(
    WidgetTester tester,
    int index,
    String value,
  ) async {
    // Buscar exclusivamente los campos del formulario abierto.
    // Así se excluye el campo de búsqueda de la pantalla anterior.
    final fields = find.descendant(
      of: find.byType(Form),
      matching: find.byType(EditableText),
    );

    expect(
      fields,
      findsWidgets,
      reason: 'No se encontraron campos de texto en el formulario.',
    );

    expect(
      fields.evaluate().length,
      greaterThan(index),
      reason: 'No existe el campo de texto número $index.',
    );

    final field = fields.at(index);

    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pump();

    await tester.enterText(field, value);
    await tester.pump();

    expect(
      find.text(value),
      findsWidgets,
      reason: 'No se pudo introducir el texto: $value',
    );
  }

  testWidgets('permite registrar un proveedor desde el directorio', (
    tester,
  ) async {
    try {
      await pumpApp(tester);

      expect(find.text('Directorio de proveedores'), findsOneWidget);

      final registerButton = find.byTooltip('Registrar nuevo proveedor');

      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Nuevo proveedor'), findsOneWidget);

      // El primer campo corresponde al nombre del proveedor.
      await enterFieldText(tester, 0, 'Distribuidora Central');

      final saveButton = find.text('Guardar proveedor');

      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final suppliers = await database.select(database.suppliers).get();

      expect(suppliers, hasLength(1));
      expect(suppliers.single.name, 'Distribuidora Central');
    } finally {
      await disposeApp(tester);
    }
  });

  testWidgets('permite registrar un producto desde el catálogo', (
    tester,
  ) async {
    try {
      await pumpApp(tester);

      // Abrir el catálogo de productos.
      router.go('/products');
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de productos'), findsOneWidget);

      final registerButton = find.byTooltip('Registrar nuevo producto');

      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Nuevo producto'), findsOneWidget);

      // SKU del producto.
      await enterFieldText(tester, 0, 'SKU-100');

      // Nombre del producto.
      await enterFieldText(tester, 1, 'Producto de prueba');

      final saveButton = find.text('Guardar producto');

      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final products = await database.select(database.products).get();

      expect(products, hasLength(1));
      expect(products.single.sku, 'SKU-100');
      expect(products.single.name, 'Producto de prueba');
    } finally {
      await disposeApp(tester);
    }
  });
}
