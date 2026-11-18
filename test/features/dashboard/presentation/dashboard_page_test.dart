import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.stream);

  final Stream<List<Product>> stream;

  @override
  Stream<List<Product>> watchActiveProducts() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository({required this.stream});

  final Stream<List<Supplier>> stream;

  @override
  Stream<List<Supplier>> watchAll({bool includeInactive = false}) => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository(this.stream);

  final Stream<List<Purchase>> stream;

  @override
  Stream<List<Purchase>> watchAll() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  testWidgets('muestra spinner mientras carga', (tester) async {
    final productController = StreamController<List<Product>>();
    final supplierController = StreamController<List<Supplier>>();
    final purchaseController = StreamController<List<Purchase>>();
    addTearDown(productController.close);
    addTearDown(supplierController.close);
    addTearDown(purchaseController.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(productController.stream),
          ),
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(stream: supplierController.stream),
          ),
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(purchaseController.stream),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(stream: Stream.value(const <Supplier>[])),
          ),
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(Stream.value(const <Purchase>[])),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra KPIs con datos', (tester) async {
    final product = Product(
      id: 'product-1',
      sku: 'SKU-001',
      name: 'Producto',
      description: null,
      category: null,
      unit: 'unidad',
      trackInventory: true,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final supplier = Supplier(
      id: 'supplier-1',
      name: 'Proveedor',
      taxId: null,
      phone: null,
      email: null,
      address: null,
      notes: null,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final purchase = Purchase(
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

    final confirmedPurchase = Purchase(
      id: 'purchase-2',
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
      status: 'confirmed',
      confirmedAt: DateTime(2026, 1, 1),
      cancelledAt: null,
      cancellationReason: null,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([product])),
          ),
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(stream: Stream.value([supplier])),
          ),
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(Stream.value([purchase, confirmedPurchase])),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('1'), findsNWidgets(4));
  });
}
