import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(purchaseRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/compras/nueva'),
        tooltip: 'Nueva compra',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Purchase>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(readableErrorMessage(snapshot.error!)));
          }

          final purchases = snapshot.data ?? const <Purchase>[];

          if (purchases.isEmpty) {
            return const Center(child: Text('No hay compras'));
          }

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return ListTile(
                title: Text(purchase.id),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Proveedor: ${purchase.supplierId}'),
                    Text('Estado: ${purchase.status}'),
                    Text(
                      'Total: ${purchase.totalMinorUnits} ${purchase.currencyCode}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (purchase.status == 'draft')
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar compra',
                        onPressed: () => context.go('/compras/${purchase.id}'),
                      ),
                    if (purchase.status == 'confirmed')
                      IconButton(
                        icon: const Icon(Icons.receipt_long),
                        tooltip: 'Recepción',
                        onPressed: () =>
                            context.go('/compras/${purchase.id}/recepcion'),
                      ),
                    if (purchase.status == 'confirmed')
                      IconButton(
                        icon: const Icon(Icons.payments),
                        tooltip: 'Pagos',
                        onPressed: () =>
                            context.go('/compras/${purchase.id}/pago'),
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
