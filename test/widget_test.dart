import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/app/app.dart';

void main() {
  testWidgets('La aplicación muestra el panel principal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GestionComercialApp());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Panel principal del sistema.'), findsOneWidget);
  });
}
