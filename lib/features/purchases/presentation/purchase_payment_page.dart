import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/purchase_providers.dart';

class PurchasePaymentPage extends ConsumerStatefulWidget {
  const PurchasePaymentPage({required this.purchaseId, super.key});

  final String purchaseId;

  @override
  ConsumerState<PurchasePaymentPage> createState() =>
      _PurchasePaymentPageState();
}

class _PurchasePaymentPageState extends ConsumerState<PurchasePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String? _currencyCode;
  String _paymentMethod = 'cash';
  bool _saving = false;

  static const _maxSqliteInteger = 9223372036854775807;
  static const _paymentMethods = <String, String>{
    'cash': 'Efectivo',
    'bank_transfer': 'Transferencia bancaria',
    'card': 'Tarjeta',
    'check': 'Cheque',
    'other': 'Otro',
  };

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int? _parseAmount(String value, int digits) {
    if (digits < 0 || digits > 9) return null;

    final normalized = value.trim().replaceAll(',', '.');
    final parts = normalized.split('.');

    if (parts.length > 2 ||
        parts.first.isEmpty ||
        !RegExp(r'^\d+$').hasMatch(parts.first)) {
      return null;
    }

    if (parts.length == 2 &&
        (digits == 0 ||
            parts[1].isEmpty ||
            parts[1].length > digits ||
            !RegExp(r'^\d+$').hasMatch(parts[1]))) {
      return null;
    }

    try {
      final factor = BigInt.from(10).pow(digits);
      final scaled =
          Decimal.parse(normalized) * Decimal.parse(factor.toString());
      final amount = scaled.toBigInt();

      if (amount <= BigInt.zero || amount > BigInt.from(_maxSqliteInteger)) {
        return null;
      }

      return amount.toInt();
    } on FormatException {
      return null;
    } on RangeError {
      return null;
    }
  }

  String _formatAmount(int minorUnits, int digits) {
    final factor = BigInt.from(10).pow(digits);
    final amount = BigInt.from(minorUnits);
    final whole = amount ~/ factor;

    if (digits == 0) return whole.toString();

    final fraction = (amount % factor).toString().padLeft(digits, '0');
    return '$whole.$fraction';
  }

  String _currencyAmount(int amount, Currency? currency) {
    final digits = currency?.decimalDigits ?? 2;
    final symbol = currency?.symbol ?? currency?.code ?? '';
    return '${_formatAmount(amount, digits)} $symbol'.trim();
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha del pago',
    );

    if (selected != null && mounted) {
      setState(() => _paymentDate = selected);
    }
  }

  Future<void> _save(Purchase purchase, Currency currency) async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final amount = _parseAmount(_amountController.text, currency.decimalDigits);
    if (amount == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await ref
          .read(supplierPaymentRepositoryProvider)
          .registerPayment(
            purchaseId: purchase.id,
            amountMinorUnits: amount,
            currencyCode: currency.code,
            paymentDate: _paymentDate,
            paymentMethod: _paymentMethod,
            reference: _referenceController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado correctamente.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;

      final message = error is ArgumentError || error is StateError
          ? error.toString().replaceFirst(
              RegExp(r'^(Invalid argument\(s\): |Bad state: )'),
              '',
            )
          : 'No se pudo registrar el pago.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseAsync = ref.watch(purchaseByIdProvider(widget.purchaseId));
    final paymentsAsync = ref.watch(
      purchasePaymentsProvider(widget.purchaseId),
    );
    final currenciesAsync = ref.watch(purchaseCurrenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago al proveedor')),
      body: purchaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _loadError('No se pudo cargar la compra: $error'),
        data: (purchase) {
          if (purchase == null) {
            return _loadError('La compra ya no existe.');
          }
          if (purchase.status != 'confirmed') {
            return _loadError('Solo se pueden pagar compras confirmadas.');
          }

          return paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _loadError('No se pudieron cargar los pagos: $error'),
            data: (payments) => currenciesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  _loadError('No se pudieron cargar las monedas: $error'),
              data: (currencies) =>
                  _buildContent(purchase, payments, currencies),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    Purchase purchase,
    List<SupplierPayment> payments,
    List<Currency> currencies,
  ) {
    final paid = payments.fold<int>(
      0,
      (total, payment) => total + payment.appliedAmountMinorUnits,
    );
    final balance = purchase.totalMinorUnits - paid;

    final purchaseCurrencyMatches = currencies.where(
      (currency) => currency.code == purchase.currencyCode,
    );
    final purchaseCurrency = purchaseCurrencyMatches.isEmpty
        ? null
        : purchaseCurrencyMatches.first;

    final activeCurrencies = currencies
        .where((currency) => currency.isActive)
        .toList();

    if (balance <= 0) {
      return _loadError('Esta compra ya está pagada completamente.');
    }

    if (activeCurrencies.isEmpty) {
      return _loadError(
        'No hay monedas activas. Activa una moneda en Configuración para registrar el pago.',
      );
    }

    final selectedCode =
        activeCurrencies.any((currency) => currency.code == _currencyCode)
        ? _currencyCode!
        : activeCurrencies.any(
            (currency) => currency.code == purchase.currencyCode,
          )
        ? purchase.currencyCode
        : activeCurrencies.first.code;

    final selectedCurrency = activeCurrencies.firstWhere(
      (currency) => currency.code == selectedCode,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de la compra',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        'Total',
                        _currencyAmount(
                          purchase.totalMinorUnits,
                          purchaseCurrency,
                        ),
                      ),
                      _summaryRow(
                        'Pagado',
                        _currencyAmount(paid, purchaseCurrency),
                      ),
                      const Divider(height: 20),
                      _summaryRow(
                        'Saldo pendiente',
                        _currencyAmount(balance, purchaseCurrency),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Datos del pago',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCode,
                decoration: const InputDecoration(
                  labelText: 'Moneda del pago',
                  border: OutlineInputBorder(),
                ),
                items: activeCurrencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency.code,
                    child: Text('${currency.code} · ${currency.name}'),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _currencyCode = value);
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Importe',
                  hintText: selectedCurrency.decimalDigits == 0
                      ? '0'
                      : '0.${'0' * selectedCurrency.decimalDigits}',
                  prefixText: '${selectedCurrency.symbol} ',
                  helperText:
                      'Introduce el importe en ${selectedCurrency.code}.',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    _parseAmount(value ?? '', selectedCurrency.decimalDigits) ==
                        null
                    ? 'Introduce un importe válido con hasta ${selectedCurrency.decimalDigits} decimales.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _paymentMethod = value);
                        }
                      },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('Fecha del pago: ${_date(_paymentDate)}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceController,
                enabled: !_saving,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Referencia (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                enabled: !_saving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving
                    ? null
                    : () => _save(purchase, selectedCurrency),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Registrando...' : 'Registrar pago'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _loadError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
