import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/app/navigation/app_shell.dart';
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
        ShellRoute(
          builder: (context, state, child) {
            return AppShell(child: child);
          },
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
        ),
      ],
    );
  });

  Future<void> pumpTestApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;

    print('APP 1: antes de montar la aplicación');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    print('APP 2: aplicación montada');

    await tester.pump();

    print('APP 3: primer pump terminado');

    await tester.pump(const Duration(milliseconds: 500));

    print('APP 4: preparación terminada');
  }

  testWidgets('permite registrar un cliente desde el formulario', (
    tester,
  ) async {
    addTearDown(() async {
      print('REG LIMPIEZA 1: cerrando router');

      router.dispose();

      print('REG LIMPIEZA 2: router cerrado');

      await database.close();

      print('REG LIMPIEZA 3: base de datos cerrada');
    });

    print('REG 1: antes de pumpTestApp');

    await pumpTestApp(tester);

    print('REG 2: después de pumpTestApp');

    await tester.tap(find.byTooltip('Registrar nuevo cliente'));

    print('REG 3: botón de registro pulsado');

    await tester.pumpAndSettle();

    print('REG 4: navegación terminada');

    expect(find.text('Nuevo cliente'), findsOneWidget);

    print('REG 5: formulario encontrado');

    await tester.enterText(find.byType(TextFormField).first, 'Ana Pérez');

    print('REG 6: nombre introducido');

    await tester.pump();

    print('REG 7: actualización visual terminada');

    final saveButton = find.text('Guardar cliente');

    await tester.ensureVisible(saveButton);

    print('REG 8: botón guardar visible');

    await tester.tap(saveButton);

    print('REG 9: botón guardar pulsado');

    await tester.pump();

    print('REG 10: primer pump después de guardar');

    await tester.pump(const Duration(seconds: 1));

    print('REG 11: segundo pump después de guardar');

    expect(find.text('Directorio de clientes'), findsOneWidget);

    expect(find.text('Ana Pérez'), findsOneWidget);

    print('REG 12: cliente visible en el directorio');

    final customers = await repository.watchAll().first;

    print('REG 13: consulta de clientes terminada');

    expect(customers, hasLength(1));
    expect(customers.single.name, 'Ana Pérez');

    print('REG 14: aserciones completadas');

    print('REG 15: antes de desmontar la aplicación');

    await tester.pumpWidget(const SizedBox.shrink());

    print('REG 16: aplicación desmontada');
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('permite editar un cliente existente', (tester) async {
    addTearDown(() async {
      print('ED LIMPIEZA 1: desmontando aplicación');

      await tester.pumpWidget(const SizedBox.shrink());

      print('ED LIMPIEZA 2: aplicación desmontada');

      router.dispose();

      print('ED LIMPIEZA 3: router cerrado');

      await database.close();

      print('ED LIMPIEZA 4: base de datos cerrada');
    });

    print('ED 1: antes de crear cliente');

    await repository.createCustomer(
      customerType: CustomerRepository.individual,
      name: 'Cliente original',
    );

    print('ED 2: cliente creado');

    await pumpTestApp(tester);

    print('ED 3: aplicación preparada');

    expect(find.text('Cliente original'), findsOneWidget);

    final actionsButton = find.byTooltip('Acciones del cliente');

    print('ED 4: antes de ensureVisible');

    await tester.ensureVisible(actionsButton);

    print('ED 5: antes de abrir acciones');

    await tester.tap(actionsButton);

    await tester.pumpAndSettle();

    print('ED 6: menú de acciones abierto');

    expect(find.text('Editar'), findsOneWidget);

    await tester.tap(find.text('Editar'));

    await tester.pumpAndSettle();

    print('ED 7: formulario de edición abierto');

    expect(find.text('Editar cliente'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Cliente actualizado',
    );

    print('ED 8: texto actualizado');

    await tester.pump();

    final saveButton = find.text('Guardar cliente');

    await tester.ensureVisible(saveButton);

    await tester.tap(saveButton);

    await tester.pumpAndSettle();

    print('ED 9: guardado terminado');

    expect(find.text('Cliente actualizado'), findsOneWidget);

    expect(find.text('Cliente original'), findsNothing);

    final customers = await repository.watchAll().first;

    print('ED 10: consulta terminada');

    expect(customers, hasLength(1));
    expect(customers.single.name, 'Cliente actualizado');

    print('ED 11: prueba de edición completada');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
