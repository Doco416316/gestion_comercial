import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class SupplierRepository {
  SupplierRepository(this._database);

  final AppDatabase _database;

  static const Uuid _uuid = Uuid();

  String? _normalizeOptionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _normalizeName(String name) {
    return name.trim();
  }

  Future<String> createSupplier({
    required String name,
    String? taxId,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    final normalizedName = _normalizeName(name);

    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre del proveedor es obligatorio.');
    }

    if (normalizedName.length > 150) {
      throw ArgumentError(
        'El nombre del proveedor no puede superar los 150 caracteres.',
      );
    }

    final id = _uuid.v4();

    await _database
        .into(_database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: id,
            name: normalizedName,
            taxId: Value(_normalizeOptionalText(taxId)),
            phone: Value(_normalizeOptionalText(phone)),
            email: Value(_normalizeOptionalText(email)),
            address: Value(_normalizeOptionalText(address)),
            notes: Value(_normalizeOptionalText(notes)),
          ),
        );

    return id;
  }

  Future<void> updateSupplier({
    required String id,
    required String name,
    required String? taxId,
    required String? phone,
    required String? email,
    required String? address,
    required String? notes,
  }) async {
    final normalizedName = _normalizeName(name);

    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre del proveedor es obligatorio.');
    }

    if (normalizedName.length > 150) {
      throw ArgumentError(
        'El nombre del proveedor no puede superar los 150 caracteres.',
      );
    }

    await _database.transaction(() async {
      final supplier = await findById(id);

      if (supplier == null) {
        throw StateError('El proveedor que intentas actualizar no existe.');
      }

      await (_database.update(
        _database.suppliers,
      )..where((table) => table.id.equals(id))).write(
        SuppliersCompanion(
          name: Value(normalizedName),
          taxId: Value(_normalizeOptionalText(taxId)),
          phone: Value(_normalizeOptionalText(phone)),
          email: Value(_normalizeOptionalText(email)),
          address: Value(_normalizeOptionalText(address)),
          notes: Value(_normalizeOptionalText(notes)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Stream<List<Supplier>> watchAll({bool includeInactive = false}) {
    final query = _database.select(_database.suppliers);

    if (!includeInactive) {
      query.where((table) => table.isActive.equals(true));
    }

    query.orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch();
  }

  Future<Supplier?> findById(String id) {
    return (_database.select(
      _database.suppliers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<List<Supplier>> search(
    String query, {
    bool includeInactive = false,
  }) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final suppliersQuery = _database.select(_database.suppliers)
      ..where(
        (table) =>
            table.name.like('%$normalizedQuery%') |
            table.taxId.like('%$normalizedQuery%'),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    if (!includeInactive) {
      suppliersQuery.where((table) => table.isActive.equals(true));
    }

    return suppliersQuery.get();
  }

  Future<void> setActive(String supplierId, bool active) async {
    await _database.transaction(() async {
      final supplier = await findById(supplierId);

      if (supplier == null) {
        throw StateError('El proveedor que intentas modificar no existe.');
      }

      await (_database.update(
        _database.suppliers,
      )..where((table) => table.id.equals(supplierId))).write(
        SuppliersCompanion(
          isActive: Value(active),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
