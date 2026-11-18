import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';
import '../../../../features/purchases/data/purchase_receipt_repository.dart';

class PurchaseReceiptPage extends ConsumerStatefulWidget {
  const PurchaseReceiptPage({super.key, this.purchaseId});

  final String? purchaseId;

  @override
  ConsumerState<PurchaseReceiptPage> createState() =>
      _PurchaseReceiptPageState();
}

class _PurchaseReceiptPageState extends ConsumerState<PurchaseReceiptPage> {
  String? _selectedPurchaseId;
  Purchase? _purchase;
  List<PurchaseDetail> _details = <PurchaseDetail>[];
  Map<String, int> _received = <String, int>{};
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  List<Purchase> _confirmedPurchases = const <Purchase>[];
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
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final purchases = await ref
          .read(purchaseRepositoryProvider)
          .watchAll()
          .first;
      if (!mounted) return;
      setState(() {
        _confirmedPurchases = purchases
            .where((purchase) => purchase.status == 'confirmed')
            .toList();
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
      final receiptRepository = ref.read(purchaseReceiptRepositoryProvider);
      final purchase = await purchaseRepository.findById(purchaseId);
      final details = await purchaseRepository.getDetails(purchaseId);
      final received = await receiptRepository.getReceivedQuantities(
        purchaseId,
      );
      if (!mounted) return;
      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      for (final detail in details) {
        _controllers[detail.id] = TextEditingController();
      }
      setState(() {
        _purchase = purchase;
        _details = details;
        _received = received;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    }
  }

  int _pending(PurchaseDetail detail) {
    final received = _received[detail.id] ?? 0;
    final pending = detail.quantityMilliUnits - received;
    return pending < 0 ? 0 : pending;
  }

  Future<void> _save() async {
    if (_selectedPurchaseId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una compra')));
      return;
    }

    final lines = <PurchaseReceiptLineInput>[];
    for (final detail in _details) {
      final text = _controllers[detail.id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final quantity = int.tryParse(text);
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cantidad inválida')));
        return;
      }
      final pending = _pending(detail);
      if (quantity > pending) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La cantidad supera lo pendiente (${pending} milésimas)',
            ),
          ),
        );
        return;
      }
      lines.add(
        PurchaseReceiptLineInput(
          purchaseDetailId: detail.id,
          quantityMilliUnits: quantity,
        ),
      );
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa cantidades a recibir')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(purchaseReceiptRepositoryProvider)
          .createReceipt(purchaseId: _selectedPurchaseId!, lines: lines);
      await _loadPurchase(_selectedPurchaseId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Recepción registrada')));
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
          _ReceiptHistoryDialog(purchaseId: _selectedPurchaseId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _selectedPurchaseId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recepción de compra')),
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
              Text('Proveedor: ${_purchase!.supplierId}'),
              Text('Estado: ${_purchase!.status}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Líneas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ],
              ),
              ..._details.map((detail) {
                final pending = _pending(detail);
                return ListTile(
                  title: Text(detail.productNameSnapshot),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Comprado: ${detail.quantityMilliUnits} milésimas'),
                      Text('Recibido: ${_received[detail.id] ?? 0} milésimas'),
                      Text('Pendiente: $pending milésimas'),
                      TextField(
                        controller: _controllers[detail.id],
                        decoration: const InputDecoration(
                          labelText: 'Cantidad a recibir (milésimas)',
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_saving && pending > 0,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              if (_saving)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton(
                  onPressed: _save,
                  child: const Text('Registrar recepción'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptHistoryDialog extends ConsumerStatefulWidget {
  const _ReceiptHistoryDialog({required this.purchaseId});

  final String purchaseId;

  @override
  ConsumerState<_ReceiptHistoryDialog> createState() =>
      _ReceiptHistoryDialogState();
}

class _ReceiptHistoryDialogState extends ConsumerState<_ReceiptHistoryDialog> {
  @override
  Widget build(BuildContext context) {
    final receiptRepository = ref.watch(purchaseReceiptRepositoryProvider);

    return AlertDialog(
      title: const Text('Historial de recepciones'),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<PurchaseReceipt>>(
          future: receiptRepository.getByPurchase(widget.purchaseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(readableErrorMessage(snapshot.error!)));
            }

            final receipts = snapshot.data ?? const <PurchaseReceipt>[];

            if (receipts.isEmpty) {
              return const Center(child: Text('Sin recepciones'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return FutureBuilder<List<PurchaseReceiptDetail>>(
                  future: receiptRepository.getReceiptDetails(receipt.id),
                  builder: (context, detailSnapshot) {
                    final details =
                        detailSnapshot.data ?? const <PurchaseReceiptDetail>[];
                    final total = details.fold<int>(
                      0,
                      (sum, detail) => sum + detail.quantityMilliUnits,
                    );
                    return ListTile(
                      title: Text('Recepción ${receipt.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Fecha: ${receipt.receivedAt}'),
                          Text('Cantidad: $total milésimas'),
                        ],
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
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
