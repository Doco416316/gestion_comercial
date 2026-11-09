import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/app/app.dart';

void main() {
  testWidgets('La aplicación muestra su pantalla principal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GestionComercialApp());

    expect(find.text('Gestión Comercial'), findsOneWidget);
    expect(find.text('Sistema de Gestión Comercial'), findsOneWidget);
  });
}
