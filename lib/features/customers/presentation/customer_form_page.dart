import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/customer_providers.dart';
import '../data/customer_repository.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  const CustomerFormPage({this.customer, super.key});

  final Customer? customer;

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _commercialNameController;
  late final TextEditingController _documentNumberController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _addressController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _countryController;
  late final TextEditingController _notesController;

  String _customerType = CustomerRepository.individual;
  String? _documentType;
  bool _isSaving = false;

  bool get _isEditing => widget.customer != null;

  static const _documentTypes = <String, String>{
    'dni': 'Documento de identidad',
    'passport': 'Pasaporte',
    'tax_id': 'Identificación fiscal',
    'other': 'Otro',
  };

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;

    _customerType = customer?.customerType ?? CustomerRepository.individual;
    _documentType = customer?.documentType;

    _nameController = TextEditingController(text: customer?.name ?? '');
    _commercialNameController = TextEditingController(
      text: customer?.commercialName ?? '',
    );
    _documentNumberController = TextEditingController(
      text: customer?.documentNumber ?? '',
    );
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _contactPersonController = TextEditingController(
      text: customer?.contactPerson ?? '',
    );
    _addressController = TextEditingController(text: customer?.address ?? '');
    _municipalityController = TextEditingController(
      text: customer?.municipality ?? '',
    );
    _provinceController = TextEditingController(text: customer?.province ?? '');
    _countryController = TextEditingController(text: customer?.country ?? '');
    _notesController = TextEditingController(text: customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commercialNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _addressController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _validateDocumentType(String? value) {
    final number = _documentNumberController.text.trim();

    if ((value == null || value.isEmpty) && number.isNotEmpty) {
      return 'Selecciona el tipo de documento.';
    }

    return null;
  }

  String? _validateDocumentNumber(String? value) {
    final type = _documentType;
    final number = value?.trim() ?? '';

    if ((type == null || type.isEmpty) && number.isNotEmpty) {
      return 'Selecciona primero el tipo de documento.';
    }

    if (type != null && number.isEmpty) {
      return 'Introduce el número de documento.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return null;

    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    return valid ? null : 'Introduce un correo electrónico válido.';
  }

  Future<void> _saveCustomer() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final repository = ref.read(customerRepositoryProvider);

    try {
      if (_isEditing) {
        await repository.updateCustomer(
          id: widget.customer!.id,
          customerType: _customerType,
          name: _nameController.text,
          commercialName: _optionalValue(_commercialNameController),
          documentType: _documentType,
          documentNumber: _optionalValue(_documentNumberController),
          phone: _optionalValue(_phoneController),
          email: _optionalValue(_emailController),
          address: _optionalValue(_addressController),
          municipality: _optionalValue(_municipalityController),
          province: _optionalValue(_provinceController),
          country: _optionalValue(_countryController),
          contactPerson: _optionalValue(_contactPersonController),
          notes: _optionalValue(_notesController),
        );
      } else {
        await repository.createCustomer(
          customerType: _customerType,
          name: _nameController.text,
          commercialName: _optionalValue(_commercialNameController),
          documentType: _documentType,
          documentNumber: _optionalValue(_documentNumberController),
          phone: _optionalValue(_phoneController),
          email: _optionalValue(_emailController),
          address: _optionalValue(_addressController),
          municipality: _optionalValue(_municipalityController),
          province: _optionalValue(_provinceController),
          country: _optionalValue(_countryController),
          contactPerson: _optionalValue(_contactPersonController),
          notes: _optionalValue(_notesController),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Cliente actualizado correctamente.'
                : 'Cliente registrado correctamente.',
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
          : 'No se pudo guardar el cliente. Inténtalo nuevamente.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGeneralSection(),
                        const SizedBox(height: 16),
                        _buildIdentificationSection(),
                        const SizedBox(height: 16),
                        _buildContactSection(),
                        const SizedBox(height: 16),
                        _buildLocationSection(),
                        const SizedBox(height: 16),
                        _buildNotesSection(),
                        const SizedBox(height: 24),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Volver',
            onPressed: _isSaving ? null : () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Editar cliente' : 'Nuevo cliente',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _isEditing
                      ? 'Modifica la información del cliente.'
                      : 'Completa los datos para registrar un cliente.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'Información general',
      icon: Icons.person_outline,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _customerType,
          decoration: const InputDecoration(
            labelText: 'Tipo de cliente *',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: const [
            DropdownMenuItem(
              value: CustomerRepository.individual,
              child: Text('Persona'),
            ),
            DropdownMenuItem(
              value: CustomerRepository.business,
              child: Text('Empresa'),
            ),
          ],
          onChanged: _isSaving
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _customerType = value);
                  }
                },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          enabled: !_isSaving,
          maxLength: 150,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre o razón social *',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio.';
            }
            if (value.trim().length > 150) {
              return 'No puede superar los 150 caracteres.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commercialNameController,
          enabled: !_isSaving,
          maxLength: 150,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre comercial',
            prefixIcon: Icon(Icons.store_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentificationSection() {
    return _buildSection(
      title: 'Identificación',
      icon: Icons.assignment_ind_outlined,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _documentType,
          decoration: const InputDecoration(
            labelText: 'Tipo de documento',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          items: [
            for (final entry in _documentTypes.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          validator: _validateDocumentType,
          onChanged: _isSaving
              ? null
              : (value) {
                  setState(() => _documentType = value);
                  _formKey.currentState?.validate();
                },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _documentNumberController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Número de documento',
            prefixIcon: Icon(Icons.numbers_outlined),
          ),
          validator: _validateDocumentNumber,
        ),
        const SizedBox(height: 8),
        Text(
          'El tipo y el número deben proporcionarse juntos. '
          'Puedes dejar ambos vacíos.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contacto',
      icon: Icons.contact_phone_outlined,
      children: [
        TextFormField(
          controller: _phoneController,
          enabled: !_isSaving,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          enabled: !_isSaving,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contactPersonController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Persona de contacto',
            prefixIcon: Icon(Icons.person_pin_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Ubicación',
      icon: Icons.location_on_outlined,
      children: [
        TextFormField(
          controller: _addressController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.home_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _municipalityController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Municipio',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _provinceController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Provincia o estado',
            prefixIcon: Icon(Icons.map_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _countryController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'País',
            prefixIcon: Icon(Icons.public_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'Información adicional',
      icon: Icons.notes_outlined,
      children: [
        TextFormField(
          controller: _notesController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Observaciones',
            hintText: 'Información adicional sobre el cliente...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => context.pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveCustomer,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Guardando...' : 'Guardar cliente'),
        ),
      ],
    );
  }
}
