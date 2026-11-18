import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../products/presentation/providers/product_providers.dart';
import '../data/inventory_repository.dart';
import 'providers/inventory_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _quantity(int milliUnits) => (milliUnits / 1000).toStringAsFixed(3);

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    final movementsAsync = ref.watch(recentInventoryMovementsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventario', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Existencias y trazabilidad de movimientos.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showMovementForm(),
                icon: const Icon(Icons.add),
                label: const Text('Registrar movimiento'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Buscar por SKU o producto...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty ? null : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () { _searchController.clear(); setState(() => _search = ''); },
                icon: const Icon(Icons.close),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: inventoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('No se pudo cargar el inventario.\n$error', textAlign: TextAlign.center)),
              data: (items) {
                final filtered = items.where((item) => '${item.product.sku} ${item.product.name} ${item.product.category ?? ''}'.toLowerCase().contains(_search)).toList();
                if (filtered.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warehouse_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(items.isEmpty ? 'No hay productos activos con control de inventario.' : 'No se encontraron productos.'),
                  ]));
                }
                return LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth >= 760) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('SKU')),
                              DataColumn(label: Text('Producto')),
                              DataColumn(label: Text('Categoría')),
                              DataColumn(label: Text('Existencias')),
                              DataColumn(label: Text('Unidad')),
                              DataColumn(label: Text('')),
                            ],
                            rows: filtered.map((item) => DataRow(cells: [
                              DataCell(Text(item.product.sku)),
                              DataCell(Text(item.product.name)),
                              DataCell(Text(item.product.category ?? '—')),
                              DataCell(Text(_quantity(item.quantityMilliUnits), style: TextStyle(fontWeight: FontWeight.w700, color: item.quantityMilliUnits <= 0 ? Colors.red : null))),
                              DataCell(Text(item.product.unit)),
                              DataCell(IconButton(tooltip: 'Ver movimientos', onPressed: () => _showHistory(item.product), icon: const Icon(Icons.history))),
                            ])).toList(),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                        title: Text(item.product.name),
                        subtitle: Text('${item.product.sku} · ${item.product.category ?? 'Sin categoría'}'),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(_quantity(item.quantityMilliUnits), style: TextStyle(fontWeight: FontWeight.bold, color: item.quantityMilliUnits <= 0 ? Colors.red : null)),
                          Text(item.product.unit, style: Theme.of(context).textTheme.bodySmall),
                        ]),
                        onTap: () => _showHistory(item.product),
                      ));
                    },
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showRecentMovements(movementsAsync),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Ver movimientos recientes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMovementForm() async {
    final products = await ref.read(productsStreamProvider(false).future);
    final eligible = products.where((product) => product.trackInventory).toList();
    if (!mounted) return;
    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primero registra un producto activo con control de inventario.')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final referenceController = TextEditingController();
    var productId = eligible.first.id;
    var movementType = 'entry';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: const Text('Registrar movimiento'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                value: productId,
                decoration: const InputDecoration(labelText: 'Producto *'),
                items: eligible.map((product) => DropdownMenuItem(value: product.id, child: Text('${product.sku} · ${product.name}', overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (value) { if (value != null) setDialogState(() => productId = value); },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: movementType,
                decoration: const InputDecoration(labelText: 'Tipo de movimiento *'),
                items: const [
                  DropdownMenuItem(value: 'entry', child: Text('Entrada')),
                  DropdownMenuItem(value: 'exit', child: Text('Salida')),
                  DropdownMenuItem(value: 'positive_adjustment', child: Text('Ajuste positivo')),
                  DropdownMenuItem(value: 'negative_adjustment', child: Text('Ajuste negativo')),
                  DropdownMenuItem(value: 'customer_return', child: Text('Devolución de cliente')),
                  DropdownMenuItem(value: 'supplier_return', child: Text('Devolución a proveedor')),
                ],
                onChanged: (value) { if (value != null) setDialogState(() => movementType = value); },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad *', hintText: 'Ej. 12 o 1,250'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = _parseQuantity(value ?? '');
                  return parsed == null || parsed <= 0 ? 'Ingresa una cantidad mayor que cero.' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: reasonController, decoration: const InputDecoration(labelText: 'Motivo *'), maxLength: 250, validator: (value) => value == null || value.trim().isEmpty ? 'El motivo es obligatorio.' : null),
              TextFormField(controller: referenceController, decoration: const InputDecoration(labelText: 'Referencia (opcional)'), maxLength: 100),
            ])),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: const Text('Guardar')),
        ],
      )),
    );

    if (saved == true && mounted) {
      try {
        final quantity = _parseQuantity(quantityController.text)!;
        await ref.read(inventoryRepositoryProvider).registerMovement(
          productId: productId,
          movementType: movementType,
          quantityMilliUnits: quantity,
          reason: reasonController.text,
          reference: referenceController.text,
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento registrado correctamente.')));
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo registrar el movimiento: $error')));
      }
    }
    quantityController.dispose();
    reasonController.dispose();
    referenceController.dispose();
  }

  int? _parseQuantity(String value) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > 999999999) return null;
    final milliUnits = parsed * 1000;
    if ((milliUnits - milliUnits.round()).abs() > 0.000001) return null;
    return milliUnits.round();
  }

  Future<void> _showHistory(Product product) async {
    final history = await ref.read(inventoryRepositoryProvider).getMovementHistory(product.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('Movimientos · ${product.name}', style: Theme.of(context).textTheme.titleLarge)),
          Expanded(child: history.isEmpty ? const Center(child: Text('Este producto aún no tiene movimientos.')) : ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final movement = history[index];
              return ListTile(
                leading: Icon(_movementIcon(movement.movementType)),
                title: Text(_movementLabel(movement.movementType)),
                subtitle: Text('${movement.reason}\n${movement.createdAt.toLocal()}${movement.reference == null ? '' : ' · Ref. ${movement.reference}'}'),
                isThreeLine: true,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_quantity(movement.quantityMilliUnits)),
                  if (movement.correctionOfId == null)
                    IconButton(
                      tooltip: 'Corregir movimiento',
                      icon: const Icon(Icons.undo_outlined),
                      onPressed: () => _correctMovement(movement.id),
                    ),
                ]),
              );
            },
          )),
        ]),
      )),
    );
  }

  Future<void> _correctMovement(String movementId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corregir movimiento'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          maxLength: 250,
          decoration: const InputDecoration(labelText: 'Motivo de la corrección *'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim().isNotEmpty),
            child: const Text('Confirmar corrección'),
          ),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(inventoryRepositoryProvider).correctMovement(
        originalMovementId: movementId,
        reason: reason,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Corrección registrada mediante un movimiento compensatorio.')));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo corregir el movimiento: $error')));
    }
  }

  void _showRecentMovements(AsyncValue<List<InventoryMovementEntry>> movementsAsync) {
    movementsAsync.when(
      loading: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cargando movimientos...'))),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudieron cargar los movimientos: $error'))),
      data: (entries) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Text('Movimientos recientes', style: Theme.of(context).textTheme.titleLarge)),
            Expanded(child: entries.isEmpty ? const Center(child: Text('Todavía no hay movimientos.')) : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: Icon(_movementIcon(entry.movement.movementType)),
                  title: Text(entry.product.name),
                  subtitle: Text('${_movementLabel(entry.movement.movementType)} · ${entry.movement.reason}\n${entry.movement.createdAt.toLocal()}'),
                  isThreeLine: true,
                  trailing: Text(_quantity(entry.movement.quantityMilliUnits)),
                );
              },
            )),
          ]),
        )),
      ),
    );
  }

  String _movementLabel(String type) => switch (type) {
    'entry' => 'Entrada',
    'exit' => 'Salida',
    'positive_adjustment' => 'Ajuste positivo',
    'negative_adjustment' => 'Ajuste negativo',
    'customer_return' => 'Devolución de cliente',
    'supplier_return' => 'Devolución a proveedor',
    _ => type,
  };

  IconData _movementIcon(String type) => switch (type) {
    'entry' || 'positive_adjustment' || 'customer_return' => Icons.south_west,
    _ => Icons.north_east,
  };
}
