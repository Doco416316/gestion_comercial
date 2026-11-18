import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/supplier_providers.dart';

class SupplierListPage extends ConsumerStatefulWidget {
  const SupplierListPage({super.key});

  @override
  ConsumerState<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends ConsumerState<SupplierListPage> {
  final _search = TextEditingController();
  String _query = '';
  bool _includeInactive = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Supplier> _filter(List<Supplier> suppliers) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return suppliers;
    return suppliers.where((supplier) {
      return [supplier.name, supplier.taxId ?? '', supplier.phone ?? '', supplier.email ?? '']
          .join(' ').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _toggle(Supplier supplier) async {
    final active = !supplier.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(active ? 'Activar proveedor' : 'Desactivar proveedor'),
        content: Text('¿Deseas ${active ? 'activar' : 'desactivar'} a ${supplier.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(active ? 'Activar' : 'Desactivar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(supplierRepositoryProvider).setActive(supplier.id, active);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(active ? 'Proveedor activado.' : 'Proveedor desactivado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar el proveedor: $error')));
    }
  }

  Future<void> _edit(Supplier supplier) async {
    await context.push('/suppliers/edit', extra: supplier);
  }

  Widget _actions(Supplier supplier) => PopupMenuButton<String>(
        tooltip: 'Acciones del proveedor',
        onSelected: (action) {
          if (action == 'edit') _edit(supplier);
          if (action == 'toggle') _toggle(supplier);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
          PopupMenuItem(value: 'toggle', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(supplier.isActive ? Icons.block_outlined : Icons.check_circle_outline), title: Text(supplier.isActive ? 'Desactivar' : 'Activar'))),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersStreamProvider(_includeInactive));
    return suppliersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No se pudieron cargar los proveedores.\n$error', textAlign: TextAlign.center))),
      data: (suppliers) {
        final filtered = _filter(suppliers);
        final wide = MediaQuery.sizeOf(context).width >= 760;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Directorio de proveedores', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${suppliers.length} ${suppliers.length == 1 ? 'proveedor registrado' : 'proveedores registrados'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
              ])),
              IconButton.filledTonal(tooltip: 'Registrar nuevo proveedor', onPressed: () => context.push('/suppliers/new'), icon: const Icon(Icons.add_business_outlined)),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, identificación, teléfono o correo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty ? null : IconButton(tooltip: 'Limpiar búsqueda', onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Incluir proveedores inactivos'),
              value: _includeInactive,
              onChanged: (value) => setState(() => _includeInactive = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.local_shipping_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(_query.isEmpty ? 'Aún no hay proveedores registrados.' : 'No se encontraron proveedores.', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      if (_query.isEmpty) FilledButton.icon(onPressed: () => context.push('/suppliers/new'), icon: const Icon(Icons.add), label: const Text('Registrar proveedor')),
                    ]))
                  : wide ? _buildTable(filtered) : _buildCards(filtered),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildTable(List<Supplier> suppliers) => Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: DataTable(columns: const [
            DataColumn(label: Text('Proveedor')),
            DataColumn(label: Text('Identificación')),
            DataColumn(label: Text('Teléfono')),
            DataColumn(label: Text('Correo')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('')),
          ], rows: suppliers.map((supplier) => DataRow(cells: [
            DataCell(Text(supplier.name)),
            DataCell(Text(supplier.taxId ?? '—')),
            DataCell(Text(supplier.phone ?? '—')),
            DataCell(Text(supplier.email ?? '—')),
            DataCell(Chip(label: Text(supplier.isActive ? 'Activo' : 'Inactivo'), visualDensity: VisualDensity.compact)),
            DataCell(_actions(supplier)),
          ])).toList()),
        ),
      );

  Widget _buildCards(List<Supplier> suppliers) => ListView.separated(
        itemCount: suppliers.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return Card(child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.business_outlined)),
            title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text([supplier.taxId, supplier.phone, supplier.email].whereType<String>().where((value) => value.isNotEmpty).join(' · ').isEmpty ? 'Sin datos de contacto' : [supplier.taxId, supplier.phone, supplier.email].whereType<String>().where((value) => value.isNotEmpty).join(' · ')),
            trailing: _actions(supplier),
            isThreeLine: false,
          ));
        },
      );
}
