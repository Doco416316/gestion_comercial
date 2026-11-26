import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/purchase_providers.dart';

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({required this.purchaseId, super.key});

  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseByIdProvider(purchaseId));
    final detailsAsync = ref.watch(purchaseDetailsProvider(purchaseId));
    final receiptsAsync = ref.watch(purchaseReceiptsProvider(purchaseId));
    final receivedQuantitiesAsync = ref.watch(
      purchaseReceivedQuantitiesProvider(purchaseId),
    );
    final paymentsAsync = ref.watch(purchasePaymentsProvider(purchaseId));
    final suppliersAsync = ref.watch(purchaseSuppliersProvider);
    final currenciesAsync = ref.watch(purchaseCurrenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de compra'),
        actions: [
          IconButton(
            tooltip: 'Volver a compras',
            onPressed: () => context.go('/purchases'),
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: purchaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _message('No se pudo cargar la compra: $error'),
        data: (purchase) {
          if (purchase == null) {
            return _message('La compra ya no existe.');
          }

          return suppliersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _message('No se pudieron cargar los proveedores: $error'),
            data: (suppliers) {
              final matches = suppliers.where(
                (item) => item.id == purchase.supplierId,
              );
              final supplierName = matches.isEmpty
                  ? 'Proveedor no disponible'
                  : matches.first.name;

              return currenciesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _message('No se pudieron cargar las monedas: $error'),
                data: (currencies) {
                  final matches = currencies.where(
                    (item) => item.code == purchase.currencyCode,
                  );
                  final currency = matches.isEmpty ? null : matches.first;

                  return detailsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        _message('No se pudieron cargar los productos: $error'),
                    data: (details) => receiptsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _message(
                        'No se pudieron cargar las recepciones: $error',
                      ),
                      data: (receipts) => receivedQuantitiesAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => _message(
                          'No se pudieron cargar las cantidades recibidas: $error',
                        ),
                        data: (receivedQuantities) => paymentsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => _message(
                            'No se pudieron cargar los pagos: $error',
                          ),
                          data: (payments) => _buildContent(
                            context,
                            purchase,
                            details,
                            receipts,
                            receivedQuantities,
                            payments,
                            currency,
                            currencies,
                            supplierName,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Purchase purchase,
    List<PurchaseDetail> details,
    List<PurchaseReceipt> receipts,
    Map<String, int> receivedQuantities,
    List<SupplierPayment> payments,
    Currency? currency,
    List<Currency> currencies,
    String supplierName,
  ) {
    final paid = payments.fold<int>(
      0,
      (total, payment) => total + payment.appliedAmountMinorUnits,
    );
    final balance = purchase.totalMinorUnits - paid;
    final isDraft = purchase.status == 'draft';
    final isConfirmed = purchase.status == 'confirmed';
    final hasPendingProducts = details.any(
      (detail) =>
          (receivedQuantities[detail.id] ?? 0) < detail.quantityMilliUnits,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            purchase.documentNumber?.isNotEmpty == true
                                ? 'Compra ${purchase.documentNumber}'
                                : 'Compra ${purchase.id.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _StatusChip(status: purchase.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Proveedor', value: supplierName),
                    _InfoRow(
                      label: 'Fecha',
                      value: _date(purchase.purchaseDate),
                    ),
                    _InfoRow(label: 'Moneda', value: purchase.currencyCode),
                    if (purchase.confirmedAt != null)
                      _InfoRow(
                        label: 'Confirmada',
                        value: _date(purchase.confirmedAt!),
                      ),
                    if (purchase.cancelledAt != null)
                      _InfoRow(
                        label: 'Anulada',
                        value: _date(purchase.cancelledAt!),
                      ),
                    if (purchase.cancellationReason?.isNotEmpty == true)
                      _InfoRow(
                        label: 'Motivo de anulación',
                        value: purchase.cancellationReason!,
                      ),
                    if (purchase.notes?.isNotEmpty == true)
                      _InfoRow(label: 'Notas', value: purchase.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Productos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (details.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Esta compra todavía no tiene productos.'),
                ),
              )
            else
              ...details.map(
                (detail) => Card(
                  child: ListTile(
                    title: Text(detail.productNameSnapshot),
                    subtitle: Text(
                      '${detail.skuSnapshot} · '
                      '${_quantity(detail.quantityMilliUnits)} ${detail.unitSnapshot} × '
                      '${_money(detail.unitCostMinorUnits, purchase.currencyCode, currency)}'
                      '\nSolicitado: ${_quantity(detail.quantityMilliUnits)} ${detail.unitSnapshot}'
                      '\nRecibido: ${_quantity(receivedQuantities[detail.id] ?? 0)} ${detail.unitSnapshot}'
                      '\nPendiente: ${_quantity((detail.quantityMilliUnits - (receivedQuantities[detail.id] ?? 0)).clamp(0, detail.quantityMilliUnits).toInt())} ${detail.unitSnapshot}',
                    ),
                    trailing: Text(
                      _money(
                        detail.totalMinorUnits,
                        purchase.currencyCode,
                        currency,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text('Recepciones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (isConfirmed && hasPendingProducts)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/purchases/receipt', extra: purchase.id),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Registrar recepción'),
                ),
              ),
            if (isConfirmed && balance > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/purchases/payment', extra: purchase.id),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                ),
              ),
            if (!isConfirmed)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Las recepciones estarán disponibles cuando la compra esté confirmada.',
                  ),
                ),
              )
            else if (receipts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Todavía no se han registrado recepciones.'),
                ),
              )
            else
              ...receipts.map(
                (receipt) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(_date(receipt.receivedAt)),
                    subtitle: Text(
                      [
                            if (receipt.reference?.isNotEmpty == true)
                              'Referencia: ${receipt.reference}',
                            if (receipt.notes?.isNotEmpty == true)
                              receipt.notes!,
                          ].join('\n').isEmpty
                          ? 'Recepción registrada'
                          : [
                              if (receipt.reference?.isNotEmpty == true)
                                'Referencia: ${receipt.reference}',
                              if (receipt.notes?.isNotEmpty == true)
                                receipt.notes!,
                            ].join('\n'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Pagos al proveedor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (isConfirmed && hasPendingProducts)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/purchases/receipt', extra: purchase.id),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Registrar recepción'),
                ),
              ),
            if (isConfirmed && balance > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/purchases/payment', extra: purchase.id),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                ),
              ),
            if (!isConfirmed)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Los pagos estarán disponibles cuando la compra esté confirmada.',
                  ),
                ),
              )
            else if (payments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Todavía no se han registrado pagos.'),
                ),
              )
            else
              ...payments.map(
                (payment) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(
                      _money(
                        payment.amountMinorUnits,
                        payment.currencyCode,
                        currencies
                            .where((item) => item.code == payment.currencyCode)
                            .firstOrNull,
                      ),
                    ),
                    subtitle: Text(
                      '${_date(payment.paymentDate)} · ${payment.paymentMethod}'
                      '${payment.reference?.isNotEmpty == true ? '\nReferencia: ${payment.reference}' : ''}',
                    ),
                    trailing: Text(
                      'Aplicado\n${_money(payment.appliedAmountMinorUnits, purchase.currencyCode, currency)}',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _AmountRow(
                      label: 'Subtotal',
                      value: _money(
                        purchase.subtotalMinorUnits,
                        purchase.currencyCode,
                        currency,
                      ),
                    ),
                    _AmountRow(
                      label: 'Descuento',
                      value: _money(
                        purchase.discountMinorUnits,
                        purchase.currencyCode,
                        currency,
                      ),
                    ),
                    _AmountRow(
                      label: 'Impuestos',
                      value: _money(
                        purchase.taxMinorUnits,
                        purchase.currencyCode,
                        currency,
                      ),
                    ),
                    const Divider(height: 24),
                    _AmountRow(
                      label: 'Total',
                      value: _money(
                        purchase.totalMinorUnits,
                        purchase.currencyCode,
                        currency,
                      ),
                      bold: true,
                    ),
                    if (isConfirmed) ...[
                      const SizedBox(height: 8),
                      _AmountRow(
                        label: 'Pagado',
                        value: _money(paid, purchase.currencyCode, currency),
                      ),
                      _AmountRow(
                        label: 'Saldo pendiente',
                        value: _money(balance, purchase.currencyCode, currency),
                        bold: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (purchase.status == 'cancelled') ...[
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Esta compra está anulada. Sus movimientos históricos se conservan.',
                  ),
                ),
              ),
            ],
            if (isDraft && details.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Agrega productos antes de confirmar la compra.',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _message(String value) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(value, textAlign: TextAlign.center),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'draft' => 'Borrador',
      'confirmed' => 'Confirmada',
      'cancelled' => 'Anulada',
      _ => status,
    };

    return Chip(label: Text(label));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/'
    '${value.year}';

String _quantity(int milliUnits) {
  final whole = milliUnits ~/ 1000;
  final fraction = (milliUnits % 1000).toString().padLeft(3, '0');
  final trimmed = fraction.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.isEmpty ? '$whole' : '$whole.$trimmed';
}

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
