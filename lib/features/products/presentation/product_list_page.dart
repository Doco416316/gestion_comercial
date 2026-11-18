import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/product_providers.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _search = TextEditingController();
  String _query = '';
  bool _includeInactive = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products.where((product) => [product.sku, product.name, product.category ?? '', product.description ?? ''].join(' ').toLowerCase().contains(query)).toList();
  }

  Future<void> _toggle(Product product) async {
    final active = !product.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(active ? 'Activar producto' : 'Desactivar producto'),
        content: Text('¿Deseas ${active ? 'activar' : 'desactivar'} ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(active ? 'Activar' : 'Desactivar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(productRepositoryProvider).setActive(product.id, active);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(active ? 'Producto activado.' : 'Producto desactivado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar el producto: $error')));
    }
  }

  Future<void> _edit(Product product) async {
    await context.push('/products/edit', extra: product);
  }

  Widget _actions(Product product) => PopupMenuButton<String>(
        tooltip: 'Acciones del producto',
        onSelected: (action) {
          if (action == 'edit') _edit(product);
          if (action == 'toggle') _toggle(product);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
          PopupMenuItem(value: 'toggle', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(product.isActive ? Icons.block_outlined : Icons.check_circle_outline), title: Text(product.isActive ? 'Desactivar' : 'Activar'))),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(_includeInactive));
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No se pudieron cargar los productos.\n$error', textAlign: TextAlign.center))),
      data: (products) {
        final filtered = _filter(products);
        final wide = MediaQuery.sizeOf(context).width >= 760;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Catálogo de productos', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${products.length} ${products.length == 1 ? 'producto registrado' : 'productos registrados'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
              ])),
              IconButton.filledTonal(tooltip: 'Registrar nuevo producto', onPressed: () => context.push('/products/new'), icon: const Icon(Icons.add_box_outlined)),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar por SKU, nombre, categoría o descripción...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty ? null : IconButton(tooltip: 'Limpiar búsqueda', onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Incluir productos inactivos'), value: _includeInactive, onChanged: (value) => setState(() => _includeInactive = value)),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(_query.isEmpty ? 'Aún no hay productos registrados.' : 'No se encontraron productos.', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      if (_query.isEmpty) FilledButton.icon(onPressed: () => context.push('/products/new'), icon: const Icon(Icons.add), label: const Text('Registrar producto')),
                    ]))
                  : wide ? _buildTable(filtered) : _buildCards(filtered),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildTable(List<Product> products) => Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: DataTable(columns: const [
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Unidad')),
            DataColumn(label: Text('Inventario')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('')),
          ], rows: products.map((product) => DataRow(cells: [
            DataCell(Text(product.sku)),
            DataCell(Text(product.name)),
            DataCell(Text(product.category ?? '—')),
            DataCell(Text(product.unit)),
            DataCell(Text(product.trackInventory ? 'Controlado' : 'No')),
            DataCell(Chip(label: Text(product.isActive ? 'Activo' : 'Inactivo'), visualDensity: VisualDensity.compact)),
            DataCell(_actions(product)),
          ])).toList()),
        ),
      );

  Widget _buildCards(List<Product> products) => ListView.separated(
        itemCount: products.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${product.sku} · ${product.category ?? 'Sin categoría'} · ${product.unit}${product.trackInventory ? ' · Control de stock' : ''}'),
            trailing: _actions(product),
          ));
        },
      );
}
