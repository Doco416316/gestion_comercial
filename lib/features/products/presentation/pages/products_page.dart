import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../app/utils/money_formatter.dart';
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

  Future<void> _showPricesDialog(Product product) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _ProductPricesDialog(product: product),
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
                      icon: const Icon(Icons.price_change),
                      tooltip: 'Precios',
                      onPressed: () => _showPricesDialog(product),
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

class _ProductPricesDialog extends ConsumerStatefulWidget {
  const _ProductPricesDialog({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductPricesDialog> createState() =>
      _ProductPricesDialogState();
}

class _ProductPricesDialogState extends ConsumerState<_ProductPricesDialog> {
  final Set<String> _busyCodes = <String>{};
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String code, ProductPrice? price) {
    return _controllers.putIfAbsent(
      code,
      () =>
          TextEditingController(text: price?.amountMinorUnits.toString() ?? ''),
    );
  }

  Future<void> _save(
    Currency currency,
    TextEditingController controller,
  ) async {
    final text = controller.text.trim();
    final amount = int.tryParse(text);
    if (amount == null || amount < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Importe inválido')));
      return;
    }

    setState(() => _busyCodes.add(currency.code));
    try {
      await ref
          .read(productRepositoryProvider)
          .setPrice(
            productId: widget.product.id,
            currencyCode: currency.code,
            amountMinorUnits: amount,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Precio guardado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _busyCodes.remove(currency.code));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyRepository = ref.watch(currencyRepositoryProvider);
    final productRepository = ref.watch(productRepositoryProvider);

    return AlertDialog(
      title: const Text('Precios'),
      content: SizedBox(
        width: 420,
        child: StreamBuilder<List<Currency>>(
          stream: currencyRepository.watchAll(),
          builder: (context, currencySnapshot) {
            if (currencySnapshot.connectionState == ConnectionState.waiting &&
                !currencySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (currencySnapshot.hasError) {
              return Center(
                child: Text(readableErrorMessage(currencySnapshot.error!)),
              );
            }

            final currencies = currencySnapshot.data ?? const <Currency>[];

            if (currencies.isEmpty) {
              return const Center(child: Text('No hay monedas'));
            }

            return StreamBuilder<List<ProductPrice>>(
              stream: productRepository.watchPrices(widget.product.id),
              builder: (context, priceSnapshot) {
                if (priceSnapshot.connectionState == ConnectionState.waiting &&
                    !priceSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (priceSnapshot.hasError) {
                  return Center(
                    child: Text(readableErrorMessage(priceSnapshot.error!)),
                  );
                }

                final prices = priceSnapshot.data ?? const <ProductPrice>[];
                final pricesByCode = <String, ProductPrice>{};
                for (final price in prices) {
                  pricesByCode[price.currencyCode] = price;
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final price = pricesByCode[currency.code];
                    final controller = _controllerFor(currency.code, price);
                    final busy = _busyCodes.contains(currency.code);

                    return ListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(currency.code),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              currency.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price == null
                                ? 'Sin precio'
                                : formatMoney(
                                    price.amountMinorUnits,
                                    decimalDigits: currency.decimalDigits,
                                    symbol: currency.symbol,
                                  ),
                          ),
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !busy,
                          ),
                        ],
                      ),
                      trailing: FilledButton(
                        onPressed: busy
                            ? null
                            : () => _save(currency, controller),
                        child: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
