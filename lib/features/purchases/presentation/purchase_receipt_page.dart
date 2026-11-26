import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/purchase_receipt_repository.dart';
import 'providers/purchase_providers.dart';

class PurchaseReceiptPage extends ConsumerStatefulWidget {
  const PurchaseReceiptPage({required this.purchaseId, super.key});

  final String purchaseId;

  @override
  ConsumerState<PurchaseReceiptPage> createState() =>
      _PurchaseReceiptPageState();
}

class _PurchaseReceiptPageState extends ConsumerState<PurchaseReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _quantityControllers = {};

  DateTime _receivedAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(PurchaseDetail detail) {
    return _quantityControllers.putIfAbsent(
      detail.id,
      () => TextEditingController(text: '0'),
    );
  }

  int? _parseQuantity(String value) {
    final normalized = value.trim().replaceAll(',', '.');

    if (!RegExp(r'^\d+(?:\.\d{1,3})?$').hasMatch(normalized)) {
      return null;
    }

    final parts = normalized.split('.');
    final whole = int.tryParse(parts[0]);
    if (whole == null || whole > 9223372036854775) return null;

    final fraction = parts.length == 1
        ? 0
        : int.parse(parts[1].padRight(3, '0'));

    return whole * 1000 + fraction;
  }

  String _formatQuantity(int milliUnits) {
    final whole = milliUnits ~/ 1000;
    final fraction = milliUnits % 1000;
    if (fraction == 0) return '$whole';
    return '$whole.${fraction.toString().padLeft(3, '0').replaceFirst(RegExp(r'0+$'), '')}';
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _receivedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha de recepción',
    );

    if (selected != null && mounted) {
      setState(() => _receivedAt = selected);
    }
  }

  Future<void> _save(
    Purchase purchase,
    List<PurchaseDetail> details,
    Map<String, int> receivedQuantities,
  ) async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final lines = <PurchaseReceiptLineInput>[];

    for (final detail in details) {
      final quantity = _parseQuantity(_controllerFor(detail).text)!;
      if (quantity > 0) {
        lines.add(
          PurchaseReceiptLineInput(
            purchaseDetailId: detail.id,
            quantityMilliUnits: quantity,
          ),
        );
      }
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce una cantidad recibida en algún producto.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await ref
          .read(purchaseReceiptRepositoryProvider)
          .createReceipt(
            purchaseId: purchase.id,
            lines: lines,
            receivedAt: _receivedAt,
            reference: _referenceController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recepción registrada correctamente.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;

      final message = error is ArgumentError || error is StateError
          ? error.toString().replaceFirst(
              RegExp(r'^(Invalid argument\(s\): |Bad state: )'),
              '',
            )
          : 'No se pudo registrar la recepción.';

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
    final detailsAsync = ref.watch(purchaseDetailsProvider(widget.purchaseId));
    final receivedAsync = ref.watch(
      purchaseReceivedQuantitiesProvider(widget.purchaseId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar recepción')),
      body: purchaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _loadError('No se pudo cargar la compra: $error'),
        data: (purchase) {
          if (purchase == null) {
            return _loadError('La compra ya no existe.');
          }

          if (purchase.status != 'confirmed') {
            return _loadError(
              'Solo se pueden registrar recepciones de compras confirmadas.',
            );
          }

          return detailsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _loadError('No se pudieron cargar los productos: $error'),
            data: (details) => receivedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _loadError(
                'No se pudieron cargar las cantidades recibidas: $error',
              ),
              data: (received) => _buildForm(purchase, details, received),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(
    Purchase purchase,
    List<PurchaseDetail> details,
    Map<String, int> received,
  ) {
    final pendingDetails = details.where((detail) {
      final quantity = received[detail.id] ?? 0;
      return quantity < detail.quantityMilliUnits;
    }).toList();

    if (details.isEmpty) {
      return _loadError('Esta compra no contiene productos.');
    }

    if (pendingDetails.isEmpty) {
      return _loadError('Esta compra ya fue recibida completamente.');
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                purchase.documentNumber?.isNotEmpty == true
                    ? 'Compra ${purchase.documentNumber}'
                    : 'Compra ${purchase.id.substring(0, 8)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Introduce las cantidades que llegaron en esta recepción. '
                'Puedes registrar entregas parciales.',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de recepción',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _selectDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(_date(_receivedAt)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Referencia (opcional)',
                          hintText: 'Ej. REC-001',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notas (opcional)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 1000,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Productos pendientes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final detail in pendingDetails)
                _buildProductField(detail, received[detail.id] ?? 0),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Productos pendientes: ${pendingDetails.length}'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving
                    ? null
                    : () => _save(purchase, details, received),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.inventory_2_outlined),
                label: Text(_saving ? 'Guardando...' : 'Registrar recepción'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductField(PurchaseDetail detail, int alreadyReceived) {
    final pending = detail.quantityMilliUnits - alreadyReceived;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.productNameSnapshot,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('SKU: ${detail.skuSnapshot}'),
            Text('Unidad: ${detail.unitSnapshot}'),
            Text('Solicitado: ${_formatQuantity(detail.quantityMilliUnits)}'),
            Text('Recibido anteriormente: ${_formatQuantity(alreadyReceived)}'),
            Text(
              'Pendiente: ${_formatQuantity(pending)} ${detail.unitSnapshot}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllerFor(detail),
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad recibida (${detail.unitSnapshot})',
                hintText: '0',
                border: const OutlineInputBorder(),
                helperText: 'Máximo: ${_formatQuantity(pending)}',
              ),
              validator: (value) {
                final quantity = _parseQuantity(value ?? '');
                if (quantity == null) {
                  return 'Introduce una cantidad válida con hasta 3 decimales.';
                }
                if (quantity > pending) {
                  return 'No puede superar la cantidad pendiente.';
                }
                return null;
              },
            ),
          ],
        ),
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
