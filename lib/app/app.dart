import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/database/app_database.dart';
import '../features/customers/presentation/customer_form_page.dart';
import '../features/customers/presentation/customer_list_page.dart';
import '../features/inventory/presentation/inventory_page.dart';
import '../features/products/presentation/product_form_page.dart';
import '../features/products/presentation/product_list_page.dart';
import '../features/suppliers/presentation/supplier_form_page.dart';
import '../features/suppliers/presentation/supplier_list_page.dart';
import '../features/sales/presentation/sales_page.dart';
import '../features/sales/presentation/sale_form_page.dart';
import '../features/sales/presentation/sale_detail_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'navigation/app_shell.dart';
import 'navigation/placeholder_page.dart';
import 'theme/app_theme.dart';

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
          builder: (context, state) => const SupplierListPage(),
        ),
        GoRoute(
          path: '/suppliers/new',
          builder: (context, state) => const SupplierFormPage(),
        ),
        GoRoute(
          path: '/suppliers/edit',
          builder: (context, state) {
            final supplier = state.extra;
            if (supplier is! Supplier) {
              return const PlaceholderPage(
                title: 'Proveedor no disponible',
                description: 'No se recibieron los datos del proveedor.',
                icon: Icons.error_outline,
              );
            }
            return SupplierFormPage(supplier: supplier);
          },
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListPage(),
        ),
        GoRoute(
          path: '/products/new',
          builder: (context, state) => const ProductFormPage(),
        ),
        GoRoute(
          path: '/products/edit',
          builder: (context, state) {
            final product = state.extra;
            if (product is! Product) {
              return const PlaceholderPage(
                title: 'Producto no disponible',
                description: 'No se recibieron los datos del producto.',
                icon: Icons.error_outline,
              );
            }
            return ProductFormPage(product: product);
          },
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(path: '/sales', builder: (context, state) => const SalesPage()),
        GoRoute(
          path: '/sales/new',
          builder: (context, state) => const SaleFormPage(),
        ),
        GoRoute(
          path: '/sales/detail',
          builder: (context, state) {
            final saleId = state.extra;
            if (saleId is! String || saleId.isEmpty) {
              return const PlaceholderPage(
                title: 'Venta no disponible',
                description: 'No se recibió el identificador de la venta.',
                icon: Icons.error_outline,
              );
            }
            return SaleDetailPage(saleId: saleId);
          },
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
          builder: (context, state) => const SettingsPage(),
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
