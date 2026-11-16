import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/customers/presentation/customer_list_page.dart';
import 'navigation/app_shell.dart';
import 'navigation/placeholder_page.dart';
import 'theme/app_theme.dart';

import '../features/customers/presentation/customer_form_page.dart';
import '../core/database/app_database.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PlaceholderPage(
            title: 'Gestión Comercial',
            description: 'Panel principal del sistema.',
            icon: Icons.dashboard_outlined,
          ),
        ),
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
              return const PlaceholderPage(
                title: 'Cliente no disponible',
                description: 'No se recibieron los datos del cliente.',
                icon: Icons.error_outline,
              );
            }

            return CustomerFormPage(customer: customer);
          },
        ),
        GoRoute(
          path: '/suppliers',
          builder: (context, state) => const PlaceholderPage(
            title: 'Proveedores',
            description: 'Administración de proveedores.',
            icon: Icons.local_shipping_outlined,
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const PlaceholderPage(
            title: 'Productos',
            description: 'Catálogo y gestión de productos.',
            icon: Icons.inventory_2_outlined,
          ),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const PlaceholderPage(
            title: 'Inventario',
            description: 'Existencias y movimientos de inventario.',
            icon: Icons.warehouse_outlined,
          ),
        ),
        GoRoute(
          path: '/purchases',
          builder: (context, state) => const PlaceholderPage(
            title: 'Compras',
            description: 'Compras, recepciones y pagos a proveedores.',
            icon: Icons.shopping_cart_outlined,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const PlaceholderPage(
            title: 'Configuración',
            description: 'Preferencias y parámetros del sistema.',
            icon: Icons.settings_outlined,
          ),
        ),
      ],
    ),
  ],
);

class GestionComercialApp extends StatelessWidget {
  const GestionComercialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestión Comercial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
