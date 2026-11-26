import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_receipt_repository.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/purchase_detail_page.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository purchaseRepository;
  late PurchaseReceiptRepository receiptRepository;
  late SupplierRepository supplierRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    purchaseRepository = PurchaseRepository(database);
    receiptRepository = PurchaseReceiptRepository(database);
    supplierRepository = SupplierRepository(database);
  });

  Future<void> insertBaseCurrency() async {
    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'CUP',
            name: 'Peso cubano',
            symbol: '\$',
            isBase: const Value(true),
          ),
        );
  }

  Future<void> pumpDetailPage(WidgetTester tester, String purchaseId) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(body: PurchaseDetailPage(purchaseId: purchaseId)),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> settleUpdates(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> disposeDatabase(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
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

  testWidgets('muestra compra confirmada, producto y recepción parcial', (
    tester,
  ) async {
    try {
      await insertBaseCurrency();

      final supplierId = await supplierRepository.createSupplier(
        name: 'Proveedor principal',
      );

      final purchaseId = await purchaseRepository.createDraft(
        supplierId: supplierId,
        purchaseDate: DateTime(2026, 1, 15),
        currencyCode: 'CUP',
        documentNumber: 'FAC-DETAIL',
      );

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-detail',
              sku: 'SKU-DETAIL',
              name: 'Producto de prueba',
            ),
          );

      final detailId = await purchaseRepository.addDetail(
        purchaseId: purchaseId,
        productId: 'product-detail',
        quantityMilliUnits: 10000,
        unitCostMinorUnits: 1000,
      );

      await purchaseRepository.confirmPurchase(purchaseId);

      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: detailId,
            quantityMilliUnits: 4000,
          ),
        ],
        receivedAt: DateTime(2026, 1, 16),
        reference: 'REC-001',
      );

      await pumpDetailPage(tester, purchaseId);

      expect(find.textContaining('FAC-DETAIL'), findsOneWidget);
      expect(find.text('Confirmada'), findsNWidgets(2));
      expect(find.text('Proveedor principal'), findsOneWidget);
      expect(find.text('Producto de prueba'), findsOneWidget);
      expect(find.textContaining('Solicitado: 10'), findsOneWidget);
      expect(find.textContaining('Recibido: 4'), findsOneWidget);
      expect(find.textContaining('Pendiente: 6'), findsOneWidget);
      expect(find.text('Recepciones'), findsOneWidget);
      expect(
        find.text('Referencia: REC-001', skipOffstage: false),
        findsOneWidget,
      );
    } finally {
      await disposeDatabase(tester);
    }
  });

  testWidgets('actualiza cantidades recibidas al registrar otra recepción', (
    tester,
  ) async {
    try {
      await insertBaseCurrency();

      final supplierId = await supplierRepository.createSupplier(
        name: 'Proveedor principal',
      );

      final purchaseId = await purchaseRepository.createDraft(
        supplierId: supplierId,
        purchaseDate: DateTime(2026, 1, 15),
        currencyCode: 'CUP',
        documentNumber: 'FAC-REACTIVE',
      );

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-reactive',
              sku: 'SKU-REACTIVE',
              name: 'Producto reactivo',
            ),
          );

      final detailId = await purchaseRepository.addDetail(
        purchaseId: purchaseId,
        productId: 'product-reactive',
        quantityMilliUnits: 10000,
        unitCostMinorUnits: 1000,
      );

      await purchaseRepository.confirmPurchase(purchaseId);

      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: detailId,
            quantityMilliUnits: 4000,
          ),
        ],
        receivedAt: DateTime(2026, 1, 16),
        reference: 'REC-001',
      );

      await pumpDetailPage(tester, purchaseId);

      expect(find.textContaining('Recibido: 4'), findsOneWidget);
      expect(find.textContaining('Pendiente: 6'), findsOneWidget);

      await receiptRepository.createReceipt(
        purchaseId: purchaseId,
        lines: [
          PurchaseReceiptLineInput(
            purchaseDetailId: detailId,
            quantityMilliUnits: 6000,
          ),
        ],
        receivedAt: DateTime(2026, 1, 17),
        reference: 'REC-002',
      );

      await settleUpdates(tester);

      expect(find.textContaining('Recibido: 10'), findsOneWidget);
      expect(find.textContaining('Pendiente: 0'), findsOneWidget);
      expect(
        find.text('Referencia: REC-001', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Referencia: REC-002', skipOffstage: false),
        findsOneWidget,
      );
    } finally {
      await disposeDatabase(tester);
    }
  });
}
