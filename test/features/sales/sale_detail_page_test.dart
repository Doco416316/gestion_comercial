import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/app/theme/app_theme.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/sales/data/sales_repository.dart';
import 'package:gestion_comercial/features/sales/domain/sale_payment_service.dart';
import 'package:gestion_comercial/features/sales/presentation/sale_detail_page.dart';

void main() {
  late AppDatabase database;
  late SalesRepository repository;
  late GoRouter router;
  late ProviderContainer container;
  late String saleId;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SalesRepository(database);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );

    router = GoRouter(
      initialLocation: '/sales/detail',
      routes: [
        GoRoute(
          path: '/sales/detail',
          builder: (context, state) => SaleDetailPage(saleId: saleId),
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) =>
              const Scaffold(body: Text('Lista de ventas')),
        ),
      ],
    );
  });

  Future<void> seedSale() async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'CUP',
            name: 'Peso cubano',
            symbol: 'CUP',
            isBase: const Value(true),
          ),
        );

    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'customer-widget-test',
            customerType: 'individual',
            name: 'Cliente de prueba',
          ),
        );

    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-widget-test',
            sku: 'SKU-WIDGET',
            name: 'Producto de prueba',
          ),
        );

    await database
        .into(database.inventoryMovements)
        .insert(
          InventoryMovementsCompanion.insert(
            id: 'opening-widget-test',
            productId: 'product-widget-test',
            movementType: 'entry',
            quantityMilliUnits: 5000,
            reason: 'Existencia inicial',
          ),
        );

    saleId = await repository.createDraft(
      customerId: 'customer-widget-test',
      saleDate: DateTime(2026, 1, 15),
      currencyCode: 'CUP',
      paymentType: SalePaymentType.credit,
    );

    await repository.addDetail(
      saleId: saleId,
      productId: 'product-widget-test',
      quantityMilliUnits: 2000,
      unitPriceMinorUnits: 10000,
    );

    await repository.confirmSale(
      saleId: saleId,
      initialPaymentMinorUnits: 2500,
    );
  }

  Future<void> pumpTestApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('permite cancelar una venta confirmada y conserva sus pagos', (
    tester,
  ) async {
    await seedSale();
    await pumpTestApp(tester);

    try {
      expect(find.text('Detalle de venta'), findsOneWidget);
      expect(find.text('Cancelar venta'), findsOneWidget);

      // Abrir el diálogo de cancelación.
      final cancelButton = find.text('Cancelar venta');
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await pumpUi(tester);

      expect(find.text('Motivo de cancelación'), findsOneWidget);

      // El motivo es obligatorio.
      final confirmButton = find.widgetWithText(
        FilledButton,
        'Confirmar cancelación',
      );

      expect(confirmButton, findsOneWidget);
      expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

      // Introducir el motivo.
      await tester.enterText(
        find.byType(TextField),
        'Cancelación solicitada por el cliente',
      );
      await pumpUi(tester);

      expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);

      // Confirmar la cancelación.
      await tester.tap(confirmButton);
      await pumpUi(tester);
      await pumpUi(tester);

      // Verificar persistencia de la venta.
      final sale = await repository.findById(saleId);

      expect(sale, isNotNull);
      expect(sale!.status, 'cancelled');
      expect(sale.cancelledAt, isNotNull);
      expect(sale.cancellationReason, 'Cancelación solicitada por el cliente');

      // Verificar reposición del inventario.
      final balance =
          await (database.select(database.inventoryBalances)
                ..where((row) => row.productId.equals('product-widget-test')))
              .getSingle();

      expect(balance.quantityMilliUnits, 5000);

      // Verificar que el pago histórico permanece intacto.
      final payments = await repository.getPayments(saleId);

      expect(payments, hasLength(1));
      expect(payments.single.appliedAmountMinorUnits, 2500);

      // Una venta cancelada ya no ofrece acciones de cancelación.
      await pumpUi(tester);

      expect(find.text('Cancelar venta'), findsNothing);
      expect(find.text('Registrar abono'), findsNothing);
    } finally {
      // Desmontar la interfaz y liberar las suscripciones de los widgets.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Cerrar el router después de desmontar la interfaz.
      router.dispose();

      // Liberar Riverpod y cerrar Drift fuera del reloj simulado.
      await tester.runAsync(() async {
        container.dispose();
        await database.close().timeout(const Duration(seconds: 10));
      });

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}
