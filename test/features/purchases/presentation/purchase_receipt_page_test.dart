import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_receipt_repository.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/pages/purchase_receipt_page.dart';

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository({this.purchase, this.details = const []});

  final Purchase? purchase;
  final List<PurchaseDetail> details;

  @override
  Future<Purchase?> findById(String purchaseId) async => purchase;

  @override
  Future<List<PurchaseDetail>> getDetails(String purchaseId) async => details;

  @override
  Stream<List<Purchase>> watchAll() => Stream.value(
    purchase == null ? const <Purchase>[] : <Purchase>[purchase!],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakePurchaseReceiptRepository implements PurchaseReceiptRepository {
  FakePurchaseReceiptRepository({
    this.received = const {},
    this.receipts = const [],
  });

  final Map<String, int> received;
  final List<PurchaseReceipt> receipts;

  final List<CreateReceiptCall> createCalls = [];

  @override
  Future<Map<String, int>> getReceivedQuantities(String purchaseId) async =>
      received;

  @override
  Future<String> createReceipt({
    required String purchaseId,
    required List<PurchaseReceiptLineInput> lines,
    DateTime? receivedAt,
    String? reference,
    String? notes,
  }) async {
    createCalls.add(CreateReceiptCall(purchaseId: purchaseId, lines: lines));
    return 'receipt-new';
  }

  @override
  Future<List<PurchaseReceipt>> getByPurchase(String purchaseId) async =>
      receipts;

  @override
  Future<List<PurchaseReceiptDetail>> getReceiptDetails(
    String receiptId,
  ) async => const <PurchaseReceiptDetail>[];

  @override
  Stream<List<PurchaseReceipt>> watchByPurchase(String purchaseId) =>
      Stream.value(receipts);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class CreateReceiptCall {
  CreateReceiptCall({required this.purchaseId, required this.lines});

  final String purchaseId;
  final List<PurchaseReceiptLineInput> lines;
}

void main() {
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
    status: 'confirmed',
    confirmedAt: DateTime(2026, 1, 1),
    cancelledAt: null,
    cancellationReason: null,
    createdAt: DateTime(2026, 1, 1),
  );

  final detail = PurchaseDetail(
    id: 'detail-1',
    purchaseId: 'purchase-1',
    productId: 'product-1',
    skuSnapshot: 'SKU-001',
    productNameSnapshot: 'Producto',
    unitSnapshot: 'unidad',
    quantityMilliUnits: 1000,
    unitCostMinorUnits: 100,
    discountMinorUnits: 0,
    discountType: 'fixed',
    discountRate: null,
    taxMinorUnits: 0,
    taxType: 'fixed',
    taxRate: null,
    totalMinorUnits: 1000,
  );

  testWidgets('abre pantalla de recepción', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(purchase: purchase, details: [detail]),
          ),
          purchaseReceiptRepositoryProvider.overrideWithValue(
            FakePurchaseReceiptRepository(),
          ),
        ],
        child: const MaterialApp(
          home: PurchaseReceiptPage(purchaseId: 'purchase-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Recepción de compra'), findsOneWidget);
    expect(find.text('Producto'), findsOneWidget);
  });
}
