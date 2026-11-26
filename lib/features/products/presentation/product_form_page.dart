import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/product_providers.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({this.product, super.key});

  final Product? product;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sku;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _unit;
  late final TextEditingController _description;
  bool _trackInventory = true;
  bool _saving = false;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _sku = TextEditingController(text: product?.sku ?? '');
    _name = TextEditingController(text: product?.name ?? '');
    _category = TextEditingController(text: product?.category ?? '');
    _unit = TextEditingController(text: product?.unit ?? 'unidad');
    _description = TextEditingController(text: product?.description ?? '');
    _trackInventory = product?.trackInventory ?? true;
  }

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _category.dispose();
    _unit.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      if (_editing) {
        await repository.updateProduct(
          id: widget.product!.id,
          sku: _sku.text,
          name: _name.text,
          description: _optional(_description),
          category: _optional(_category),
          unit: _unit.text,
          trackInventory: _trackInventory,
        );
      } else {
        await repository.createProduct(
          sku: _sku.text,
          name: _name.text,
          description: _optional(_description),
          category: _optional(_category),
          unit: _unit.text,
          trackInventory: _trackInventory,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editing ? 'Producto actualizado.' : 'Producto registrado.',
          ),
        ),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      final message = error is ArgumentError || error is StateError
          ? error.toString().replaceFirst(
              RegExp(r'^(Invalid argument\(s\): |Bad state: )'),
              '',
            )
          : 'No se pudo guardar el producto.';
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
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  _editing ? 'Editar producto' : 'Nuevo producto',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Define la información básica del artículo y su control de existencias.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _sku,
                  decoration: const InputDecoration(
                    labelText: 'Código SKU *',
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 40,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El código SKU es obligatorio.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 120,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El nombre es obligatorio.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de medida *',
                    prefixIcon: Icon(Icons.straighten_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'La unidad de medida es obligatoria.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Controlar existencias'),
                  subtitle: const Text(
                    'Desactívalo para servicios o artículos sin control de stock.',
                  ),
                  value: _trackInventory,
                  onChanged: (value) => setState(() => _trackInventory = value),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _saving ? null : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _editing ? 'Guardar cambios' : 'Guardar producto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
