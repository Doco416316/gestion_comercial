import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    router.push('/customers/new');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(const SizedBox.shrink());

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));

    router.dispose();
    await database.close();
  }, timeout: const Timeout(Duration(seconds: 30)));
}
