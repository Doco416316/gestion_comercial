import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/domain/purchase_calculation_service.dart';
import 'package:gestion_comercial/features/purchases/presentation/pages/purchase_form_page.dart';
import 'package:gestion_comercial/features/settings/data/currency_repository.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository({required this.stream});

  final Stream<List<Supplier>> stream;

  @override
  Stream<List<Supplier>> watchAll({bool includeInactive = false}) => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository({required this.stream});

  final Stream<List<Currency>> stream;

  @override
  Stream<List<Currency>> watchAll() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.stream);

  final Stream<List<Product>> stream;

  @override
  Stream<List<Product>> watchActiveProducts() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository({this.purchase, this.details = const []});

  final Purchase? purchase;
  final List<PurchaseDetail> details;

  @override
  Future<Purchase?> findById(String purchaseId) async => purchase;

  @override
  Future<List<PurchaseDetail>> getDetails(String purchaseId) async => details;

  @override
  Future<String> createDraft({
    required String supplierId,
    required DateTime purchaseDate,
    required String currencyCode,
    String? documentNumber,
    String? notes,
  }) async => 'purchase-new';

  @override
  Future<void> updateDraftHeader({
    required String purchaseId,
    required String supplierId,
    required DateTime purchaseDate,
    required String currencyCode,
    String? documentNumber,
    String? notes,
  }) async {}

  @override
  Future<String> addDetail({
    required String purchaseId,
    required String productId,
    required int quantityMilliUnits,
    required int unitCostMinorUnits,
    PurchaseAdjustmentInput discount = const PurchaseAdjustmentInput.fixed(0),
    PurchaseAdjustmentInput tax = const PurchaseAdjustmentInput.fixed(0),
  }) async => 'detail-new';

  @override
  Future<void> removeDetail({
    required String purchaseId,
    required String detailId,
  }) async {}

  @override
  Future<void> confirmPurchase(String purchaseId) async {}

  @override
  Future<void> cancelPurchase({
    required String purchaseId,
    required String reason,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
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

  final currency = Currency(
    code: 'USD',
    name: 'Dólar',
    symbol: '\$',
    decimalDigits: 2,
    isActive: true,
    isBase: true,
    createdAt: DateTime(2026, 1, 1),
  );

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

  testWidgets('abre formulario de nueva compra', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(stream: Stream.value([supplier])),
          ),
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([currency])),
          ),
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(Stream.value([product])),
          ),
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(),
          ),
        ],
        child: const MaterialApp(home: PurchaseFormPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nueva compra'), findsOneWidget);
  });
}
