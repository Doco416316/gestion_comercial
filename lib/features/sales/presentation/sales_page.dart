import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/sales_providers.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  String _status = 'all';

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesStreamProvider);
    final customersAsync = ref.watch(salesCustomersProvider);
    final currenciesAsync = ref.watch(salesCurrenciesProvider);

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: 'No se pudieron cargar las ventas: $error',
        onRetry: () => ref.invalidate(salesStreamProvider),
      ),
      data: (sales) => customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: 'No se pudieron cargar los clientes: $error',
          onRetry: () => ref.invalidate(salesCustomersProvider),
        ),
        data: (customers) => currenciesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: 'No se pudieron cargar las monedas: $error',
            onRetry: () => ref.invalidate(salesCurrenciesProvider),
          ),
          data: (currencies) => _buildContent(sales, customers, currencies),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<Sale> sales,
    List<Customer> customers,
    List<Currency> currencies,
  ) {
    final filtered = _status == 'all'
        ? sales
        : sales.where((sale) => sale.status == _status).toList();
    final customerNames = {for (final c in customers) c.id: c.name};
    final currencyByCode = {for (final c in currencies) c.code: c};

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
                      'Ventas',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sales.length} ${sales.length == 1 ? 'registro' : 'registros'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/sales/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nueva venta'),
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
                ButtonSegment(value: 'cancelled', label: Text('Canceladas')),
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
                        ? 'Todavía no hay ventas'
                        : 'No hay ventas en este estado',
                    message: 'Las ventas que registres aparecerán aquí.',
                    icon: Icons.point_of_sale_outlined,
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final sale = filtered[index];
                      final customerName = sale.customerId == null
                          ? 'Venta sin cliente'
                          : customerNames[sale.customerId] ?? 'Cliente';
                      final currency = currencyByCode[sale.currencyCode];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            child: Icon(
                              sale.status == 'confirmed'
                                  ? Icons.receipt_long_outlined
                                  : sale.status == 'cancelled'
                                  ? Icons.block_outlined
                                  : Icons.edit_note_outlined,
                            ),
                          ),
                          title: Text(
                            sale.documentNumber?.isNotEmpty == true
                                ? 'Venta ${sale.documentNumber}'
                                : 'Venta ${sale.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '$customerName\n${_date(sale.saleDate)} · ${_statusLabel(sale.status)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _money(
                                  sale.totalMinorUnits,
                                  sale.currencyCode,
                                  currency,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () =>
                              context.push('/sales/detail', extra: sale.id),
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
  'cancelled' => 'Cancelada',
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
