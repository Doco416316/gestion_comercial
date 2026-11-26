import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'providers/purchase_providers.dart';

import 'package:go_router/go_router.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  String _status = 'all';

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);
    final suppliersAsync = ref.watch(purchaseSuppliersProvider);
    final currenciesAsync = ref.watch(purchaseCurrenciesProvider);

    return purchasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: 'No se pudieron cargar las compras: $error',
        onRetry: () => ref.invalidate(purchasesStreamProvider),
      ),
      data: (purchases) => suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: 'No se pudieron cargar los proveedores: $error',
          onRetry: () => ref.invalidate(purchaseSuppliersProvider),
        ),
        data: (suppliers) => currenciesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: 'No se pudieron cargar las monedas: $error',
            onRetry: () => ref.invalidate(purchaseCurrenciesProvider),
          ),
          data: (currencies) => _buildContent(purchases, suppliers, currencies),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<Purchase> purchases,
    List<Supplier> suppliers,
    List<Currency> currencies,
  ) {
    final filtered = _status == 'all'
        ? purchases
        : purchases.where((purchase) => purchase.status == _status).toList();

    final supplierNames = {
      for (final supplier in suppliers) supplier.id: supplier.name,
    };
    final currencyByCode = {
      for (final currency in currencies) currency.code: currency,
    };

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
                    Text(
                      'Compras',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${purchases.length} ${purchases.length == 1 ? 'registro' : 'registros'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.push('/purchases/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nueva compra'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Todas')),
                ButtonSegment(value: 'draft', label: Text('Borradores')),
                ButtonSegment(value: 'confirmed', label: Text('Confirmadas')),
                ButtonSegment(value: 'cancelled', label: Text('Anuladas')),
              ],
              selected: {_status},
              onSelectionChanged: (value) {
                setState(() => _status = value.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(
                    title: _status == 'all'
                        ? 'Todavía no hay compras'
                        : 'No hay compras en este estado',
                    message: 'Las compras que registres aparecerán aquí.',
                    icon: Icons.shopping_cart_outlined,
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final purchase = filtered[index];
                      final supplierName =
                          supplierNames[purchase.supplierId] ?? 'Proveedor';
                      final currency = currencyByCode[purchase.currencyCode];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          onTap: () {
                            context.push(
                              '/purchases/detail',
                              extra: purchase.id,
                            );
                          },
                          leading: CircleAvatar(
                            child: Icon(
                              purchase.status == 'confirmed'
                                  ? Icons.receipt_long_outlined
                                  : purchase.status == 'cancelled'
                                  ? Icons.block_outlined
                                  : Icons.edit_note_outlined,
                            ),
                          ),
                          title: Text(
                            purchase.documentNumber?.isNotEmpty == true
                                ? 'Compra ${purchase.documentNumber}'
                                : 'Compra ${purchase.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '$supplierName\n${_date(purchase.purchaseDate)} · ${_statusLabel(purchase.status)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _money(
                                  purchase.totalMinorUnits,
                                  purchase.currencyCode,
                                  currency,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                purchase.currencyCode,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

String _statusLabel(String status) => switch (status) {
  'draft' => 'Borrador',
  'confirmed' => 'Confirmada',
  'cancelled' => 'Anulada',
  _ => status,
};

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _money(int amount, String code, Currency? currency) {
  final digits = currency?.decimalDigits ?? 2;
  final factor = _pow10(digits);
  final whole = amount ~/ factor;
  final fraction = (amount % factor).toString().padLeft(digits, '0');
  final symbol = currency?.symbol ?? code;
  return digits == 0 ? '$symbol $whole' : '$symbol $whole.$fraction';
}

int _pow10(int digits) {
  var value = 1;
  for (var i = 0; i < digits; i++) {
    value *= 10;
  }
  return value;
}
