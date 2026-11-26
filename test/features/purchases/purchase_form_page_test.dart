import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/purchases/presentation/purchase_form_page.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late SupplierRepository supplierRepository;
  late GoRouter router;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    supplierRepository = SupplierRepository(database);

    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Inicio')),
        ),
        GoRoute(
          path: '/purchases/new',
          builder: (_, _) => const Scaffold(body: PurchaseFormPage()),
        ),
      ],
    );
  });

  Future<void> insertCurrency({
    required String code,
    bool isBase = false,
    bool isActive = true,
    int decimalDigits = 2,
  }) async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: code,
            name: code == 'CUP' ? 'Peso cubano' : code,
            symbol: code == 'CUP' ? '\$' : code,
            decimalDigits: Value(decimalDigits),
            isBase: Value(isBase),
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> pumpFormPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/purchases/new');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> disposeDatabase(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.runAsync(() async {
      await database.close().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('No se pudo cerrar la base de datos.');
        },
      );
    });
  }

  testWidgets('muestra los datos generales y selecciona la moneda base', (
    tester,
  ) async {
    try {
      await insertCurrency(code: 'CUP', isBase: true);
      await insertCurrency(code: 'USD');
      await supplierRepository.createSupplier(name: 'Proveedor principal');

      await pumpFormPage(tester);

      expect(find.text('Nueva compra'), findsOneWidget);
      expect(find.text('Datos generales'), findsOneWidget);
      expect(find.text('Proveedor'), findsOneWidget);
      expect(find.text('Número de documento (opcional)'), findsOneWidget);
      expect(find.text('Moneda de la compra'), findsOneWidget);
      expect(find.text('Notas (opcional)'), findsOneWidget);
      expect(find.text('Moneda: CUP (\$)'), findsOneWidget);
      expect(find.text('Crear borrador'), findsOneWidget);
    } finally {
      await disposeDatabase(tester);
    }
  });

  testWidgets('no permite crear un borrador sin proveedores activos', (
    tester,
  ) async {
    try {
      await insertCurrency(code: 'CUP', isBase: true);

      await pumpFormPage(tester);

      expect(
        find.text(
          'No hay proveedores activos. Registra o activa un proveedor.',
        ),
        findsOneWidget,
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Crear borrador'),
      );
      expect(button.onPressed, isNull);
    } finally {
      await disposeDatabase(tester);
    }
  });

  testWidgets('crea un borrador con los datos generales introducidos', (
    tester,
  ) async {
    try {
      await insertCurrency(code: 'CUP', isBase: true);
      final supplierId = await supplierRepository.createSupplier(
        name: 'Proveedor principal',
      );

      await pumpFormPage(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proveedor principal').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Número de documento (opcional)'),
        '  FAC-TEST-001  ',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Notas (opcional)'),
        '  Compra de prueba  ',
      );

      await tester.tap(find.text('Crear borrador'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Agregar productos'), findsOneWidget);
      expect(find.text('Borrador de compra'), findsOneWidget);
      expect(find.text('Proveedor: Proveedor principal'), findsOneWidget);
      expect(find.text('Moneda: CUP'), findsOneWidget);
      expect(find.text('Documento: FAC-TEST-001'), findsOneWidget);
      expect(find.text('Notas: Compra de prueba'), findsOneWidget);

      final purchases = await database.select(database.purchases).get();
      expect(purchases, hasLength(1));
      expect(purchases.single.supplierId, supplierId);
      expect(purchases.single.currencyCode, 'CUP');
      expect(purchases.single.documentNumber, 'FAC-TEST-001');
      expect(purchases.single.notes, 'Compra de prueba');
      expect(purchases.single.status, 'draft');
    } finally {
      await disposeDatabase(tester);
    }
  });
  testWidgets('agrega un producto y actualiza los totales del borrador', (
    tester,
  ) async {
    try {
      await insertCurrency(code: 'CUP', isBase: true);

      final supplierId = await supplierRepository.createSupplier(
        name: 'Proveedor principal',
      );

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              sku: 'SKU-001',
              name: 'Producto de prueba',
              unit: Value('unidad'),
              isActive: Value(true),
            ),
          );

      await pumpFormPage(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proveedor principal').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear borrador'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Borrador de compra'), findsOneWidget);

      await tester.tap(find.text('Agregar').first);
      await tester.pumpAndSettle();

      expect(find.text('Agregar producto'), findsOneWidget);
      expect(find.text('SKU-001 · Producto de prueba'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Cantidad (máximo 3 decimales)'),
        '2',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Costo unitario (CUP)'),
        '150',
      );

      await tester.tap(find.text('Agregar').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Producto de prueba'), findsOneWidget);
      expect(find.text('SKU: SKU-001'), findsOneWidget);
      expect(find.text('Cantidad: 2 unidad'), findsOneWidget);
      expect(find.text('Costo unitario: 150.00 CUP'), findsOneWidget);
      expect(find.text('Total: 300.00 CUP'), findsOneWidget);
      expect(find.text('Resumen de compra'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Total'), findsWidgets);
      expect(find.text('300.00 CUP'), findsNWidgets(2));

      final purchases = await database.select(database.purchases).get();
      final details = await database.select(database.purchaseDetails).get();

      expect(purchases, hasLength(1));
      expect(purchases.single.supplierId, supplierId);
      expect(purchases.single.subtotalMinorUnits, 30000);
      expect(purchases.single.totalMinorUnits, 30000);

      expect(details, hasLength(1));
      expect(details.single.productId, 'product-1');
      expect(details.single.skuSnapshot, 'SKU-001');
      expect(details.single.productNameSnapshot, 'Producto de prueba');
      expect(details.single.quantityMilliUnits, 2000);
      expect(details.single.unitCostMinorUnits, 15000);
      expect(details.single.totalMinorUnits, 30000);
    } finally {
      await disposeDatabase(tester);
    }
  });
  testWidgets(
    'edita un producto y recalcula los totales sin duplicar la línea',
    (tester) async {
      try {
        await insertCurrency(code: 'CUP', isBase: true);

        await supplierRepository.createSupplier(name: 'Proveedor principal');

        await database
            .into(database.products)
            .insert(
              ProductsCompanion.insert(
                id: 'product-1',
                sku: 'SKU-001',
                name: 'Producto de prueba',
                unit: Value('unidad'),
                isActive: Value(true),
              ),
            );

        await pumpFormPage(tester);

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Proveedor principal').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Crear borrador'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Agregar').first);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Cantidad (máximo 3 decimales)'),
          '2',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Costo unitario (CUP)'),
          '150',
        );

        await tester.tap(find.text('Agregar').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        final originalDetails = await database
            .select(database.purchaseDetails)
            .get();

        expect(originalDetails, hasLength(1));
        final originalDetailId = originalDetails.single.id;

        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();

        expect(find.text('Editar producto'), findsOneWidget);

        expect(
          tester
              .widget<TextField>(
                find.widgetWithText(TextField, 'Cantidad (máximo 3 decimales)'),
              )
              .controller!
              .text,
          '2',
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Cantidad (máximo 3 decimales)'),
          '3',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Costo unitario (CUP)'),
          '200',
        );

        await tester.tap(find.text('Guardar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Cantidad: 3 unidad'), findsOneWidget);
        expect(find.text('Costo unitario: 200.00 CUP'), findsOneWidget);
        expect(find.text('Total: 600.00 CUP'), findsOneWidget);
        expect(find.text('600.00 CUP'), findsNWidgets(2));

        final purchases = await database.select(database.purchases).get();
        final details = await database.select(database.purchaseDetails).get();

        expect(purchases, hasLength(1));
        expect(purchases.single.subtotalMinorUnits, 60000);
        expect(purchases.single.totalMinorUnits, 60000);

        expect(details, hasLength(1));
        expect(details.single.id, originalDetailId);
        expect(details.single.quantityMilliUnits, 3000);
        expect(details.single.unitCostMinorUnits, 20000);
        expect(details.single.totalMinorUnits, 60000);
      } finally {
        await disposeDatabase(tester);
      }
    },
  );
  testWidgets('elimina un producto con confirmación y conserva el borrador', (
    tester,
  ) async {
    try {
      await insertCurrency(code: 'CUP', isBase: true);

      await supplierRepository.createSupplier(name: 'Proveedor principal');

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              sku: 'SKU-001',
              name: 'Producto de prueba',
              unit: Value('unidad'),
              isActive: Value(true),
            ),
          );

      await pumpFormPage(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proveedor principal').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear borrador'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Agregar').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Cantidad (máximo 3 decimales)'),
        '2',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Costo unitario (CUP)'),
        '150',
      );

      await tester.tap(find.text('Agregar').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final originalPurchases = await database.select(database.purchases).get();
      final originalDetails = await database
          .select(database.purchaseDetails)
          .get();

      expect(originalPurchases, hasLength(1));
      expect(originalDetails, hasLength(1));

      final purchaseId = originalPurchases.single.id;
      final detailId = originalDetails.single.id;

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar producto'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      var purchases = await database.select(database.purchases).get();
      var details = await database.select(database.purchaseDetails).get();

      expect(purchases, hasLength(1));
      expect(details, hasLength(1));
      expect(details.single.id, detailId);
      expect(purchases.single.totalMinorUnits, 30000);
      expect(find.text('Producto de prueba'), findsOneWidget);

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Todavía no hay productos.'), findsOneWidget);
      expect(find.text('Resumen de compra'), findsOneWidget);
      expect(find.text('Total'), findsWidgets);
      expect(find.text('0.00 CUP'), findsNWidgets(4));

      purchases = await database.select(database.purchases).get();
      details = await database.select(database.purchaseDetails).get();

      expect(purchases, hasLength(1));
      expect(purchases.single.id, purchaseId);
      expect(purchases.single.status, 'draft');
      expect(purchases.single.subtotalMinorUnits, 0);
      expect(purchases.single.totalMinorUnits, 0);
      expect(details, isEmpty);
    } finally {
      await disposeDatabase(tester);
    }
  });
}


