import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/data/supplier_payment_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/purchase_payment_page.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository purchaseRepository;
  late SupplierPaymentRepository paymentRepository;
  late SupplierRepository supplierRepository;
  late GoRouter router;

  final purchaseDate = DateTime(2026, 1, 15);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    purchaseRepository = PurchaseRepository(database);
    supplierRepository = SupplierRepository(database);
    paymentRepository = SupplierPaymentRepository(database);

    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Inicio')),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => Scaffold(
            body: PurchasePaymentPage(purchaseId: state.extra! as String),
          ),
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
            name: code,
            symbol: code,
            decimalDigits: Value(decimalDigits),
            isBase: Value(isBase),
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> insertBaseCurrency() {
    return insertCurrency(code: 'CUP', isBase: true);
  }

  Future<String> createConfirmedPurchase() async {
    final supplierId = await supplierRepository.createSupplier(
      name: 'Proveedor de prueba',
    );

    final purchaseId = await purchaseRepository.createDraft(
      supplierId: supplierId,
      purchaseDate: purchaseDate,
      currencyCode: 'CUP',
      documentNumber: 'FAC-PAYMENT-TEST',
    );

    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-payment-test',
            sku: 'SKU-PAYMENT-TEST',
            name: 'Producto de prueba',
          ),
        );

    await purchaseRepository.addDetail(
      purchaseId: purchaseId,
      productId: 'product-payment-test',
      quantityMilliUnits: 1000,
      unitCostMinorUnits: 10000,
    );

    await purchaseRepository.confirmPurchase(purchaseId);
    return purchaseId;
  }

  Future<void> pumpPaymentPage(WidgetTester tester, String purchaseId) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/payment', extra: purchaseId);
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

  testWidgets('muestra el resumen y el formulario de pago', (tester) async {
    try {
      await insertBaseCurrency();
      final purchaseId = await createConfirmedPurchase();

      await pumpPaymentPage(tester, purchaseId);

      expect(find.text('Registrar pago al proveedor'), findsOneWidget);
      expect(find.text('Resumen de la compra'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Pagado'), findsOneWidget);
      expect(find.text('Saldo pendiente'), findsOneWidget);
      expect(find.text('100.00 CUP'), findsNWidgets(2));
      expect(find.text('0.00 CUP'), findsOneWidget);
      expect(find.text('Moneda del pago'), findsOneWidget);
      expect(find.text('Importe'), findsOneWidget);
      expect(find.text('Método de pago'), findsOneWidget);
      expect(find.text('Registrar pago'), findsOneWidget);
    } finally {
      await disposeDatabase(tester);
    }
  });

  testWidgets('registra un pago parcial y conserva el saldo restante', (
    tester,
  ) async {
    try {
      await insertBaseCurrency();
      final purchaseId = await createConfirmedPurchase();

      await pumpPaymentPage(tester, purchaseId);

      await tester.enterText(find.byType(TextFormField).first, '25.50');
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar pago'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final payments = await paymentRepository.getByPurchase(purchaseId);

      expect(payments, hasLength(1));
      expect(payments.first.amountMinorUnits, 2550);
      expect(payments.first.currencyCode, 'CUP');
      expect(payments.first.paymentMethod, 'cash');
      expect(await paymentRepository.getPaidAmount(purchaseId), 2550);
      expect(await paymentRepository.getOutstandingBalance(purchaseId), 7450);
    } finally {
      await disposeDatabase(tester);
    }
  });
}
