import 'package:go_router/go_router.dart';

import '../layout/main_layout.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/purchases/presentation/pages/purchase_form_page.dart';
import '../../features/purchases/presentation/pages/purchase_receipt_page.dart';
import '../../features/purchases/presentation/pages/purchases_page.dart';
import '../../features/purchases/presentation/pages/supplier_payment_page.dart';
import '../../features/settings/presentation/pages/currencies_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';

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
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: '/inventario',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/compras/nueva',
          builder: (context, state) => const PurchaseFormPage(),
        ),
        GoRoute(
          path: '/compras/:id',
          builder: (context, state) =>
              PurchaseFormPage(purchaseId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/compras/:id/recepcion',
          builder: (context, state) =>
              PurchaseReceiptPage(purchaseId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/compras/:id/pago',
          builder: (context, state) =>
              SupplierPaymentPage(purchaseId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/compras',
          builder: (context, state) => const PurchasesPage(),
        ),
        GoRoute(
          path: '/proveedores',
          builder: (context, state) => const SuppliersPage(),
        ),
        GoRoute(
          path: '/ajustes/monedas',
          builder: (context, state) => const CurrenciesPage(),
        ),
      ],
    ),
  ],
);
