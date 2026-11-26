import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'sale_form_page.dart';
import 'providers/sales_providers.dart';

class SaleDetailPage extends ConsumerWidget {
  const SaleDetailPage({required this.saleId, super.key});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleByIdProvider(saleId));
    final detailsAsync = ref.watch(saleDetailsProvider(saleId));
    final paymentsAsync = ref.watch(salePaymentsProvider(saleId));
    final customersAsync = ref.watch(salesCustomersProvider);
    final currenciesAsync = ref.watch(salesCurrenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de venta'),
        actions: [
          IconButton(
            tooltip: 'Volver a ventas',
            onPressed: () => context.go('/sales'),
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: saleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _message('No se pudo cargar la venta: $error'),
        data: (sale) {
          if (sale == null) {
            return _message('La venta ya no existe.');
          }
          return currenciesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _message('No se pudieron cargar las monedas: $error'),
            data: (currencies) {
              final currency = currencies.where(
                (item) => item.code == sale.currencyCode,
              );
              final selectedCurrency = currency.isEmpty ? null : currency.first;
              return customersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _message('No se pudieron cargar los clientes: $error'),
                data: (customers) {
                  final customer = customers.where(
                    (item) => item.id == sale.customerId,
                  );
                  final customerName = customer.isEmpty
                      ? (sale.customerId == null
                            ? 'Sin cliente'
                            : 'Cliente no disponible')
                      : customer.first.name;
                  return detailsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        _message('No se pudieron cargar los productos: $error'),
                    data: (details) => paymentsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) =>
                          _message('No se pudieron cargar los pagos: $error'),
                      data: (payments) => _buildContent(
                        context,
                        ref,
                        sale,
                        details,
                        payments,
                        selectedCurrency,
                        customerName,
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
    WidgetRef ref,
    Sale sale,
    List<SaleDetail> details,
    List<SalePayment> payments,
    Currency? currency,
    String customerName,
  ) {
    final paid = payments.fold<int>(
      0,
      (total, payment) => total + payment.appliedAmountMinorUnits,
    );
    final balance = sale.totalMinorUnits - paid;
    final isDraft = sale.status == 'draft';
    final isConfirmed = sale.status == 'confirmed';

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
                            sale.documentNumber?.isNotEmpty == true
                                ? 'Venta ${sale.documentNumber}'
                                : 'Venta ${sale.id.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _StatusChip(status: sale.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Cliente', value: customerName),
                    _InfoRow(label: 'Fecha', value: _date(sale.saleDate)),
                    _InfoRow(
                      label: 'Condición',
                      value: sale.paymentType == 'cash' ? 'Contado' : 'Crédito',
                    ),
                    _InfoRow(label: 'Moneda', value: sale.currencyCode),
                    if (sale.notes?.isNotEmpty == true)
                      _InfoRow(label: 'Notas', value: sale.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isDraft)
                  FilledButton.tonalIcon(
                    onPressed: () => showAddSaleLineDialog(
                      context: context,
                      ref: ref,
                      sale: sale,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (details.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Esta venta todavía no tiene productos.'),
                ),
              )
            else
              ...details.map(
                (detail) => Card(
                  child: ListTile(
                    title: Text(detail.productNameSnapshot),
                    subtitle: Text(
                      '${detail.skuSnapshot} · ${_quantity(detail.quantityMilliUnits)} ${detail.unitSnapshot} × ${_money(detail.unitPriceMinorUnits, sale.currencyCode, currency)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _money(
                            detail.totalMinorUnits,
                            sale.currencyCode,
                            currency,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isDraft)
                          IconButton(
                            tooltip: 'Quitar producto',
                            onPressed: () =>
                                _removeDetail(context, ref, sale, detail),
                            icon: const Icon(Icons.delete_outline),
                          ),
                      ],
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
                        sale.subtotalMinorUnits,
                        sale.currencyCode,
                        currency,
                      ),
                    ),
                    _AmountRow(
                      label: 'Descuentos',
                      value: _money(
                        sale.discountMinorUnits,
                        sale.currencyCode,
                        currency,
                      ),
                    ),
                    _AmountRow(
                      label: 'Impuestos',
                      value: _money(
                        sale.taxMinorUnits,
                        sale.currencyCode,
                        currency,
                      ),
                    ),
                    const Divider(height: 24),
                    _AmountRow(
                      label: 'Total',
                      value: _money(
                        sale.totalMinorUnits,
                        sale.currencyCode,
                        currency,
                      ),
                      emphasized: true,
                    ),
                    if (isConfirmed) ...[
                      const Divider(height: 24),
                      _AmountRow(
                        label: 'Pagado',
                        value: _money(paid, sale.currencyCode, currency),
                      ),
                      _AmountRow(
                        label: 'Saldo pendiente',
                        value: _money(balance, sale.currencyCode, currency),
                        emphasized: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Pagos registrados',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...payments.map(
                (payment) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(
                      _money(
                        payment.appliedAmountMinorUnits,
                        sale.currencyCode,
                        currency,
                      ),
                    ),
                    subtitle: Text(
                      '${_date(payment.paymentDate)} · ${payment.paymentMethod}',
                    ),
                    trailing: Text(payment.currencyCode),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (isDraft) ...[
              FilledButton.icon(
                onPressed: details.isEmpty
                    ? null
                    : () => _confirm(context, ref, sale, currency),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar venta'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _deleteDraft(context, ref, sale),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar borrador'),
              ),
            ] else if (isConfirmed) ...[
              if (balance > 0) ...[
                FilledButton.icon(
                  onPressed: () =>
                      _registerPayment(context, ref, sale, currency),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar abono'),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => _cancelSale(context, ref, sale),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar venta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
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

  Future<void> _removeDetail(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
    SaleDetail detail,
  ) async {
    try {
      await ref
          .read(salesRepositoryProvider)
          .removeDetail(saleId: sale.id, detailId: detail.id);
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'No se pudo quitar el producto: $error');
      }
    }
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
    Currency? currency,
  ) async {
    final payment = await showDialog<_PaymentEntry>(
      context: context,
      builder: (_) => _PaymentEntryDialog(
        title: 'Confirmar venta',
        description: sale.paymentType == 'cash'
            ? 'La venta de contado debe quedar pagada en su totalidad.'
            : 'Indica el abono inicial. Puedes registrar el resto después.',
        initialAmountMinor: sale.paymentType == 'cash'
            ? sale.totalMinorUnits
            : 0,
        digits: currency?.decimalDigits ?? 2,
        readOnlyAmount: sale.paymentType == 'cash',
        actionLabel: 'Confirmar',
      ),
    );
    if (payment == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(salesRepositoryProvider)
          .confirmSale(
            saleId: sale.id,
            initialPaymentMinorUnits: payment.amountMinorUnits,
            initialPaymentMethod: payment.method,
          );
      if (context.mounted) {
        _snack(context, 'Venta confirmada correctamente.');
      }
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'No se pudo confirmar la venta: $error');
      }
    }
  }

  Future<void> _registerPayment(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
    Currency? currency,
  ) async {
    final payment = await showDialog<_PaymentEntry>(
      context: context,
      builder: (_) => _PaymentEntryDialog(
        title: 'Registrar abono',
        description: 'El importe se registrará en ${sale.currencyCode}.',
        initialAmountMinor: 0,
        digits: currency?.decimalDigits ?? 2,
        actionLabel: 'Registrar abono',
      ),
    );
    if (payment == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(salesRepositoryProvider)
          .registerPayment(
            saleId: sale.id,
            amountMinorUnits: payment.amountMinorUnits,
            currencyCode: sale.currencyCode,
            paymentDate: DateTime.now(),
            paymentMethod: payment.method,
          );
      if (context.mounted) {
        _snack(context, 'Abono registrado correctamente.');
      }
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'No se pudo registrar el abono: $error');
      }
    }
  }

  Future<void> _cancelSale(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String cancellationReason = '';

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Cancelar venta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se repondrá el inventario mediante movimientos '
                  'compensatorios. Los pagos históricos se conservarán '
                  'sin modificaciones; las devoluciones de dinero '
                  'deberán registrarse por separado.',
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  maxLength: 250,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de cancelación',
                    hintText: 'Describe por qué se cancela la venta',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (value) {
                    setState(() => cancellationReason = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Volver'),
              ),
              FilledButton(
                onPressed: cancellationReason.trim().isEmpty
                    ? null
                    : () => Navigator.pop(
                        dialogContext,
                        cancellationReason.trim(),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Confirmar cancelación'),
              ),
            ],
          ),
        );
      },
    );

    if (reason == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(salesRepositoryProvider)
          .cancelSale(saleId: sale.id, reason: reason);

      if (context.mounted) {
        _snack(context, 'Venta cancelada correctamente.');
      }
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'No se pudo cancelar la venta: $error');
      }
    }
  }

  Future<void> _deleteDraft(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar borrador'),
        content: const Text(
          'Esta operación eliminará la venta y sus detalles. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await ref.read(salesRepositoryProvider).deleteDraft(sale.id);
      if (context.mounted) {
        context.go('/sales');
      }
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'No se pudo eliminar: $error');
      }
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PaymentEntry {
  const _PaymentEntry({required this.amountMinorUnits, required this.method});

  final int amountMinorUnits;
  final String method;
}

class _PaymentEntryDialog extends StatefulWidget {
  const _PaymentEntryDialog({
    required this.title,
    required this.description,
    required this.initialAmountMinor,
    required this.digits,
    required this.actionLabel,
    this.readOnlyAmount = false,
  });

  final String title;
  final String description;
  final int initialAmountMinor;
  final int digits;
  final String actionLabel;
  final bool readOnlyAmount;

  @override
  State<_PaymentEntryDialog> createState() => _PaymentEntryDialogState();
}

class _PaymentEntryDialogState extends State<_PaymentEntryDialog> {
  late final TextEditingController _amountController;
  final _methodController = TextEditingController(text: 'cash');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _formatMajor(widget.initialAmountMinor, widget.digits),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            readOnly: widget.readOnlyAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importe recibido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _methodController,
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              hintText: 'cash, transfer, card...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
    ],
  );

  void _submit() {
    try {
      final amount = _parseMinor(_amountController.text, widget.digits);
      final method = _methodController.text.trim();
      if (amount < 0 || method.isEmpty) {
        throw const FormatException('El importe y el método son obligatorios.');
      }
      Navigator.pop(
        context,
        _PaymentEntry(amountMinorUnits: amount, method: method),
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Datos no válidos: $error')));
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Confirmada', Colors.green),
      'cancelled' => ('Cancelada', Colors.red),
      _ => ('Borrador', Colors.orange),
    };
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
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
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        ),
        Text(
          value,
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
              : null,
        ),
      ],
    ),
  );
}

int _parseMinor(String value, int digits) {
  final parsed = Decimal.parse(value.trim().replaceAll(',', '.'));
  var factor = 1;
  for (var i = 0; i < digits; i++) {
    factor *= 10;
  }
  return (parsed * Decimal.fromInt(factor)).round().toBigInt().toInt();
}

String _formatMajor(int minor, int digits) {
  var factor = 1;
  for (var i = 0; i < digits; i++) {
    factor *= 10;
  }
  final whole = minor ~/ factor;
  final fraction = (minor % factor).toString().padLeft(digits, '0');
  return digits == 0 ? '$whole' : '$whole.$fraction';
}

String _money(int amount, String code, Currency? currency) {
  final digits = currency?.decimalDigits ?? 2;
  return '${currency?.symbol ?? code} ${_formatMajor(amount, digits)}';
}

String _quantity(int milli) {
  final whole = milli ~/ 1000;
  final fraction = (milli % 1000).toString().padLeft(3, '0');
  return fraction == '000'
      ? '$whole'
      : '$whole.${fraction.replaceFirst(RegExp(r'0+$'), '')}';
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
