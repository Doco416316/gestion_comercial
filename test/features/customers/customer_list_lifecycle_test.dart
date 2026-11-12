import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gestion_comercial/app/navigation/app_shell.dart';
import 'package:gestion_comercial/app/theme/app_theme.dart';
import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/core/providers/database_provider.dart';
import 'package:gestion_comercial/features/customers/presentation/customer_form_page.dart';
import 'package:gestion_comercial/features/customers/presentation/customer_list_page.dart';

void main() {
  testWidgets('navega al formulario y regresa sin bloquear la limpieza', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    final router = GoRouter(
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
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CustomerFormPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    print('NAV 1: recursos creados');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    print('NAV 2: lista preparada');

    router.push('/customers/new');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    print('NAV 3: formulario abierto');

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    print('NAV 4: regreso a la lista');

    await tester.pumpWidget(const SizedBox.shrink());
    print('NAV 5: aplicación desmontada');

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    print('NAV 6: ciclos de limpieza completados');

    router.dispose();
    print('NAV 7: router cerrado');

    await database.close();
    print('NAV 8: base de datos cerrada');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
