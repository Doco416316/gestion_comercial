import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  Future<void> _showProductDialog({Product? product}) async {
    final skuController = TextEditingController(text: product?.sku ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final categoryController = TextEditingController(
      text: product?.category ?? '',
    );
    var trackInventory = product?.trackInventory ?? true;
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSave =
                !saving &&
                skuController.text.trim().isNotEmpty &&
                nameController.text.trim().isNotEmpty;

            return AlertDialog(
              title: Text(
                product == null ? 'Nuevo producto' : 'Editar producto',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: 'SKU'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  SwitchListTile(
                    title: const Text('Controlar inventario'),
                    value: trackInventory,
                    onChanged: saving
                        ? null
                        : (value) =>
                              setDialogState(() => trackInventory = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: canSave
                      ? () async {
                          setDialogState(() => saving = true);
                          try {
                            final repository = ref.read(
                              productRepositoryProvider,
                            );
                            if (product == null) {
                              await repository.createProduct(
                                sku: skuController.text.trim(),
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                category: categoryController.text.trim(),
                                trackInventory: trackInventory,
                              );
                            } else {
                              await repository.updateProduct(
                                id: product.id,
                                sku: skuController.text.trim(),
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                category: categoryController.text.trim(),
                                unit: product.unit,
                                trackInventory: trackInventory,
                              );
                            }
                            if (!mounted || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  product == null
                                      ? 'Producto creado'
                                      : 'Producto actualizado',
                                ),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          } catch (error) {
                            if (mounted && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(readableErrorMessage(error)),
                                ),
                              );
                              setDialogState(() => saving = false);
                            }
                          }
                        }
                      : null,
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(productRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        tooltip: 'Nuevo producto',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Product>>(
        stream: repository.watchActiveProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(readableErrorMessage(snapshot.error!)));
          }

          final products = snapshot.data ?? const <Product>[];

          if (products.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(product.sku),
                    const SizedBox(width: 8),
                    Text(product.name),
                  ],
                ),
                subtitle: Text(product.category ?? 'Sin categoría'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.trackInventory
                          ? Icons.inventory_2
                          : Icons.inventory_2_outlined,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar producto',
                      onPressed: () => _showProductDialog(product: product),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
