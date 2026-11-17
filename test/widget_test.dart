import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/app/app.dart';
import 'package:gestion_comercial/app/router/app_router.dart';

void main() {
  setUp(() => appRouter.go('/dashboard'));

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: GestionComercialApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('En pantalla ancha muestra NavigationRail con 6 destinos', (
    tester,
  ) async {
    await pumpApp(tester, const Size(1200, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    for (final label in [
      'Inicio',
      'Productos',
      'Inventario',
      'Compras',
      'Ajustes',
      'Proveedores',
    ]) {
      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets('En pantalla estrecha muestra NavigationBar', (tester) async {
    await pumpApp(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('Navegar a Productos cambia el destino seleccionado', (
    tester,
  ) async {
    await pumpApp(tester, const Size(1200, 800));

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Productos'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 1);
  });

  testWidgets('Navegar a Proveedores cambia el destino seleccionado', (
    tester,
  ) async {
    await pumpApp(tester, const Size(1200, 800));

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Proveedores'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 5);
  });
}
