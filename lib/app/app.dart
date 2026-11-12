import 'package:flutter/material.dart';

// Corregido: apunta a lib/app/layout/
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GestionComercialApp extends StatelessWidget {
  const GestionComercialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestión Comercial',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
