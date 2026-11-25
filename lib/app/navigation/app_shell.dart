import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _destinations = <_NavigationDestination>[
    _NavigationDestination(
      label: 'Inicio',
      path: '/',
      icon: Icons.dashboard_outlined,
    ),
    _NavigationDestination(
      label: 'Clientes',
      path: '/customers',
      icon: Icons.people_outline,
    ),
    _NavigationDestination(
      label: 'Proveedores',
      path: '/suppliers',
      icon: Icons.local_shipping_outlined,
    ),
    _NavigationDestination(
      label: 'Productos',
      path: '/products',
      icon: Icons.inventory_2_outlined,
    ),
    _NavigationDestination(
      label: 'Inventario',
      path: '/inventory',
      icon: Icons.warehouse_outlined,
    ),
    _NavigationDestination(
      label: 'Compras',
      path: '/purchases',
      icon: Icons.shopping_cart_outlined,
    ),
    _NavigationDestination(
      label: 'Ventas',
      path: '/sales',
      icon: Icons.point_of_sale_outlined,
    ),
    _NavigationDestination(
      label: 'Configuración',
      path: '/settings',
      icon: Icons.settings_outlined,
    ),
  ];

  int _selectedIndex(String location) {
    final index = _destinations.indexWhere(
      (destination) => destination.path == '/'
          ? location == '/'
          : location.startsWith(destination.path),
    );

    return index < 0 ? 0 : index;
  }

  void _navigate(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _destinations[selectedIndex].label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.business_center_outlined),
                      title: Text(
                        'Gestión Comercial',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _destinations.length,
                        itemBuilder: (context, index) {
                          final destination = _destinations[index];

                          return ListTile(
                            leading: Icon(destination.icon),
                            title: Text(destination.label),
                            selected: selectedIndex == index,
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigate(context, index);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (isWide) ...[
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _navigate(context, index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}
