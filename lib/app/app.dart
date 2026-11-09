import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';

class GestionComercialApp extends StatelessWidget {
  const GestionComercialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
      ],
    );

    return MaterialApp.router(
      title: 'Gestión Comercial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión Comercial',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          'Sistema de Gestión Comercial',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
