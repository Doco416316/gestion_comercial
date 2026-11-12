import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/main_layout.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title - En construcción',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(currentLocation: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/productos',
          builder: (context, state) =>
              const PlaceholderPage(title: 'Productos'),
        ),
        GoRoute(
          path: '/inventario',
          builder: (context, state) =>
              const PlaceholderPage(title: 'Inventario'),
        ),
        GoRoute(
          path: '/compras',
          builder: (context, state) => const PlaceholderPage(title: 'Compras'),
        ),
      ],
    ),
  ],
);
