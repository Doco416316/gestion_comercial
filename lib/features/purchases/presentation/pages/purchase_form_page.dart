import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';
import '../../../../features/purchases/domain/purchase_calculation_service.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  const PurchaseFormPage({super.key, this.purchaseId});

  final String? purchaseId;

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _DraftLine {
  _DraftLine({required this.product, required this.input});

  final Product product;
  final PurchaseLineCalculationInput input;
}

class _LineFormData {
  _LineFormData({
    required this.product,
    required this.quantityMilliUnits,
    required this.unitCostMinorUnits,
    required this.discount,
    required this.tax,
  });

  final Product product;
  final int quantityMilliUnits;
  final int unitCostMinorUnits;
  final PurchaseAdjustmentInput discount;
  final PurchaseAdjustmentInput tax;
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final PurchaseCalculationService _calculationService =
      PurchaseCalculationService();

  bool _loading = true;
  String? _purchaseId;
  Purchase? _purchase;
  List<PurchaseDetail> _details = <PurchaseDetail>[];

  List<Supplier> _suppliers = const <Supplier>[];
  List<Currency> _currencies = const <Currency>[];
  List<Product> _products = const <Product>[];

  String? _supplierId;
  String? _currencyCode;
  DateTime _purchaseDate = DateTime.now();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<_DraftLine> _draftLines = <_DraftLine>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _purchaseId = widget.purchaseId;
    _loadCatalogs();
    if (_purchaseId != null) {
      _loadPurchase();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _documentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final suppliers = await ref
          .read(supplierRepositoryProvider)
          .watchAll()
          .first;
      final currencies = await ref
          .read(currencyRepositoryProvider)
          .watchAll()
          .first;
      final products = await ref
          .read(productRepositoryProvider)
          .watchActiveProducts()
          .first;
      if (!mounted) return;
      setState(() {
        _suppliers = suppliers;
        _currencies = currencies;
        _products = products;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    }
  }

  Future<void> _loadPurchase() async {
    setState(() => _loading = true);
    try {
      final repository = ref.read(purchaseRepositoryProvider);
      final purchase = await repository.findById(_purchaseId!);
      final details = await repository.getDetails(_purchaseId!);
      if (!mounted) return;
      setState(() {
        _purchase = purchase;
        _details = details;
        if (purchase != null) {
          _supplierId = purchase.supplierId;
          _currencyCode = purchase.currencyCode;
          _purchaseDate = purchase.purchaseDate;
          _documentController.text = purchase.documentNumber ?? '';
          _notesController.text = purchase.notes ?? '';
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    }
  }

  PurchaseLineCalculationInput _detailToInput(PurchaseDetail detail) {
    PurchaseAdjustmentInput discount;
    if (detail.discountType == 'percentage') {
      discount = PurchaseAdjustmentInput.percentage(
        Decimal.parse(detail.discountRate ?? '0'),
      );
    } else {
      discount = PurchaseAdjustmentInput.fixed(detail.discountMinorUnits);
    }

    PurchaseAdjustmentInput tax;
    if (detail.taxType == 'percentage') {
      tax = PurchaseAdjustmentInput.percentage(
        Decimal.parse(detail.taxRate ?? '0'),
      );
    } else {
      tax = PurchaseAdjustmentInput.fixed(detail.taxMinorUnits);
    }

    return PurchaseLineCalculationInput(
      quantityMilliUnits: detail.quantityMilliUnits,
      unitCostMinorUnits: detail.unitCostMinorUnits,
      discount: discount,
      tax: tax,
    );
  }

  PurchaseCalculationResult? get _result {
    final inputs = _purchaseId == null
        ? _draftLines.map((line) => line.input).toList()
        : _details.map(_detailToInput).toList();
    if (inputs.isEmpty) return null;
    try {
      return _calculationService.calculatePurchase(inputs);
    } catch (_) {
      return null;
    }
  }

  Future<void> _createDraft() async {
    if (_supplierId == null || _currencyCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona proveedor y moneda')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = ref.read(purchaseRepositoryProvider);
      final id = await repository.createDraft(
        supplierId: _supplierId!,
        purchaseDate: _purchaseDate,
        currencyCode: _currencyCode!,
        documentNumber: _documentController.text.trim().isEmpty
            ? null
            : _documentController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      for (final line in _draftLines) {
        await repository.addDetail(
          purchaseId: id,
          productId: line.product.id,
          quantityMilliUnits: line.input.quantityMilliUnits,
          unitCostMinorUnits: line.input.unitCostMinorUnits,
          discount: line.input.discount,
          tax: line.input.tax,
        );
      }

      if (!mounted) return;
      setState(() {
        _purchaseId = id;
        _draftLines.clear();
      });
      await _loadPurchase();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Borrador creado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateHeader() async {
    if (_purchaseId == null || _supplierId == null || _currencyCode == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(purchaseRepositoryProvider)
          .updateDraftHeader(
            purchaseId: _purchaseId!,
            supplierId: _supplierId!,
            purchaseDate: _purchaseDate,
            currencyCode: _currencyCode!,
            documentNumber: _documentController.text.trim().isEmpty
                ? null
                : _documentController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      await _loadPurchase();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Borrador actualizado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addLine() async {
    final result = await showDialog<_LineFormData>(
      context: context,
      builder: (dialogContext) => _AddLineDialog(products: _products),
    );
    if (result == null) return;

    final input = PurchaseLineCalculationInput(
      quantityMilliUnits: result.quantityMilliUnits,
      unitCostMinorUnits: result.unitCostMinorUnits,
      discount: result.discount,
      tax: result.tax,
    );

    if (_purchaseId == null) {
      setState(() {
        _draftLines.add(_DraftLine(product: result.product, input: input));
      });
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(purchaseRepositoryProvider)
          .addDetail(
            purchaseId: _purchaseId!,
            productId: result.product.id,
            quantityMilliUnits: result.quantityMilliUnits,
            unitCostMinorUnits: result.unitCostMinorUnits,
            discount: result.discount,
            tax: result.tax,
          );
      await _loadPurchase();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeDraftLine(int index) async {
    setState(() => _draftLines.removeAt(index));
  }

  Future<void> _removeDetail(String detailId) async {
    if (_purchaseId == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(purchaseRepositoryProvider)
          .removeDetail(purchaseId: _purchaseId!, detailId: detailId);
      await _loadPurchase();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirm() async {
    if (_purchaseId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(purchaseRepositoryProvider).confirmPurchase(_purchaseId!);
      await _loadPurchase();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Compra confirmada')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancel() async {
    if (_purchaseId == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cancelar compra'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Motivo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Cancelar compra'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(purchaseRepositoryProvider)
          .cancelPurchase(purchaseId: _purchaseId!, reason: reason);
      await _loadPurchase();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Compra cancelada')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = _result;
    final isDraft = _purchase == null || _purchase!.status == 'draft';
    final isConfirmed = _purchase?.status == 'confirmed';

    return Scaffold(
      appBar: AppBar(
        title: Text(_purchaseId == null ? 'Nueva compra' : 'Editar compra'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _supplierId,
              decoration: const InputDecoration(labelText: 'Proveedor'),
              items: _suppliers
                  .map(
                    (supplier) => DropdownMenuItem<String>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    ),
                  )
                  .toList(),
              onChanged: isDraft && !_saving
                  ? (value) => setState(() => _supplierId = value)
                  : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _currencyCode,
              decoration: const InputDecoration(labelText: 'Moneda'),
              items: _currencies
                  .map(
                    (currency) => DropdownMenuItem<String>(
                      value: currency.code,
                      child: Text('${currency.code} - ${currency.name}'),
                    ),
                  )
                  .toList(),
              onChanged: isDraft && !_saving && _purchaseId == null
                  ? (value) => setState(() => _currencyCode = value)
                  : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Fecha: ${_purchaseDate.toIso8601String()}'),
              trailing: isDraft && !_saving
                  ? TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _purchaseDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _purchaseDate = picked);
                        }
                      },
                      child: const Text('Cambiar'),
                    )
                  : null,
            ),
            TextField(
              controller: _documentController,
              decoration: const InputDecoration(labelText: 'Documento'),
              enabled: isDraft && !_saving,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas'),
              enabled: isDraft && !_saving,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Líneas', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (isDraft)
                  TextButton.icon(
                    onPressed: _saving ? null : _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir línea'),
                  ),
              ],
            ),
            if (_purchaseId == null)
              ..._draftLines.asMap().entries.map((entry) {
                final index = entry.key;
                final line = entry.value;
                return ListTile(
                  title: Text(line.product.name),
                  subtitle: Text(
                    '${line.input.quantityMilliUnits} milésimas · '
                    '${line.input.unitCostMinorUnits} unidades menores',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _saving ? null : () => _removeDraftLine(index),
                  ),
                );
              })
            else
              ..._details.map((detail) {
                return ListTile(
                  title: Text(detail.productNameSnapshot),
                  subtitle: Text(
                    '${detail.quantityMilliUnits} milésimas · '
                    '${detail.unitCostMinorUnits} unidades menores',
                  ),
                  trailing: isDraft
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _saving
                              ? null
                              : () => _removeDetail(detail.id),
                        )
                      : null,
                );
              }),
            const SizedBox(height: 16),
            if (result != null) ...[
              Text('Subtotal: ${result.subtotalMinorUnits}'),
              Text('Descuento: ${result.discountMinorUnits}'),
              Text('Impuestos: ${result.taxMinorUnits}'),
              Text('Total: ${result.totalMinorUnits}'),
            ],
            const SizedBox(height: 16),
            if (_saving)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                children: [
                  if (_purchaseId == null)
                    FilledButton(
                      onPressed: _createDraft,
                      child: const Text('Crear borrador'),
                    )
                  else if (isDraft) ...[
                    FilledButton(
                      onPressed: _updateHeader,
                      child: const Text('Guardar'),
                    ),
                    FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirmar'),
                    ),
                    OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar compra'),
                    ),
                  ],
                ],
              ),
            if (isConfirmed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Compra confirmada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.products});

  final List<Product> products;

  @override
  ConsumerState<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends ConsumerState<_AddLineDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  Product? _selectedProduct;
  String _discountType = 'fixed';
  String _taxType = 'fixed';

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  PurchaseAdjustmentInput _buildAdjustment(String type, String value) {
    if (type == 'percentage') {
      final parsed = Decimal.tryParse(value.trim()) ?? Decimal.zero;
      return PurchaseAdjustmentInput.percentage(parsed);
    }
    final amount = int.tryParse(value.trim()) ?? 0;
    return PurchaseAdjustmentInput.fixed(amount);
  }

  void _submit() {
    final product = _selectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un producto')));
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    final cost = int.tryParse(_costController.text.trim());
    if (quantity == null || quantity <= 0 || cost == null || cost < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad o coste inválido')),
      );
      return;
    }

    final result = _LineFormData(
      product: product,
      quantityMilliUnits: quantity,
      unitCostMinorUnits: cost,
      discount: _buildAdjustment(_discountType, _discountController.text),
      tax: _buildAdjustment(_taxType, _taxController.text),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir línea'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                isExpanded: true,
                value: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: widget.products
                    .map(
                      (product) => DropdownMenuItem<Product>(
                        value: product,
                        child: Text('${product.sku} - ${product.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProduct = value),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (milésimas)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Coste unitario (unidades menores)',
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _discountType,
                decoration: const InputDecoration(labelText: 'Tipo descuento'),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fijo')),
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Porcentaje'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _discountType = value);
                },
              ),
              TextField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Descuento'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _taxType,
                decoration: const InputDecoration(labelText: 'Tipo impuesto'),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fijo')),
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Porcentaje'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _taxType = value);
                },
              ),
              TextField(
                controller: _taxController,
                decoration: const InputDecoration(labelText: 'Impuesto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Añadir')),
      ],
    );
  }
}
