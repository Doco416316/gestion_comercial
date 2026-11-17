import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/settings/data/currency_repository.dart';
import 'package:gestion_comercial/features/settings/presentation/pages/currencies_page.dart';

class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository({
    required this.stream,
    this.onCreate,
    this.onSetActive,
    this.onSetBase,
  });

  final Stream<List<Currency>> stream;
  final Future<void> Function(String code, String name, String symbol)?
  onCreate;
  final Future<void> Function(String code, bool active)? onSetActive;
  final Future<void> Function(String code)? onSetBase;

  final List<({String code, String name, String symbol})> createCalls = [];
  final List<({String code, bool active})> activeCalls = [];
  final List<String> baseCalls = [];

  @override
  Stream<List<Currency>> watchAll() => stream;

  @override
  Future<Currency?> findByCode(String code) => throw UnimplementedError();

  @override
  Future<void> create({
    required String code,
    required String name,
    required String symbol,
  }) async {
    createCalls.add((code: code, name: name, symbol: symbol));
    await onCreate?.call(code, name, symbol);
  }

  @override
  Future<void> setActive(String code, bool active) async {
    activeCalls.add((code: code, active: active));
    await onSetActive?.call(code, active);
  }

  @override
  Future<void> setBaseCurrency(String code) async {
    baseCalls.add(code);
    await onSetBase?.call(code);
  }
}

void main() {
  final baseCurrency = Currency(
    code: 'USD',
    name: 'Dólar estadounidense',
    symbol: '\$',
    decimalDigits: 2,
    isActive: true,
    isBase: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final nonBaseCurrency = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: 'EUR',
    decimalDigits: 2,
    isActive: true,
    isBase: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final inactiveCurrency = Currency(
    code: 'CUP',
    name: 'Peso cubano',
    symbol: 'CUP',
    decimalDigits: 2,
    isActive: false,
    isBase: false,
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('muestra spinner mientras carga', (tester) async {
    final controller = StreamController<List<Currency>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: controller.stream),
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
            FakeCurrencyRepository(stream: Stream.value(const <Currency>[])),
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
              stream: Stream<List<Currency>>.error(Exception('boom')),
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
            FakeCurrencyRepository(stream: Stream.value([baseCurrency])),
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

  testWidgets('abre diálogo de creación', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value(const <Currency>[])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Símbolo'), findsOneWidget);
  });

  testWidgets('Guardar deshabilitado si campos vacíos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value(const <Currency>[])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Código'), 'EUR');
    await tester.pump();

    final button2 = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(button2.onPressed, isNull);
  });

  testWidgets('crea moneda exitosamente', (tester) async {
    final fake = FakeCurrencyRepository(
      stream: Stream.value(const <Currency>[]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Código'), 'EUR');
    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Euro');
    await tester.enterText(find.widgetWithText(TextField, 'Símbolo'), 'EUR');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(fake.createCalls, hasLength(1));
    expect(fake.createCalls.first.code, 'EUR');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Moneda creada'), findsOneWidget);
  });

  testWidgets('error al crear moneda', (tester) async {
    final fake = FakeCurrencyRepository(
      stream: Stream.value(const <Currency>[]),
      onCreate: (_, _, _) async {
        throw ArgumentError('bad');
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Código'), 'EUR');
    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Euro');
    await tester.enterText(find.widgetWithText(TextField, 'Símbolo'), 'EUR');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('bad'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('cambia switch de moneda', (tester) async {
    final fake = FakeCurrencyRepository(
      stream: Stream.value([nonBaseCurrency]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(fake.activeCalls, hasLength(1));
    expect(fake.activeCalls.first.code, 'EUR');
    expect(fake.activeCalls.first.active, isFalse);
  });

  testWidgets('switch de moneda base deshabilitado', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([baseCurrency])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.onChanged, isNull);
  });

  testWidgets('switch deshabilitado durante operación', (tester) async {
    final completer = Completer<void>();
    final fake = FakeCurrencyRepository(
      stream: Stream.value([nonBaseCurrency]),
      onSetActive: (_, _) => completer.future,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pump();

    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.onChanged, isNull);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('marca moneda como base', (tester) async {
    final fake = FakeCurrencyRepository(
      stream: Stream.value([nonBaseCurrency]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Marcar como base'));
    await tester.pumpAndSettle();

    expect(fake.baseCalls, ['EUR']);
    expect(find.text('Moneda base actualizada'), findsOneWidget);
  });

  testWidgets('botón base deshabilitado si moneda inactiva', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository(stream: Stream.value([inactiveCurrency])),
          ),
        ],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Marcar como base'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('botón base deshabilitado durante operación', (tester) async {
    final completer = Completer<void>();
    final fake = FakeCurrencyRepository(
      stream: Stream.value([nonBaseCurrency]),
      onSetBase: (_) => completer.future,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: CurrenciesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Marcar como base'));
    await tester.pump();

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Marcar como base'),
    );
    expect(button.onPressed, isNull);

    completer.complete();
    await tester.pumpAndSettle();
  });
}
