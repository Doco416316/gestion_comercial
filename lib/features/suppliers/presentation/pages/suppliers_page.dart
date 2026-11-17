import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Supplier>>? _searchFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    setState(() {
      _searchFuture = query.isEmpty
          ? null
          : ref.read(supplierRepositoryProvider).search(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchFuture = null);
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(supplierRepositoryProvider);
    final searchFuture = _searchFuture;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Buscar proveedores',
                hintText: 'Nombre o identificación fiscal',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchFuture == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                        tooltip: 'Limpiar búsqueda',
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: searchFuture == null
                ? StreamBuilder<List<Supplier>>(
                    stream: repository.watchAll(),
                    builder: (context, snapshot) => _SuppliersStateView(
                      connectionState: snapshot.connectionState,
                      data: snapshot.data,
                      error: snapshot.error,
                      emptyMessage: 'No hay proveedores',
                    ),
                  )
                : FutureBuilder<List<Supplier>>(
                    future: searchFuture,
                    builder: (context, snapshot) => _SuppliersStateView(
                      connectionState: snapshot.connectionState,
                      data: snapshot.data,
                      error: snapshot.error,
                      emptyMessage: 'No se encontraron proveedores',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SuppliersStateView extends StatelessWidget {
  const _SuppliersStateView({
    required this.connectionState,
    required this.data,
    required this.error,
    required this.emptyMessage,
  });

  final ConnectionState connectionState;
  final List<Supplier>? data;
  final Object? error;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (connectionState == ConnectionState.waiting && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(readableErrorMessage(error!)));
    }

    final suppliers = data ?? const <Supplier>[];
    if (suppliers.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      itemCount: suppliers.length,
      itemBuilder: (context, index) =>
          _SupplierTile(supplier: suppliers[index]),
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({required this.supplier});

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (supplier.taxId != null) 'Tax ID: ${supplier.taxId}',
      if (supplier.phone != null) 'Teléfono: ${supplier.phone}',
      if (supplier.email != null) 'Email: ${supplier.email}',
    ];

    return ListTile(
      title: Text(supplier.name),
      subtitle: details.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [for (final detail in details) Text(detail)],
            ),
    );
  }
}
