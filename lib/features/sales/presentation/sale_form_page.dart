import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../domain/sale_payment_service.dart';
import '../../purchases/domain/purchase_calculation_service.dart';
import 'providers/sales_providers.dart';

class SaleFormPage extends ConsumerStatefulWidget {
  const SaleFormPage({super.key});

  @override
  ConsumerState<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends ConsumerState<SaleFormPage> {
  final _documentController = TextEditingController();
  final _notesController = TextEditingController();
  String? _customerId;
  String? _currencyCode;
  String _paymentType = 'cash';
  bool _saving = false;

  @override
  void dispose() {
    _documentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencies = ref.watch(salesCurrenciesProvider);
    final customers = ref.watch(salesCustomersProvider);
    final products = ref.watch(salesProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: currencies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _loadError('monedas', error),
        data: (currencyRows) => customers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _loadError('clientes', error),
          data: (customerRows) => products.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _loadError('productos', error),
            data: (productRows) {
              if (currencyRows.isEmpty) {
                return _loadError(
                  'monedas activas',
                  'Registra y activa al menos una moneda en Configuración.',
                );
              }
              _currencyCode ??= currencyRows
                  .firstWhere(
                    (currency) => currency.isBase,
                    orElse: () => currencyRows.first,
                  )
                  .code;
              return _buildForm(currencyRows, customerRows, productRows);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    List<Currency> currencies,
    List<Customer> customers,
    List<Product> products,
  ) {
    final selectedCurrency = currencies.firstWhere(
      (currency) => currency.code == _currencyCode,
      orElse: () => currencies.first,
    );

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
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentController,
              decoration: const InputDecoration(
                labelText: 'Número de documento (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _customerId,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Venta sin cliente'),
                ),
                for (final customer in customers)
                  DropdownMenuItem<String?>(
                    value: customer.id,
                    child: Text(customer.name),
                  ),
              ],
              onChanged: (value) => setState(() => _customerId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currencyCode,
              decoration: const InputDecoration(
                labelText: 'Moneda de la venta',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final currency in currencies)
                  DropdownMenuItem(
                    value: currency.code,
                    child: Text('${currency.code} · ${currency.name}'),
                  ),
              ],
              onChanged: (value) => setState(() => _currencyCode = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentType,
              decoration: const InputDecoration(
                labelText: 'Condición de pago',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Contado')),
                DropdownMenuItem(value: 'credit', child: Text('Crédito')),
              ],
              onChanged: (value) => setState(() {
                _paymentType = value ?? 'cash';
              }),
            ),
            if (_paymentType == 'credit') ...[
              const SizedBox(height: 8),
              const Text(
                'Las ventas a crédito requieren seleccionar un cliente registrado.',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ],
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
            Text(
              'Productos disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${products.length} productos activos. Los precios se pueden ajustar al registrar cada línea.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.playlist_add_outlined, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Los productos y sus cantidades se agregarán en el siguiente paso.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Moneda seleccionada: ${selectedCurrency.code} (${selectedCurrency.symbol})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : () => _createDraft(selectedCurrency),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(
                _saving ? 'Creando...' : 'Continuar y agregar productos',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadError(String title, Object error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('No se pudieron cargar $title: $error'),
    ),
  );

  Future<void> _createDraft(Currency currency) async {
    if (_paymentType == 'credit' && _customerId == null) {
      _showMessage('Selecciona un cliente para una venta a crédito.');
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(salesRepositoryProvider)
          .createDraft(
            customerId: _customerId,
            saleDate: DateTime.now(),
            currencyCode: currency.code,
            paymentType: _paymentType == 'cash'
                ? SalePaymentType.cash
                : SalePaymentType.credit,
            documentNumber: _documentController.text,
            notes: _notesController.text,
          );
      if (!mounted) return;
      context.go('/sales/detail', extra: id);
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo crear el borrador: $error');
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

/// Diálogo compartido para agregar una línea a una venta en borrador.
Future<void> showAddSaleLineDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Sale sale,
}) async {
  final db = ref.read(appDatabaseProvider);
  final products =
      await (db.select(db.products)
            ..where((row) => row.isActive.equals(true))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .get();
  if (!context.mounted) return;

  final prices = <String, int>{};
  final priceRows = await (db.select(
    db.productPrices,
  )..where((row) => row.currencyCode.equals(sale.currencyCode))).get();
  for (final price in priceRows) {
    prices[price.productId] = price.amountMinorUnits;
  }
  final stockRows = await db.select(db.inventoryBalances).get();
  final stock = {
    for (final row in stockRows) row.productId: row.quantityMilliUnits,
  };
  if (!context.mounted) return;

  final currency = await (db.select(
    db.currencies,
  )..where((row) => row.code.equals(sale.currencyCode))).getSingle();
  if (!context.mounted) return;

  final result = await showDialog<_SaleLineInput>(
    context: context,
    builder: (_) => _AddSaleLineDialog(
      products: products,
      prices: prices,
      stock: stock,
      currencyCode: sale.currencyCode,
      currencyDigits: currency.decimalDigits,
    ),
  );
  if (result == null || !context.mounted) return;

  try {
    await ref
        .read(salesRepositoryProvider)
        .addDetail(
          saleId: sale.id,
          productId: result.productId,
          quantityMilliUnits: result.quantityMilliUnits,
          unitPriceMinorUnits: result.unitPriceMinorUnits,
          discount: result.discount,
          tax: result.tax,
        );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo agregar el producto: $error')),
      );
    }
  }
}

class _SaleLineInput {
  const _SaleLineInput({
    required this.productId,
    required this.quantityMilliUnits,
    required this.unitPriceMinorUnits,
    required this.discount,
    required this.tax,
  });

  final String productId;
  final int quantityMilliUnits;
  final int unitPriceMinorUnits;
  final PurchaseAdjustmentInput discount;
  final PurchaseAdjustmentInput tax;
}

class _AddSaleLineDialog extends StatefulWidget {
  const _AddSaleLineDialog({
    required this.products,
    required this.prices,
    required this.stock,
    required this.currencyCode,
    required this.currencyDigits,
  });

  final List<Product> products;
  final Map<String, int> prices;
  final Map<String, int> stock;
  final String currencyCode;
  final int currencyDigits;

  @override
  State<_AddSaleLineDialog> createState() => _AddSaleLineDialogState();
}

class _AddSaleLineDialogState extends State<_AddSaleLineDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  late final TextEditingController _priceController;
  String? _productId;
  String _discountType = 'fixed';
  String _taxType = 'fixed';

  @override
  void initState() {
    super.initState();
    _productId = widget.products.isEmpty ? null : widget.products.first.id;
    _priceController = TextEditingController(
      text: _formatMajor(
        _productId == null ? 0 : widget.prices[_productId] ?? 0,
        widget.currencyDigits,
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = widget.products.where(
      (product) => product.id == _productId,
    );
    final product = selectedProduct.isEmpty ? null : selectedProduct.first;
    final available = product == null ? null : widget.stock[product.id] ?? 0;

    return AlertDialog(
      title: const Text('Agregar producto'),
      content: SizedBox(
        width: 420,
        child: widget.products.isEmpty
            ? const Text('No hay productos activos disponibles.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _productId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Producto'),
                    items: [
                      for (final item in widget.products)
                        DropdownMenuItem(
                          value: item.id,
                          child: Text('${item.sku} · ${item.name}'),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _productId = value;
                        _priceController.text = _formatMajor(
                          value == null ? 0 : widget.prices[value] ?? 0,
                          widget.currencyDigits,
                        );
                      });
                    },
                  ),
                  if (product != null && product.trackInventory) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Existencias actuales: ${_formatQuantity(available ?? 0)} ${product.unit}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cantidad (${product?.unit ?? 'unidad'})',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Precio unitario (${widget.currencyCode})',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _discountType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de descuento',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Importe'),
                            ),
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text('%'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _discountType = value ?? 'fixed'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: _discountType == 'fixed'
                                ? 'Descuento (${widget.currencyCode})'
                                : 'Descuento (%)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _taxType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de impuesto',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Importe'),
                            ),
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text('%'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _taxType = value ?? 'fixed'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _taxController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: _taxType == 'fixed'
                                ? 'Impuesto (${widget.currencyCode})'
                                : 'Impuesto (%)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.products.isEmpty ? null : _submit,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  PurchaseAdjustmentInput _adjustment(String type, String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final amount = Decimal.parse(normalized);
    if (amount < Decimal.zero) {
      throw const FormatException(
        'Los descuentos e impuestos no pueden ser negativos.',
      );
    }
    if (type == 'percentage') {
      return PurchaseAdjustmentInput.percentage(amount);
    }
    final minor = (amount * Decimal.fromInt(_pow10(widget.currencyDigits)))
        .round()
        .toBigInt()
        .toInt();
    return PurchaseAdjustmentInput.fixed(minor);
  }

  void _submit() {
    try {
      final quantity = _parseScaled(_quantityController.text, 3);
      final price = _parseScaled(_priceController.text, widget.currencyDigits);
      if (_productId == null || quantity <= 0 || price < 0) {
        throw const FormatException('Revisa la cantidad y el precio.');
      }
      Navigator.pop(
        context,
        _SaleLineInput(
          productId: _productId!,
          quantityMilliUnits: quantity,
          unitPriceMinorUnits: price,
          discount: _adjustment(_discountType, _discountController.text),
          tax: _adjustment(_taxType, _taxController.text),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Datos no válidos: $error')));
    }
  }
}

int _pow10(int digits) {
  var value = 1;
  for (var i = 0; i < digits; i++) {
    value *= 10;
  }
  return value;
}

int _parseScaled(String value, int digits) {
  final normalized = value.trim().replaceAll(',', '.');
  final parsed = Decimal.parse(normalized);
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

String _formatQuantity(int milli) {
  final whole = milli ~/ 1000;
  final fraction = (milli % 1000).toString().padLeft(3, '0');
  return fraction == '000'
      ? '$whole'
      : '$whole.${fraction.replaceFirst(RegExp(r'0+$'), '')}';
}
