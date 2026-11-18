import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<Map<String, int>>? _kpisFuture;

  @override
  void initState() {
    super.initState();
    _kpisFuture = _loadKpis();
  }

  Future<List<T>> _firstOrEmpty<T>(Stream<List<T>> stream) {
    final completer = Completer<List<T>>();
    StreamSubscription<List<T>>? subscription;
    subscription = stream.listen(
      (data) {
        if (!completer.isCompleted) {
          completer.complete(data);
          subscription?.cancel();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
          subscription?.cancel();
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(<T>[]);
          subscription?.cancel();
        }
      },
    );
    scheduleMicrotask(() {
      if (!completer.isCompleted) {
        completer.complete(<T>[]);
        subscription?.cancel();
      }
    });
    return completer.future;
  }

  Future<Map<String, int>> _loadKpis() async {
    final productRepository = ref.read(productRepositoryProvider);
    final supplierRepository = ref.read(supplierRepositoryProvider);
    final purchaseRepository = ref.read(purchaseRepositoryProvider);

    final products = await _firstOrEmpty(
      productRepository.watchActiveProducts(),
    );
    final suppliers = await _firstOrEmpty(supplierRepository.watchAll());
    final purchases = await _firstOrEmpty(purchaseRepository.watchAll());

    return {
      'products': products.length,
      'suppliers': suppliers.where((supplier) => supplier.isActive).length,
      'draftPurchases': purchases
          .where((purchase) => purchase.status == 'draft')
          .length,
      'confirmedPurchases': purchases
          .where((purchase) => purchase.status == 'confirmed')
          .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, int>>(
        future: _kpisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(readableErrorMessage(snapshot.error!)));
          }

          final kpis = snapshot.data ?? const <String, int>{};

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _KpiCard(
                title: 'Productos activos',
                value: '${kpis['products'] ?? 0}',
              ),
              _KpiCard(
                title: 'Proveedores activos',
                value: '${kpis['suppliers'] ?? 0}',
              ),
              _KpiCard(
                title: 'Compras en borrador',
                value: '${kpis['draftPurchases'] ?? 0}',
              ),
              _KpiCard(
                title: 'Compras confirmadas',
                value: '${kpis['confirmedPurchases'] ?? 0}',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}
