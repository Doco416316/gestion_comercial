import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import 'providers/customer_providers.dart';

class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _typeFilter = 'all';
  bool _includeInactive = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createCustomer() async {
    if (!mounted) return;
    await context.push('/customers/new');
  }

  Future<void> _editCustomer(Customer customer) async {
    if (!mounted) return;
    await context.push('/customers/edit', extra: customer);
  }

  Future<void> _toggleCustomerStatus(Customer customer) async {
    final newStatus = !customer.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(newStatus ? 'Activar cliente' : 'Desactivar cliente'),
          content: Text(
            newStatus
                ? '¿Deseas activar a ${customer.name}?'
                : '¿Deseas desactivar a ${customer.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(newStatus ? 'Activar' : 'Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(customerRepositoryProvider)
          .setActive(customer.id, newStatus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Cliente activado correctamente.'
                : 'Cliente desactivado correctamente.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el cliente: $error')),
      );
    }
  }

  Widget _buildCustomerActions(Customer customer) {
    return PopupMenuButton<String>(
      tooltip: 'Acciones del cliente',
      onSelected: (action) {
        switch (action) {
          case 'edit':
            _editCustomer(customer);
            break;
          case 'toggle':
            _toggleCustomerStatus(customer);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Editar'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: ListTile(
            leading: Icon(
              customer.isActive
                  ? Icons.person_off_outlined
                  : Icons.person_outline,
            ),
            title: Text(customer.isActive ? 'Desactivar' : 'Activar'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    final query = _searchQuery.trim().toLowerCase();

    return customers.where((customer) {
      final matchesType =
          _typeFilter == 'all' || customer.customerType == _typeFilter;

      final searchableText = [
        customer.name,
        customer.commercialName ?? '',
        customer.documentType ?? '',
        customer.documentNumber ?? '',
        customer.phone ?? '',
        customer.email ?? '',
      ].join(' ').toLowerCase();

      final matchesSearch = query.isEmpty || searchableText.contains(query);

      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider(_includeInactive));

    return customersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildError(error),
      data: (customers) {
        final filteredCustomers = _filterCustomers(customers);

        return _buildContent(context, customers, filteredCustomers);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Customer> customers,
    List<Customer> filteredCustomers,
  ) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, customers.length),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: filteredCustomers.isEmpty
                ? _buildEmptyState(context)
                : isWide
                ? _buildTable(filteredCustomers)
                : _buildCards(filteredCustomers),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalCustomers) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Directorio de clientes',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCustomers ${totalCustomers == 1 ? 'cliente registrado' : 'clientes registrados'}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: _createCustomer,
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, documento, teléfono o correo...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: _typeFilter == 'all',
          onSelected: (_) {
            setState(() => _typeFilter = 'all');
          },
        ),
        ChoiceChip(
          label: const Text('Personas'),
          selected: _typeFilter == 'individual',
          onSelected: (_) {
            setState(() => _typeFilter = 'individual');
          },
        ),
        ChoiceChip(
          label: const Text('Empresas'),
          selected: _typeFilter == 'business',
          onSelected: (_) {
            setState(() => _typeFilter = 'business');
          },
        ),
        FilterChip(
          label: const Text('Incluir inactivos'),
          selected: _includeInactive,
          onSelected: (selected) {
            setState(() => _includeInactive = selected);
          },
        ),
      ],
    );
  }

  Widget _buildTable(List<Customer> customers) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 28,
            headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Documento')),
              DataColumn(label: Text('Contacto')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: customers.map((customer) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        customer.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(_typeChip(customer.customerType)),
                  DataCell(Text(customer.documentNumber ?? 'No especificado')),
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: Text(
                        customer.phone ?? customer.email ?? 'Sin contacto',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(_statusChip(customer.isActive)),
                  DataCell(_buildCustomerActions(customer)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(List<Customer> customers) {
    return ListView.separated(
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = customers[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _statusChip(customer.isActive),
                    _buildCustomerActions(customer),
                  ],
                ),
                if (customer.commercialName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    customer.commercialName!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _typeChip(customer.customerType),
                    if (customer.documentNumber != null)
                      Chip(
                        avatar: const Icon(Icons.badge_outlined, size: 16),
                        label: Text(customer.documentNumber!),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (customer.phone != null || customer.email != null) ...[
                  const SizedBox(height: 8),
                  if (customer.phone != null)
                    _contactLine(Icons.phone_outlined, customer.phone!),
                  if (customer.email != null)
                    _contactLine(Icons.email_outlined, customer.email!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contactLine(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String customerType) {
    final isBusiness = customerType == 'business';

    return Chip(
      avatar: Icon(
        isBusiness ? Icons.business_outlined : Icons.person_outline,
        size: 16,
      ),
      label: Text(isBusiness ? 'Empresa' : 'Persona'),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _statusChip(bool isActive) {
    return Chip(
      avatar: Icon(
        isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
        size: 16,
        color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
      ),
      label: Text(isActive ? 'Activo' : 'Inactivo'),
      visualDensity: VisualDensity.compact,
      backgroundColor: isActive ? Colors.green.shade50 : Colors.grey.shade200,
      side: BorderSide.none,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasFilters =
        _searchQuery.isNotEmpty || _typeFilter != 'all' || _includeInactive;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.people_outline,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No se encontraron clientes'
                  : 'Todavía no hay clientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Prueba cambiando la búsqueda o los filtros.'
                  : 'Los clientes registrados aparecerán en esta sección.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los clientes.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(customersStreamProvider(_includeInactive));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
