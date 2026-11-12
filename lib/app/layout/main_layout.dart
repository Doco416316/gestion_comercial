import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  // Datos únicos de los 4 destinos
  static const _items =
      <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Inicio'),
    (
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Productos'
    ),
    (
      icon: Icons.warehouse_outlined,
      selectedIcon: Icons.warehouse,
      label: 'Inventario'
    ),
    (
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Compras'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _calculateSelectedIndex(),
              onDestinationSelected: (index) => _onItemTapped(index, context),
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations(),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: !isWide
          ? NavigationBar(
              selectedIndex: _calculateSelectedIndex(),
              onDestinationSelected: (index) => _onItemTapped(index, context),
              destinations: _barDestinations(),
            )
          : null,
    );
  }

  List<NavigationRailDestination> _railDestinations() => [
        for (final i in _items)
          NavigationRailDestination(
            icon: Icon(i.icon),
            selectedIcon: Icon(i.selectedIcon),
            label: Text(i.label),
          ),
      ];

  List<NavigationDestination> _barDestinations() => [
        for (final i in _items)
          NavigationDestination(
            icon: Icon(i.icon),
            selectedIcon: Icon(i.selectedIcon),
            label: i.label,
          ),
      ];

  int _calculateSelectedIndex() {
    if (currentLocation.startsWith('/productos')) return 1;
    if (currentLocation.startsWith('/inventario')) return 2;
    if (currentLocation.startsWith('/compras')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/productos');
      case 2:
        context.go('/inventario');
      case 3:
        context.go('/compras');
    }
  }
}