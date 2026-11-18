import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class SupplierPaymentPage extends ConsumerStatefulWidget {
  const SupplierPaymentPage({super.key, this.purchaseId});

  final String? purchaseId;

  @override
  ConsumerState<SupplierPaymentPage> createState() =>
      _SupplierPaymentPageState();
}

class _SupplierPaymentPageState extends ConsumerState<SupplierPaymentPage> {
  String? _selectedPurchaseId;
  Purchase? _purchase;
  List<Currency> _currencies = const <Currency>[];
  List<Purchase> _confirmedPurchases = const <Purchase>[];

  int _paidAmount = 0;
  int _outstandingBalance = 0;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _paymentCurrencyCode;
  DateTime _paymentDate = DateTime.now();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedPurchaseId = widget.purchaseId;
    _loadCatalogs();
    if (_selectedPurchaseId != null) {
      _loadPurchase(_selectedPurchaseId!);
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final currencies = await ref
          .read(currencyRepositoryProvider)
          .watchAll()
          .first;
      final purchases = await ref
          .read(purchaseRepositoryProvider)
          .watchAll()
          .first;
      if (!mounted) return;
      setState(() {
        _currencies = currencies;
        _confirmedPurchases = purchases
            .where((purchase) => purchase.status == 'confirmed')
            .toList();
        if (_paymentCurrencyCode == null && currencies.isNotEmpty) {
          _paymentCurrencyCode = currencies.first.code;
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    }
  }

  Future<void> _loadPurchase(String purchaseId) async {
    setState(() => _loading = true);
    try {
      final purchaseRepository = ref.read(purchaseRepositoryProvider);
      final paymentRepository = ref.read(supplierPaymentRepositoryProvider);
      final purchase = await purchaseRepository.findById(purchaseId);
      final paid = await paymentRepository.getPaidAmount(purchaseId);
      final outstanding = await paymentRepository.getOutstandingBalance(
        purchaseId,
      );
      if (!mounted) return;
      setState(() {
        _purchase = purchase;
        _paidAmount = paid;
        _outstandingBalance = outstanding;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    }
  }

  Future<void> _save() async {
    if (_selectedPurchaseId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una compra')));
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Monto inválido')));
      return;
    }

    final method = _methodController.text.trim();
    if (method.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El método de pago es obligatorio')),
      );
      return;
    }

    if (_paymentCurrencyCode == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una moneda')));
      return;
    }

    if (amount > _outstandingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El monto supera el saldo pendiente ($_outstandingBalance)',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(supplierPaymentRepositoryProvider)
          .registerPayment(
            purchaseId: _selectedPurchaseId!,
            amountMinorUnits: amount,
            currencyCode: _paymentCurrencyCode!,
            paymentDate: _paymentDate,
            paymentMethod: method,
            reference: _referenceController.text.trim().isEmpty
                ? null
                : _referenceController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      _amountController.clear();
      await _loadPurchase(_selectedPurchaseId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pago registrado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showHistory() async {
    if (_selectedPurchaseId == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          _PaymentHistoryDialog(purchaseId: _selectedPurchaseId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _selectedPurchaseId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pagos a proveedores')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.purchaseId == null)
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedPurchaseId,
                decoration: const InputDecoration(
                  labelText: 'Compra confirmada',
                ),
                items: _confirmedPurchases
                    .map(
                      (purchase) => DropdownMenuItem<String>(
                        value: purchase.id,
                        child: Text(purchase.id),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedPurchaseId = value);
                          _loadPurchase(value);
                        }
                      },
              ),
            if (_purchase != null) ...[
              const SizedBox(height: 8),
              Text('Compra: ${_purchase!.id}'),
              Text(
                'Total: ${_purchase!.totalMinorUnits} ${_purchase!.currencyCode}',
              ),
              Text('Pagado: $_paidAmount'),
              Text('Saldo pendiente: $_outstandingBalance'),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto (unidades menores)',
                ),
                keyboardType: TextInputType.number,
                enabled: !_saving,
              ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _paymentCurrencyCode,
                decoration: const InputDecoration(labelText: 'Moneda de pago'),
                items: _currencies
                    .map(
                      (currency) => DropdownMenuItem<String>(
                        value: currency.code,
                        child: Text('${currency.code} - ${currency.name}'),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _paymentCurrencyCode = value),
              ),
              TextField(
                controller: _methodController,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                enabled: !_saving,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Fecha: ${_paymentDate.toIso8601String()}'),
                trailing: _saving
                    ? null
                    : TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _paymentDate = picked);
                          }
                        },
                        child: const Text('Cambiar'),
                      ),
              ),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Referencia'),
                enabled: !_saving,
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_saving)
                    const CircularProgressIndicator()
                  else
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Registrar pago'),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _showHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryDialog extends ConsumerStatefulWidget {
  const _PaymentHistoryDialog({required this.purchaseId});

  final String purchaseId;

  @override
  ConsumerState<_PaymentHistoryDialog> createState() =>
      _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends ConsumerState<_PaymentHistoryDialog> {
  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(supplierPaymentRepositoryProvider);

    return AlertDialog(
      title: const Text('Historial de pagos'),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<SupplierPayment>>(
          future: repository.getByPurchase(widget.purchaseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(readableErrorMessage(snapshot.error!)));
            }

            final payments = snapshot.data ?? const <SupplierPayment>[];

            if (payments.isEmpty) {
              return const Center(child: Text('Sin pagos'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ListTile(
                  title: Text(
                    '${payment.amountMinorUnits} ${payment.currencyCode}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Aplicado: ${payment.appliedAmountMinorUnits}'),
                      Text('Método: ${payment.paymentMethod}'),
                      Text('Fecha: ${payment.paymentDate}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
