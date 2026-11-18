import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  List<Product> _products = const <Product>[];

  Future<void> _showMovementHistory(Product product) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _MovementHistoryDialog(product: product),
    );
  }

  Future<void> _showRegisterMovementDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _RegisterMovementDialog(products: _products),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productRepository = ref.watch(productRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showRegisterMovementDialog,
        tooltip: 'Registrar movimiento',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productRepository.watchActiveProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(readableErrorMessage(snapshot.error!)));
          }

          final products = snapshot.data ?? const <Product>[];
          _products = products;

          if (products.isEmpty) {
            return const Center(child: Text('No hay productos en inventario'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _InventoryProductTile(
                product: product,
                onHistory: () => _showMovementHistory(product),
              );
            },
          );
        },
      ),
    );
  }
}

class _InventoryProductTile extends ConsumerWidget {
  const _InventoryProductTile({required this.product, required this.onHistory});

  final Product product;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryRepository = ref.watch(inventoryRepositoryProvider);

    return ListTile(
      title: Row(
        children: [
          Text(product.sku),
          const SizedBox(width: 8),
          Flexible(child: Text(product.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
      subtitle: StreamBuilder<int>(
        stream: inventoryRepository.watchStock(product.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Text('Stock: ...');
          }

          if (snapshot.hasError) {
            return Text(readableErrorMessage(snapshot.error!));
          }

          final stock = snapshot.data ?? 0;
          return Text('Stock: $stock milésimas · ${product.unit}');
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'Historial',
        onPressed: onHistory,
      ),
    );
  }
}

class _MovementHistoryDialog extends ConsumerStatefulWidget {
  const _MovementHistoryDialog({required this.product});

  final Product product;

  @override
  ConsumerState<_MovementHistoryDialog> createState() =>
      _MovementHistoryDialogState();
}

class _MovementHistoryDialogState
    extends ConsumerState<_MovementHistoryDialog> {
  @override
  Widget build(BuildContext context) {
    final inventoryRepository = ref.watch(inventoryRepositoryProvider);

    return AlertDialog(
      title: const Text('Historial de movimientos'),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<InventoryMovement>>(
          future: inventoryRepository.getMovementHistory(widget.product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(readableErrorMessage(snapshot.error!)));
            }

            final movements = snapshot.data ?? const <InventoryMovement>[];

            if (movements.isEmpty) {
              return const Center(child: Text('Sin movimientos'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                return ListTile(
                  title: Text(movement.movementType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cantidad: ${movement.quantityMilliUnits} milésimas',
                      ),
                      Text('Fecha: ${movement.createdAt}'),
                      Text('Motivo: ${movement.reason}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _RegisterMovementDialog extends ConsumerStatefulWidget {
  const _RegisterMovementDialog({required this.products});

  final List<Product> products;

  @override
  ConsumerState<_RegisterMovementDialog> createState() =>
      _RegisterMovementDialogState();
}

class _RegisterMovementDialogState
    extends ConsumerState<_RegisterMovementDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedProductId;
  String _selectedType = 'entry';
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final productId = _selectedProductId;
    if (productId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un producto')));
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cantidad inválida')));
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El motivo es obligatorio')));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .registerMovement(
            productId: productId,
            movementType: _selectedType,
            quantityMilliUnits: quantity,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Movimiento registrado')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar movimiento'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedProductId,
              decoration: const InputDecoration(labelText: 'Producto'),
              items: widget.products
                  .map(
                    (product) => DropdownMenuItem<String>(
                      value: product.id,
                      child: Text('${product.sku} - ${product.name}'),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _selectedProductId = value),
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'entry', child: Text('Entrada')),
                DropdownMenuItem(value: 'exit', child: Text('Salida')),
                DropdownMenuItem(
                  value: 'positive_adjustment',
                  child: Text('Ajuste positivo'),
                ),
                DropdownMenuItem(
                  value: 'negative_adjustment',
                  child: Text('Ajuste negativo'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                helperText: 'Se ingresa en milésimas',
              ),
              keyboardType: TextInputType.number,
              enabled: !_saving,
            ),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Motivo'),
              enabled: !_saving,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
