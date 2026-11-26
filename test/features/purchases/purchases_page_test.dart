import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/purchases_page.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late PurchaseRepository repository;
  late SupplierRepository supplierRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PurchaseRepository(database);
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

  Future<String> createPurchase({
    required String supplierId,
    required String documentNumber,
    DateTime? date,
  }) {
    return repository.createDraft(
      supplierId: supplierId,
      purchaseDate: date ?? DateTime(2026, 1, 15),
      currencyCode: 'CUP',
      documentNumber: documentNumber,
    );
  }

  Future<void> createConfirmedPurchase(String purchaseId) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-$purchaseId',
            sku: 'SKU-${purchaseId.toUpperCase()}',
            name: 'Producto de prueba',
          ),
        );

    await repository.addDetail(
      purchaseId: purchaseId,
      productId: 'product-$purchaseId',
      quantityMilliUnits: 1000,
      unitCostMinorUnits: 1000,
    );

    await repository.confirmPurchase(purchaseId);
  }

  Future<void> pumpPurchasesPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: const Scaffold(body: PurchasesPage())),
      ),
    );

    await tester.pump();
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

  testWidgets('muestra correctamente el estado inicial de Compras', (
    tester,
  ) async {
    try {
      await pumpPurchasesPage(tester);

      expect(find.text('Compras'), findsOneWidget);
      expect(find.text('0 registros'), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Borradores'), findsOneWidget);
      expect(find.text('Confirmadas'), findsOneWidget);
      expect(find.text('Anuladas'), findsOneWidget);
      expect(find.text('Todavía no hay compras'), findsOneWidget);
      expect(
        find.text('Las compras que registres aparecerán aquí.'),
        findsOneWidget,
      );
    } finally {
      await disposeDatabase(tester);
    }
  });

  testWidgets('lista compras y filtra correctamente por estado', (
    tester,
  ) async {
    try {
      await insertBaseCurrency();

      final supplierId = await supplierRepository.createSupplier(
        name: 'Proveedor principal',
      );

      await createPurchase(supplierId: supplierId, documentNumber: 'FAC-DRAFT');

      final confirmedId = await createPurchase(
        supplierId: supplierId,
        documentNumber: 'FAC-CONF',
        date: DateTime(2026, 2, 10),
      );

      await createConfirmedPurchase(confirmedId);

      final cancelledId = await createPurchase(
        supplierId: supplierId,
        documentNumber: 'FAC-CANCEL',
        date: DateTime(2026, 3, 10),
      );

      await createConfirmedPurchase(cancelledId);

      await repository.cancelPurchase(
        purchaseId: cancelledId,
        reason: 'Anulación de prueba',
      );

      await pumpPurchasesPage(tester);

      // Todas las compras.
      expect(find.text('3 registros'), findsOneWidget);
      expect(find.text('Compra FAC-DRAFT'), findsOneWidget);
      expect(find.text('Compra FAC-CONF'), findsOneWidget);
      expect(find.text('Compra FAC-CANCEL'), findsOneWidget);
      expect(find.textContaining('Proveedor principal'), findsNWidgets(3));

      // Borradores.
      await tester.tap(find.text('Borradores'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Compra FAC-DRAFT'), findsOneWidget);
      expect(find.text('Compra FAC-CONF'), findsNothing);
      expect(find.text('Compra FAC-CANCEL'), findsNothing);

      // Confirmadas.
      await tester.tap(find.text('Confirmadas'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Compra FAC-CONF'), findsOneWidget);
      expect(find.text('Compra FAC-DRAFT'), findsNothing);
      expect(find.text('Compra FAC-CANCEL'), findsNothing);

      // Anuladas.
      await tester.tap(find.text('Anuladas'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Compra FAC-CANCEL'), findsOneWidget);
      expect(find.text('Compra FAC-DRAFT'), findsNothing);
      expect(find.text('Compra FAC-CONF'), findsNothing);
    } finally {
      await disposeDatabase(tester);
    }
  });
}
