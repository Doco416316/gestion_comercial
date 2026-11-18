import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/purchases/data/purchase_repository.dart';
import 'package:gestion_comercial/features/purchases/data/supplier_payment_repository.dart';
import 'package:gestion_comercial/features/purchases/presentation/pages/supplier_payment_page.dart';
import 'package:gestion_comercial/features/settings/data/currency_repository.dart';

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository({this.purchase});

  final Purchase? purchase;

  @override
  Future<Purchase?> findById(String purchaseId) async => purchase;

  @override
  Stream<List<Purchase>> watchAll() => Stream.value(
    purchase == null ? const <Purchase>[] : <Purchase>[purchase!],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeSupplierPaymentRepository implements SupplierPaymentRepository {
  FakeSupplierPaymentRepository({
    this.paidAmount = 0,
    this.outstandingBalance = 0,
    this.onRegister,
  });

  final int paidAmount;
  final int outstandingBalance;
  final Future<String> Function({
    required String purchaseId,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime paymentDate,
    required String paymentMethod,
    String? reference,
    String? notes,
  })?
  onRegister;

  final List<RegisterPaymentCall> registerCalls = [];

  @override
  Future<int> getPaidAmount(String purchaseId) async => paidAmount;

  @override
  Future<int> getOutstandingBalance(String purchaseId) async =>
      outstandingBalance;

  @override
  Future<String> registerPayment({
    required String purchaseId,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime paymentDate,
    required String paymentMethod,
    String? reference,
    String? notes,
  }) async {
    registerCalls.add(
      RegisterPaymentCall(
        purchaseId: purchaseId,
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
      ),
    );
    if (onRegister != null) {
      return onRegister!(
        purchaseId: purchaseId,
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        reference: reference,
        notes: notes,
      );
    }
    return 'payment-id';
  }

  @override
  Future<List<SupplierPayment>> getByPurchase(String purchaseId) async =>
      const <SupplierPayment>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class RegisterPaymentCall {
  RegisterPaymentCall({
    required this.purchaseId,
    required this.amountMinorUnits,
    required this.currencyCode,
  });

  final String purchaseId;
  final int amountMinorUnits;
  final String currencyCode;
}

class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository({required this.stream});

  final Stream<List<Currency>> stream;

  @override
  Stream<List<Currency>> watchAll() => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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

  final currency = Currency(
    code: 'USD',
    name: 'Dólar',
    symbol: '\$',
    decimalDigits: 2,
    isActive: true,
    isBase: true,
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('abre pantalla de pagos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(purchase: purchase),
          ),
          supplierPaymentRepositoryProvider.overrideWithValue(
            FakeSupplierPaymentRepository(outstandingBalance: 1000),
          ),
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([currency])),
          ),
        ],
        child: const MaterialApp(
          home: SupplierPaymentPage(purchaseId: 'purchase-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pagos a proveedores'), findsOneWidget);
    expect(find.text('Saldo pendiente: 1000'), findsOneWidget);
  });

  testWidgets('registra pago', (tester) async {
    final fakePayment = FakeSupplierPaymentRepository(outstandingBalance: 1000);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(purchase: purchase),
          ),
          supplierPaymentRepositoryProvider.overrideWithValue(fakePayment),
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([currency])),
          ),
        ],
        child: const MaterialApp(
          home: SupplierPaymentPage(purchaseId: 'purchase-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Monto (unidades menores)'),
      '500',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Método de pago'),
      'Efectivo',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pago'));
    await tester.pumpAndSettle();

    expect(fakePayment.registerCalls, hasLength(1));
    expect(fakePayment.registerCalls.single.amountMinorUnits, 500);
    expect(find.text('Pago registrado'), findsOneWidget);
  });

  testWidgets('error al pagar más del saldo', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(
            FakePurchaseRepository(purchase: purchase),
          ),
          supplierPaymentRepositoryProvider.overrideWithValue(
            FakeSupplierPaymentRepository(outstandingBalance: 100),
          ),
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([currency])),
          ),
        ],
        child: const MaterialApp(
          home: SupplierPaymentPage(purchaseId: 'purchase-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Monto (unidades menores)'),
      '200',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Método de pago'),
      'Efectivo',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pago'));
    await tester.pumpAndSettle();

    expect(
      find.text('El monto supera el saldo pendiente (100)'),
      findsOneWidget,
    );
  });
}
