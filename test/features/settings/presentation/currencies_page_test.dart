import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/settings/data/currency_repository.dart';
import 'package:gestion_comercial/features/settings/presentation/pages/currencies_page.dart';

class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository(this.stream);

  final Stream<List<Currency>> stream;

  @override
  Stream<List<Currency>> watchAll() => stream;

  @override
  Future<Currency?> findByCode(String code) => throw UnimplementedError();

  @override
  Future<void> create({
    required String code,
    required String name,
    required String symbol,
  }) => throw UnimplementedError();

  @override
  Future<void> setActive(String code, bool active) =>
      throw UnimplementedError();

  @override
  Future<void> setBaseCurrency(String code) => throw UnimplementedError();
}

void main() {
  final sampleCurrency = Currency(
    code: 'USD',
    name: 'Dólar estadounidense',
    symbol: '\$',
    decimalDigits: 2,
    isActive: true,
    isBase: true,
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('muestra spinner mientras carga', (tester) async {
    final controller = StreamController<List<Currency>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(controller.stream),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra mensaje cuando no hay monedas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(Stream.value(const <Currency>[])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay monedas'), findsOneWidget);
  });

  testWidgets('muestra error legible', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(
              Stream<List<Currency>>.error(Exception('boom')),
            ),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra lista con datos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(Stream.value([sampleCurrency])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('Dólar estadounidense'), findsOneWidget);
    expect(find.text('\$'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
  });
}
