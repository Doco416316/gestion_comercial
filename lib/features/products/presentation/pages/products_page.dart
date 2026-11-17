import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(productRepositoryProvider);

    return Scaffold(
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
                trailing: Icon(
                  product.trackInventory
                      ? Icons.inventory_2
                      : Icons.inventory_2_outlined,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
