import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/pages/purchases_page.dart';

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository(this.stream);

  final Stream<List<Purchase>> stream;

  @override
  Stream<List<Purchase>> watchAll() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  final samplePurchase = Purchase(
    id: 'purchase-1',
    supplierId: 'supplier-1',
    documentNumber: null,
    purchaseDate: DateTime(2026, 1, 1),
    currencyCode: 'USD',
    exchangeRateToBaseSnapshot: '1',
    subtotalMinorUnits: 1000,
    discountMinorUnits: 0,
    taxMinorUnits: 0,
    totalMinorUnits: 1000,
    notes: null,
    status: 'draft',
    confirmedAt: null,
    cancelledAt: null,
    cancellationReason: null,
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('muestra spinner mientras carga', (tester) async {
    final controller = StreamController<List<Purchase>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(controller.stream),
          ),
        ],
        child: const MaterialApp(home: PurchasesPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra mensaje cuando no hay compras', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(Stream.value(const <Purchase>[])),
          ),
        ],
        child: const MaterialApp(home: PurchasesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay compras'), findsOneWidget);
  });

  testWidgets('muestra error legible', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(
              Stream<List<Purchase>>.error(Exception('boom')),
            ),
          ),
        ],
        child: const MaterialApp(home: PurchasesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra lista con datos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(Stream.value([samplePurchase])),
          ),
        ],
        child: const MaterialApp(home: PurchasesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('purchase-1'), findsOneWidget);
    expect(find.text('Proveedor: supplier-1'), findsOneWidget);
    expect(find.text('Estado: draft'), findsOneWidget);
    expect(find.text('Total: 1000 USD'), findsOneWidget);
  });
}
