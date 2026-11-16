import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class CustomerRepository {
  CustomerRepository(this._database);

  final AppDatabase _database;

  static const Uuid _uuid = Uuid();

  static const String individual = 'individual';
  static const String business = 'business';

  String? _normalizeOptionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _normalizeName(String name) {
    return name.trim();
  }

  void _validateCustomer({
    required String customerType,
    required String name,
    required String? documentType,
    required String? documentNumber,
  }) {
    if (customerType != individual && customerType != business) {
      throw ArgumentError('El tipo de cliente debe ser individual o business.');
    }

    final normalizedName = _normalizeName(name);

    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre del cliente es obligatorio.');
    }

    if (normalizedName.length > 150) {
      throw ArgumentError(
        'El nombre del cliente no puede superar los 150 caracteres.',
      );
    }

    final normalizedDocumentType = _normalizeOptionalText(documentType);
    final normalizedDocumentNumber = _normalizeOptionalText(documentNumber);

    if ((normalizedDocumentType == null) !=
        (normalizedDocumentNumber == null)) {
      throw ArgumentError(
        'El tipo y número de documento deben proporcionarse juntos.',
      );
    }
  }

  bool _isDuplicateDocumentError(Object error) {
    final message = error.toString();

    return message.contains(
          'customers.document_type, customers.document_number',
        ) ||
        message.contains('unique_customer_document');
  }

  Never _translateDatabaseError(Object error) {
    if (_isDuplicateDocumentError(error)) {
      throw StateError(
        'Ya existe un cliente con ese tipo y número de documento.',
      );
    }

    Error.throwWithStackTrace(error, StackTrace.current);
  }

  Future<String> createCustomer({
    required String customerType,
    required String name,
    String? commercialName,
    String? documentType,
    String? documentNumber,
    String? phone,
    String? email,
    String? address,
    String? municipality,
    String? province,
    String? country,
    String? contactPerson,
    String? notes,
  }) async {
    final normalizedDocumentType = _normalizeOptionalText(documentType);
    final normalizedDocumentNumber = _normalizeOptionalText(documentNumber);

    _validateCustomer(
      customerType: customerType,
      name: name,
      documentType: normalizedDocumentType,
      documentNumber: normalizedDocumentNumber,
    );

    final id = _uuid.v4();

    try {
      await _database
          .into(_database.customers)
          .insert(
            CustomersCompanion.insert(
              id: id,
              customerType: customerType,
              name: _normalizeName(name),
              commercialName: Value(_normalizeOptionalText(commercialName)),
              documentType: Value(normalizedDocumentType),
              documentNumber: Value(normalizedDocumentNumber),
              phone: Value(_normalizeOptionalText(phone)),
              email: Value(_normalizeOptionalText(email)),
              address: Value(_normalizeOptionalText(address)),
              municipality: Value(_normalizeOptionalText(municipality)),
              province: Value(_normalizeOptionalText(province)),
              country: Value(_normalizeOptionalText(country)),
              contactPerson: Value(_normalizeOptionalText(contactPerson)),
              notes: Value(_normalizeOptionalText(notes)),
            ),
          );
    } catch (error) {
      _translateDatabaseError(error);
    }

    return id;
  }

  Future<void> updateCustomer({
    required String id,
    required String customerType,
    required String name,
    required String? commercialName,
    required String? documentType,
    required String? documentNumber,
    required String? phone,
    required String? email,
    required String? address,
    required String? municipality,
    required String? province,
    required String? country,
    required String? contactPerson,
    required String? notes,
  }) async {
    final normalizedDocumentType = _normalizeOptionalText(documentType);
    final normalizedDocumentNumber = _normalizeOptionalText(documentNumber);

    _validateCustomer(
      customerType: customerType,
      name: name,
      documentType: normalizedDocumentType,
      documentNumber: normalizedDocumentNumber,
    );

    try {
      await _database.transaction(() async {
        final customer = await findById(id);

        if (customer == null) {
          throw StateError('El cliente que intentas actualizar no existe.');
        }

        await (_database.update(
          _database.customers,
        )..where((table) => table.id.equals(id))).write(
          CustomersCompanion(
            customerType: Value(customerType),
            name: Value(_normalizeName(name)),
            commercialName: Value(_normalizeOptionalText(commercialName)),
            documentType: Value(normalizedDocumentType),
            documentNumber: Value(normalizedDocumentNumber),
            phone: Value(_normalizeOptionalText(phone)),
            email: Value(_normalizeOptionalText(email)),
            address: Value(_normalizeOptionalText(address)),
            municipality: Value(_normalizeOptionalText(municipality)),
            province: Value(_normalizeOptionalText(province)),
            country: Value(_normalizeOptionalText(country)),
            contactPerson: Value(_normalizeOptionalText(contactPerson)),
            notes: Value(_normalizeOptionalText(notes)),
            updatedAt: Value(DateTime.now()),
          ),
        );
      });
    } catch (error) {
      _translateDatabaseError(error);
    }
  }

  Stream<List<Customer>> watchAll({bool includeInactive = false}) {
    final query = _database.select(_database.customers);

    if (!includeInactive) {
      query.where((table) => table.isActive.equals(true));
    }

    query.orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch();
  }

  Future<Customer?> findById(String id) {
    return (_database.select(
      _database.customers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<List<Customer>> search(
    String query, {
    bool includeInactive = false,
  }) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final customersQuery = _database.select(_database.customers)
      ..where(
        (table) =>
            table.name.like('%$normalizedQuery%') |
            table.commercialName.like('%$normalizedQuery%') |
            table.documentNumber.like('%$normalizedQuery%') |
            table.phone.like('%$normalizedQuery%') |
            table.email.like('%$normalizedQuery%'),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    if (!includeInactive) {
      customersQuery.where((table) => table.isActive.equals(true));
    }

    return customersQuery.get();
  }

  Future<void> setActive(String customerId, bool active) async {
    await _database.transaction(() async {
      final customer = await findById(customerId);

      if (customer == null) {
        throw StateError('El cliente que intentas modificar no existe.');
      }

      await (_database.update(
        _database.customers,
      )..where((table) => table.id.equals(customerId))).write(
        CustomersCompanion(
          isActive: Value(active),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
