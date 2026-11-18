import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/app/theme/app_theme.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/customers/data/customer_repository.dart';
import 'package:gestion_comercial/features/customers/presentation/customer_form_page.dart';
import 'package:gestion_comercial/features/customers/presentation/customer_list_page.dart';

void main() {
  late AppDatabase database;
  late GoRouter router;
  late CustomerRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CustomerRepository(database);

    router = GoRouter(
      initialLocation: '/customers',
      routes: [
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerListPage(),
        ),
        GoRoute(
          path: '/customers/new',
          builder: (context, state) => const CustomerFormPage(),
        ),
        GoRoute(
          path: '/customers/edit',
          builder: (context, state) {
            final customer = state.extra;

            if (customer is! Customer) {
              return const Scaffold(body: Text('Cliente no disponible'));
            }

            return CustomerFormPage(customer: customer);
          },
        ),
      ],
    );
  });

  Future<void> pumpTestApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          builder: (context, child) {
            return Scaffold(body: child ?? const SizedBox.shrink());
          },
        ),
      ),
    );

    // Procesa la carga inicial del StreamProvider y el primer render.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<List<Customer>> readCustomers() async {
    return database.select(database.customers).get();
  }

  Future<void> disposeTestApp(WidgetTester tester) async {
    // Primero desmontamos los widgets para cancelar las suscripciones.
    await tester.pumpWidget(const SizedBox.shrink());

    // Procesamos las cancelaciones pendientes de Drift/Riverpod.
    await tester.pump(const Duration(milliseconds: 1));

    // Cerramos el router después de desmontar la aplicación.
    router.dispose();

    // La base de datos se cierra fuera del FakeAsync de testWidgets.
    await tester.runAsync(() async {
      await database.close().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'La base de datos no terminó de cerrarse en 10 segundos.',
          );
        },
      );
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('muestra la lista de clientes sin errores', (tester) async {
    await pumpTestApp(tester);

    expect(find.byType(CustomerListPage), findsOneWidget);
    expect(find.text('Directorio de clientes'), findsOneWidget);

    await disposeTestApp(tester);
  });

  testWidgets('permite registrar un cliente desde el formulario', (
    tester,
  ) async {
    await pumpTestApp(tester);

    // Abrir formulario de registro.
    final registerButton = find.byIcon(Icons.person_add_alt_1_outlined);

    expect(registerButton, findsOneWidget);

    await tester.tap(registerButton);
    await pumpUi(tester);

    expect(find.text('Nuevo cliente'), findsOneWidget);

    // Introducir nombre.
    await tester.enterText(find.byType(TextFormField).first, 'Ana Pérez');

    await pumpUi(tester);

    // Guardar.
    final saveButton = find.text('Guardar cliente');

    expect(saveButton, findsOneWidget);

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    // Procesar la operación asíncrona y el regreso a la lista.
    await pumpUi(tester);
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar persistencia directamente en Drift.
    final customers = await readCustomers();

    expect(customers, hasLength(1));
    expect(customers.single.name, 'Ana Pérez');

    // Procesar la notificación del StreamProvider real.
    await pumpUi(tester);

    expect(find.text('Directorio de clientes'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);

    await disposeTestApp(tester);
  });

  testWidgets('permite editar un cliente existente', (tester) async {
    // Crear el registro inicial directamente en la base de datos.
    await repository.createCustomer(
      customerType: CustomerRepository.individual,
      name: 'Cliente original',
    );

    await pumpTestApp(tester);

    // El proveedor real debe mostrar el registro inicial.
    await pumpUi(tester);

    expect(find.text('Cliente original'), findsOneWidget);

    // Abrir menú de acciones.
    final actionsButton = find.byTooltip('Acciones del cliente');

    expect(actionsButton, findsOneWidget);

    await tester.ensureVisible(actionsButton);
    await tester.tap(actionsButton);
    await pumpUi(tester);

    expect(find.text('Editar'), findsOneWidget);

    // Abrir edición.
    await tester.tap(find.text('Editar'));
    await pumpUi(tester);

    expect(find.text('Editar cliente'), findsOneWidget);

    // Cambiar nombre.
    await tester.enterText(
      find.byType(TextFormField).first,
      'Cliente actualizado',
    );

    await pumpUi(tester);

    // Guardar cambios.
    final saveButton = find.text('Guardar cliente');

    expect(saveButton, findsOneWidget);

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await pumpUi(tester);
    await tester.pump(const Duration(milliseconds: 300));

    // Verificar persistencia.
    final customers = await readCustomers();

    expect(customers, hasLength(1));
    expect(customers.single.name, 'Cliente actualizado');

    // Verificar actualización visual.
    await pumpUi(tester);

    expect(find.text('Cliente actualizado'), findsOneWidget);
    expect(find.text('Cliente original'), findsNothing);

    await disposeTestApp(tester);
  });
}
