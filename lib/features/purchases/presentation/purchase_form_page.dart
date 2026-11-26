import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../purchases/domain/purchase_calculation_service.dart';
import 'providers/purchase_providers.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final _documentController = TextEditingController();
  final _notesController = TextEditingController();

  String? _supplierId;
  String? _currencyCode;
  String? _purchaseId;
  bool _saving = false;

  @override
  void dispose() {
    _documentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(purchaseSuppliersProvider);
    final currenciesAsync = ref.watch(purchaseCurrenciesProvider);
    final productsAsync = ref.watch(purchaseProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_purchaseId == null ? 'Nueva compra' : 'Agregar productos'),
      ),
      body: suppliersAsync.when(
        loading: _loading,
        error: (error, _) => _loadError('proveedores', error),
        data: (allSuppliers) => currenciesAsync.when(
          loading: _loading,
          error: (error, _) => _loadError('monedas', error),
          data: (allCurrencies) => productsAsync.when(
            loading: _loading,
            error: (error, _) => _loadError('productos', error),
            data: (allProducts) {
              final suppliers = allSuppliers
                  .where((item) => item.isActive)
                  .toList();
              final currencies = allCurrencies
                  .where((item) => item.isActive)
                  .toList();

              if (currencies.isEmpty) {
                return _loadError(
                  'monedas activas',
                  'Activa al menos una moneda en Configuración.',
                );
              }

              _currencyCode ??= currencies
                  .firstWhere(
                    (item) => item.isBase,
                    orElse: () => currencies.first,
                  )
                  .code;

              if (_purchaseId == null) {
                return _buildHeader(suppliers, currencies);
              }

              return _buildDraft();
            },
          ),
        ),
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _loadError(String title, Object error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('No se pudieron cargar $title: $error'),
    ),
  );

  Widget _buildHeader(List<Supplier> suppliers, List<Currency> currencies) {
    final selectedCurrency = currencies.firstWhere(
      (item) => item.code == _currencyCode,
      orElse: () => currencies.first,
    );

    if (_supplierId != null &&
        !suppliers.any((item) => item.id == _supplierId)) {
      _supplierId = null;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Datos generales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _supplierId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Proveedor',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final supplier in suppliers)
                  DropdownMenuItem(
                    value: supplier.id,
                    child: Text(supplier.name),
                  ),
              ],
              onChanged: (value) {
                setState(() => _supplierId = value);
              },
            ),
            if (suppliers.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'No hay proveedores activos. Registra o activa un proveedor.',
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentController,
              decoration: const InputDecoration(
                labelText: 'Número de documento (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currencyCode,
              decoration: const InputDecoration(
                labelText: 'Moneda de la compra',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final currency in currencies)
                  DropdownMenuItem(
                    value: currency.code,
                    child: Text('${currency.code} · ${currency.name}'),
                  ),
              ],
              onChanged: (value) {
                setState(() => _currencyCode = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Después de crear el borrador podrás agregar, editar '
                      'y eliminar productos antes de confirmar la compra.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Moneda: ${selectedCurrency.code} '
                      '(${selectedCurrency.symbol})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving || suppliers.isEmpty
                  ? null
                  : () => _createDraft(selectedCurrency),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_saving ? 'Creando...' : 'Crear borrador'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDraft(Currency currency) async {
    if (_supplierId == null) {
      _showMessage('Selecciona un proveedor.');
      return;
    }

    setState(() => _saving = true);

    try {
      final id = await ref
          .read(purchaseRepositoryProvider)
          .createDraft(
            supplierId: _supplierId!,
            purchaseDate: DateTime.now(),
            currencyCode: currency.code,
            documentNumber: _documentController.text.trim().isEmpty
                ? null
                : _documentController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;
      setState(() => _purchaseId = id);
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo crear el borrador: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildDraft() {
    final id = _purchaseId!;

    return ref
        .watch(purchaseByIdProvider(id))
        .when(
          loading: _loading,
          error: (error, _) => _loadError('compra', error),
          data: (purchase) {
            if (purchase == null) {
              return _loadError('compra', 'El borrador ya no existe.');
            }

            return ref
                .watch(purchaseDetailsProvider(id))
                .when(
                  loading: _loading,
                  error: (error, _) => _loadError('detalles', error),
                  data: (details) => _buildDraftContent(purchase, details),
                );
          },
        );
  }

  Widget _buildDraftContent(Purchase purchase, List<PurchaseDetail> details) {
    final currencies =
        ref.read(purchaseCurrenciesProvider).value ?? const <Currency>[];

    final currency = currencies.where(
      (item) => item.code == purchase.currencyCode,
    );

    final digits = currency.isEmpty ? 2 : currency.first.decimalDigits;

    final suppliers =
        ref.read(purchaseSuppliersProvider).value ?? const <Supplier>[];

    final supplier = suppliers.where((item) => item.id == purchase.supplierId);

    final isDraft = purchase.status == 'draft';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
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
                      'Borrador de compra',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proveedor: ${supplier.isEmpty ? purchase.supplierId : supplier.first.name}',
                    ),
                    Text('Moneda: ${purchase.currencyCode}'),
                    if (purchase.documentNumber != null &&
                        purchase.documentNumber!.isNotEmpty)
                      Text('Documento: ${purchase.documentNumber}'),
                    if (purchase.notes != null && purchase.notes!.isNotEmpty)
                      Text('Notas: ${purchase.notes}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: isDraft ? _addDetail : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (details.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Todavía no hay productos. Agrega al menos uno para '
                    'poder confirmar la compra.',
                  ),
                ),
              )
            else
              for (final detail in details)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.productNameSnapshot,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('SKU: ${detail.skuSnapshot}'),
                        const SizedBox(height: 6),
                        Text(
                          'Cantidad: ${_formatQuantity(detail.quantityMilliUnits)} ${detail.unitSnapshot}',
                        ),
                        Text(
                          'Costo unitario: ${_formatMajor(detail.unitCostMinorUnits, digits)} ${purchase.currencyCode}',
                        ),
                        Text(
                          'Total: ${_formatMajor(detail.totalMinorUnits, digits)} ${purchase.currencyCode}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (isDraft) ...[
                          const Divider(),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => _editDetail(detail, digits),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed: () => _removeDetail(detail),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de compra',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _totalRow(
                      'Subtotal',
                      purchase.subtotalMinorUnits,
                      digits,
                      purchase.currencyCode,
                    ),
                    _totalRow(
                      'Descuentos',
                      purchase.discountMinorUnits,
                      digits,
                      purchase.currencyCode,
                    ),
                    _totalRow(
                      'Impuestos',
                      purchase.taxMinorUnits,
                      digits,
                      purchase.currencyCode,
                    ),
                    const Divider(),
                    _totalRow(
                      'Total',
                      purchase.totalMinorUnits,
                      digits,
                      purchase.currencyCode,
                      emphasized: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isDraft && details.isNotEmpty
                  ? _confirmPurchase
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar compra'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(
    String label,
    int amount,
    int digits,
    String currency, {
    bool emphasized = false,
  }) {
    final style = emphasized
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('${_formatMajor(amount, digits)} $currency', style: style),
        ],
      ),
    );
  }

  Future<void> _addDetail() async {
    final purchase = await ref
        .read(purchaseRepositoryProvider)
        .findById(_purchaseId!);

    if (purchase == null || !mounted) return;

    final products =
        ref.read(purchaseProductsProvider).value ?? const <Product>[];

    final currencies =
        ref.read(purchaseCurrenciesProvider).value ?? const <Currency>[];

    final matching = currencies.where(
      (item) => item.code == purchase.currencyCode,
    );

    if (matching.isEmpty) {
      _showMessage('La moneda de la compra ya no está disponible.');
      return;
    }

    await _showLineDialog(
      products: products,
      currencyCode: purchase.currencyCode,
      digits: matching.first.decimalDigits,
    );
  }

  Future<void> _editDetail(PurchaseDetail detail, int digits) async {
    final products =
        ref.read(purchaseProductsProvider).value ?? const <Product>[];

    final result = await _showLineDialog(
      products: products,
      currencyCode: _purchaseId == null
          ? ''
          : (await ref.read(purchaseRepositoryProvider).findById(_purchaseId!))
                    ?.currencyCode ??
                '',
      digits: digits,
      initialDetail: detail,
    );

    if (result == null || !mounted) return;

    try {
      await ref
          .read(purchaseRepositoryProvider)
          .updateDetail(
            purchaseId: _purchaseId!,
            detailId: detail.id,
            productId: result.productId,
            quantityMilliUnits: result.quantityMilliUnits,
            unitCostMinorUnits: result.unitCostMinorUnits,
            discount: result.discount,
            tax: result.tax,
          );
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo actualizar el producto: $error');
      }
    }
  }

  Future<_PurchaseLineInput?> _showLineDialog({
    required List<Product> products,
    required String currencyCode,
    required int digits,
    PurchaseDetail? initialDetail,
  }) {
    return showDialog<_PurchaseLineInput>(
      context: context,
      builder: (_) => _PurchaseLineDialog(
        products: products,
        currencyCode: currencyCode,
        digits: digits,
        initialDetail: initialDetail,
      ),
    ).then((result) async {
      if (result == null || initialDetail != null || !mounted) {
        return result;
      }

      try {
        await ref
            .read(purchaseRepositoryProvider)
            .addDetail(
              purchaseId: _purchaseId!,
              productId: result.productId,
              quantityMilliUnits: result.quantityMilliUnits,
              unitCostMinorUnits: result.unitCostMinorUnits,
              discount: result.discount,
              tax: result.tax,
            );
      } catch (error) {
        if (mounted) {
          _showMessage('No se pudo agregar el producto: $error');
        }
        return null;
      }

      return result;
    });
  }

  Future<void> _removeDetail(PurchaseDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Deseas eliminar "${detail.productNameSnapshot}" de la compra?',
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

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(purchaseRepositoryProvider)
          .removeDetail(purchaseId: _purchaseId!, detailId: detail.id);
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo eliminar el producto: $error');
      }
    }
  }

  Future<void> _confirmPurchase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: const Text(
          'Al confirmar, la compra dejará de ser editable. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);

    try {
      await ref.read(purchaseRepositoryProvider).confirmPurchase(_purchaseId!);

      if (!mounted) return;

      _showMessage('Compra confirmada correctamente.');
      context.pop();
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo confirmar la compra: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PurchaseLineInput {
  const _PurchaseLineInput({
    required this.productId,
    required this.quantityMilliUnits,
    required this.unitCostMinorUnits,
    required this.discount,
    required this.tax,
  });

  final String productId;
  final int quantityMilliUnits;
  final int unitCostMinorUnits;
  final PurchaseAdjustmentInput discount;
  final PurchaseAdjustmentInput tax;
}

class _PurchaseLineDialog extends StatefulWidget {
  const _PurchaseLineDialog({
    required this.products,
    required this.currencyCode,
    required this.digits,
    this.initialDetail,
  });

  final List<Product> products;
  final String currencyCode;
  final int digits;
  final PurchaseDetail? initialDetail;

  @override
  State<_PurchaseLineDialog> createState() => _PurchaseLineDialogState();
}

class _PurchaseLineDialogState extends State<_PurchaseLineDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;

  String? _productId;
  String _discountType = 'fixed';
  String _taxType = 'fixed';

  @override
  void initState() {
    super.initState();

    final detail = widget.initialDetail;

    _productId =
        detail?.productId ??
        (widget.products.isEmpty ? null : widget.products.first.id);

    _quantityController = TextEditingController(
      text: detail == null ? '1' : _formatQuantity(detail.quantityMilliUnits),
    );

    _costController = TextEditingController(
      text: _formatMajor(detail?.unitCostMinorUnits ?? 0, widget.digits),
    );

    _discountType = detail?.discountType ?? 'fixed';
    _taxType = detail?.taxType ?? 'fixed';

    _discountController = TextEditingController(
      text: detail == null
          ? '0'
          : _formatAdjustment(
              detail.discountType,
              detail.discountMinorUnits,
              detail.discountRate,
              widget.digits,
            ),
    );

    _taxController = TextEditingController(
      text: detail == null
          ? '0'
          : _formatAdjustment(
              detail.taxType,
              detail.taxMinorUnits,
              detail.taxRate,
              widget.digits,
            ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialDetail == null ? 'Agregar producto' : 'Editar producto',
      ),
      content: SizedBox(
        width: 440,
        child: widget.products.isEmpty
            ? const Text('No hay productos activos disponibles.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _productId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Producto'),
                      items: [
                        for (final product in widget.products)
                          DropdownMenuItem(
                            value: product.id,
                            child: Text('${product.sku} · ${product.name}'),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() => _productId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad (máximo 3 decimales)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Costo unitario (${widget.currencyCode})',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _adjustmentFields(
                      title: 'Descuento',
                      type: _discountType,
                      controller: _discountController,
                      onTypeChanged: (value) {
                        setState(() => _discountType = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _adjustmentFields(
                      title: 'Impuesto',
                      type: _taxType,
                      controller: _taxController,
                      onTypeChanged: (value) {
                        setState(() => _taxType = value);
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.products.isEmpty ? null : _submit,
          child: Text(widget.initialDetail == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _adjustmentFields({
    required String title,
    required String type,
    required TextEditingController controller,
    required ValueChanged<String> onTypeChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: type,
            decoration: InputDecoration(labelText: 'Tipo de $title'),
            items: const [
              DropdownMenuItem(value: 'fixed', child: Text('Importe')),
              DropdownMenuItem(value: 'percentage', child: Text('Porcentaje')),
            ],
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: type == 'fixed'
                  ? '$title (${widget.currencyCode})'
                  : '$title (%)',
            ),
          ),
        ),
      ],
    );
  }

  PurchaseAdjustmentInput _adjustment(String type, String value) {
    if (type == 'percentage') {
      return PurchaseAdjustmentInput.percentage(_parseDecimalStrict(value, 4));
    }

    return PurchaseAdjustmentInput.fixed(
      _parseScaledStrict(value, widget.digits),
    );
  }

  void _submit() {
    try {
      final quantity = _parseScaledStrict(_quantityController.text, 3);

      final cost = _parseScaledStrict(_costController.text, widget.digits);

      if (_productId == null || quantity <= 0 || cost < 0) {
        throw const FormatException(
          'Revisa el producto, la cantidad y el costo.',
        );
      }

      final result = _PurchaseLineInput(
        productId: _productId!,
        quantityMilliUnits: quantity,
        unitCostMinorUnits: cost,
        discount: _adjustment(_discountType, _discountController.text),
        tax: _adjustment(_taxType, _taxController.text),
      );

      Navigator.pop(context, result);
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Datos no válidos: $error')));
    }
  }
}

String _formatAdjustment(
  String type,
  int fixedMinor,
  String? percentage,
  int digits,
) {
  if (type == 'percentage') {
    return percentage ?? '0';
  }

  return _formatMajor(fixedMinor, digits);
}

int _parseScaledStrict(String value, int digits) {
  final normalized = value.trim();

  if (!RegExp('^\\d+(?:[.,]\\d{1,$digits})?\$').hasMatch(normalized)) {
    throw FormatException(
      'Introduce un número válido con un máximo de $digits decimales.',
    );
  }

  final parsed = Decimal.parse(normalized.replaceAll(',', '.'));
  var factor = 1;

  for (var i = 0; i < digits; i++) {
    factor *= 10;
  }

  return (parsed * Decimal.fromInt(factor)).toBigInt().toInt();
}

Decimal _parseDecimalStrict(String value, int digits) {
  final normalized = value.trim();

  if (!RegExp('^\\d+(?:[.,]\\d{1,$digits})?\$').hasMatch(normalized)) {
    throw FormatException(
      'Introduce un porcentaje válido con un máximo de $digits decimales.',
    );
  }

  return Decimal.parse(normalized.replaceAll(',', '.'));
}

int _pow10(int digits) {
  var value = 1;

  for (var i = 0; i < digits; i++) {
    value *= 10;
  }

  return value;
}

String _formatMajor(int minor, int digits) {
  final factor = _pow10(digits);
  final whole = minor ~/ factor;
  final fraction = (minor % factor).toString().padLeft(digits, '0');

  return digits == 0 ? '$whole' : '$whole.$fraction';
}

String _formatQuantity(int milli) {
  final whole = milli ~/ 1000;
  final fraction = (milli % 1000).toString().padLeft(3, '0');

  return fraction == '000'
      ? '$whole'
      : '$whole.${fraction.replaceFirst(RegExp(r'0+$'), '')}';
}
