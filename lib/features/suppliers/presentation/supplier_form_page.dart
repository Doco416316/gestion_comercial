import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/supplier_providers.dart';

class SupplierFormPage extends ConsumerStatefulWidget {
  const SupplierFormPage({this.supplier, super.key});

  final Supplier? supplier;

  @override
  ConsumerState<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends ConsumerState<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _taxId;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _notes;
  bool _saving = false;

  bool get _editing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _name = TextEditingController(text: supplier?.name ?? '');
    _taxId = TextEditingController(text: supplier?.taxId ?? '');
    _phone = TextEditingController(text: supplier?.phone ?? '');
    _email = TextEditingController(text: supplier?.email ?? '');
    _address = TextEditingController(text: supplier?.address ?? '');
    _notes = TextEditingController(text: supplier?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _taxId.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Introduce un correo electrónico válido.';
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final repository = ref.read(supplierRepositoryProvider);
      if (_editing) {
        await repository.updateSupplier(
          id: widget.supplier!.id,
          name: _name.text,
          taxId: _optional(_taxId),
          phone: _optional(_phone),
          email: _optional(_email),
          address: _optional(_address),
          notes: _optional(_notes),
        );
      } else {
        await repository.createSupplier(
          name: _name.text,
          taxId: _optional(_taxId),
          phone: _optional(_phone),
          email: _optional(_email),
          address: _optional(_address),
          notes: _optional(_notes),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editing ? 'Proveedor actualizado.' : 'Proveedor registrado.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      final message = error is ArgumentError || error is StateError
          ? error.toString().replaceFirst(RegExp(r'^(Invalid argument\(s\): |Bad state: )'), '')
          : 'No se pudo guardar el proveedor.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
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
                Text(_editing ? 'Editar proveedor' : 'Nuevo proveedor',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Datos de contacto y fiscales del proveedor.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre *', prefixIcon: Icon(Icons.business_outlined)),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 150,
                  validator: (value) => value == null || value.trim().isEmpty ? 'El nombre es obligatorio.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _taxId, decoration: const InputDecoration(labelText: 'Identificación fiscal', prefixIcon: Icon(Icons.badge_outlined))),
                const SizedBox(height: 12),
                TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                const SizedBox(height: 12),
                TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Dirección', prefixIcon: Icon(Icons.location_on_outlined)), maxLines: 2),
                const SizedBox(height: 12),
                TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notas', prefixIcon: Icon(Icons.notes_outlined)), maxLines: 3),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: _saving ? null : () => context.pop(), child: const Text('Cancelar')),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                      label: Text(_editing ? 'Guardar cambios' : 'Guardar proveedor'),
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
