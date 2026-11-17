import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/app/providers/database_providers.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';
import 'package:gestion_comercial/features/suppliers/presentation/pages/suppliers_page.dart';

class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository({required this.streamFactory, this.onSearch});

  final Stream<List<Supplier>> Function() streamFactory;
  final Future<List<Supplier>> Function(String query)? onSearch;

  final List<String> searchCalls = <String>[];

  @override
  Stream<List<Supplier>> watchAll({bool includeInactive = false}) =>
      streamFactory();

  @override
  Future<List<Supplier>> search(String query, {bool includeInactive = false}) {
    searchCalls.add(query);
    return onSearch?.call(query) ?? Future.value(const <Supplier>[]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  final fullSupplier = Supplier(
    id: 'supplier-1',
    name: 'Distribuidora Central',
    taxId: 'ABC-123',
    phone: '555-1234',
    email: 'contacto@example.com',
    address: null,
    notes: null,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final minimalSupplier = Supplier(
    id: 'supplier-2',
    name: 'Proveedor sin datos',
    taxId: null,
    phone: null,
    email: null,
    address: null,
    notes: null,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final otherSupplier = Supplier(
    id: 'supplier-3',
    name: 'Comercial del Norte',
    taxId: 'XYZ-999',
    phone: null,
    email: null,
    address: null,
    notes: null,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Future<void> pumpPage(
    WidgetTester tester,
    FakeSupplierRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supplierRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SuppliersPage()),
      ),
    );
  }

  testWidgets('muestra spinner mientras carga', (tester) async {
    final controller = StreamController<List<Supplier>>();
    addTearDown(controller.close);

    await pumpPage(
      tester,
      FakeSupplierRepository(streamFactory: () => controller.stream),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('muestra mensaje cuando no hay proveedores', (tester) async {
    await pumpPage(
      tester,
      FakeSupplierRepository(
        streamFactory: () => Stream.value(const <Supplier>[]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay proveedores'), findsOneWidget);
  });

  testWidgets('muestra error legible', (tester) async {
    await pumpPage(
      tester,
      FakeSupplierRepository(
        streamFactory: () => Stream<List<Supplier>>.error(Exception('boom')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('muestra lista con datos', (tester) async {
    await pumpPage(
      tester,
      FakeSupplierRepository(
        streamFactory: () => Stream.value([fullSupplier, minimalSupplier]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Distribuidora Central'), findsOneWidget);
    expect(find.text('Tax ID: ABC-123'), findsOneWidget);
    expect(find.text('Teléfono: 555-1234'), findsOneWidget);
    expect(find.text('Email: contacto@example.com'), findsOneWidget);
    expect(find.text('Proveedor sin datos'), findsOneWidget);
    expect(find.textContaining('Tax ID:'), findsOneWidget);
    expect(find.textContaining('Teléfono:'), findsOneWidget);
    expect(find.textContaining('Email:'), findsOneWidget);
  });

  testWidgets('busca por nombre usando el repositorio', (tester) async {
    final repository = FakeSupplierRepository(
      streamFactory: () => Stream.value([fullSupplier, otherSupplier]),
      onSearch: (_) => Future.value([fullSupplier]),
    );

    await pumpPage(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();

    expect(repository.searchCalls, ['Central']);
    expect(find.text('Distribuidora Central'), findsOneWidget);
    expect(find.text('Comercial del Norte'), findsNothing);
  });

  testWidgets('busca por identificación fiscal', (tester) async {
    final repository = FakeSupplierRepository(
      streamFactory: () => Stream.value([fullSupplier, otherSupplier]),
      onSearch: (_) => Future.value([fullSupplier]),
    );

    await pumpPage(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ABC-123');
    await tester.pumpAndSettle();

    expect(repository.searchCalls, ['ABC-123']);
    expect(find.text('Tax ID: ABC-123'), findsOneWidget);
    expect(find.text('Comercial del Norte'), findsNothing);
  });

  testWidgets('muestra mensaje cuando la búsqueda no tiene resultados', (
    tester,
  ) async {
    await pumpPage(
      tester,
      FakeSupplierRepository(
        streamFactory: () => Stream.value([fullSupplier]),
        onSearch: (_) => Future.value(const <Supplier>[]),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron proveedores'), findsOneWidget);
    expect(find.text('Distribuidora Central'), findsNothing);
  });

  testWidgets('muestra error legible en la búsqueda', (tester) async {
    final completer = Completer<List<Supplier>>();

    await pumpPage(
      tester,
      FakeSupplierRepository(
        streamFactory: () => Stream.value([fullSupplier]),
        onSearch: (_) => completer.future,
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pump();
    completer.completeError(Exception('boom'));
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('limpia la búsqueda y vuelve al listado general', (tester) async {
    final repository = FakeSupplierRepository(
      streamFactory: () => Stream.value([fullSupplier, otherSupplier]),
      onSearch: (_) => Future.value([fullSupplier]),
    );

    await pumpPage(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();
    expect(find.text('Comercial del Norte'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(repository.searchCalls, ['Central']);
    expect(find.text('Distribuidora Central'), findsOneWidget);
    expect(find.text('Comercial del Norte'), findsOneWidget);
  });
}
