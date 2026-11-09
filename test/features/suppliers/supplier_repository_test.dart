import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/suppliers/data/supplier_repository.dart';

void main() {
  late AppDatabase database;
  late SupplierRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SupplierRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Registra un proveedor correctamente', () async {
    final id = await repository.createSupplier(
      name: 'Distribuidora Central',
      taxId: '  123456789  ',
      phone: '  55512345  ',
      email: ' contacto@example.com ',
      address: ' Calle Principal 123 ',
      notes: 'Proveedor habitual',
    );

    final supplier = await repository.findById(id);

    expect(supplier, isNotNull);
    expect(supplier!.name, 'Distribuidora Central');
    expect(supplier.taxId, '123456789');
    expect(supplier.phone, '55512345');
    expect(supplier.email, 'contacto@example.com');
    expect(supplier.address, 'Calle Principal 123');
    expect(supplier.notes, 'Proveedor habitual');
    expect(supplier.isActive, isTrue);
  });

  test('Permite registrar un proveedor solo con nombre', () async {
    final id = await repository.createSupplier(
      name: 'Proveedor sin datos adicionales',
    );

    final supplier = await repository.findById(id);

    expect(supplier, isNotNull);
    expect(supplier!.name, 'Proveedor sin datos adicionales');
    expect(supplier.taxId, isNull);
    expect(supplier.phone, isNull);
    expect(supplier.email, isNull);
    expect(supplier.address, isNull);
    expect(supplier.notes, isNull);
  });

  test('Rechaza nombres vacíos', () async {
    await expectLater(
      repository.createSupplier(name: '   '),
      throwsArgumentError,
    );
  });

  test('Rechaza nombres superiores a 150 caracteres', () async {
    await expectLater(
      repository.createSupplier(name: 'A' * 151),
      throwsArgumentError,
    );
  });

  test('Normaliza los campos opcionales vacíos como null', () async {
    final id = await repository.createSupplier(
      name: 'Proveedor de prueba',
      taxId: ' ',
      phone: '',
      email: '   ',
      address: '',
      notes: '  ',
    );

    final supplier = await repository.findById(id);

    expect(supplier!.taxId, isNull);
    expect(supplier.phone, isNull);
    expect(supplier.email, isNull);
    expect(supplier.address, isNull);
    expect(supplier.notes, isNull);
  });

  test('Actualiza correctamente los datos de un proveedor', () async {
    final id = await repository.createSupplier(
      name: 'Proveedor inicial',
      phone: '55511111',
    );

    await repository.updateSupplier(
      id: id,
      name: 'Proveedor actualizado',
      taxId: 'ABC123',
      phone: '55522222',
      email: 'nuevo@example.com',
      address: 'Nueva dirección',
      notes: 'Datos actualizados',
    );

    final supplier = await repository.findById(id);

    expect(supplier!.name, 'Proveedor actualizado');
    expect(supplier.taxId, 'ABC123');
    expect(supplier.phone, '55522222');
    expect(supplier.email, 'nuevo@example.com');
    expect(supplier.address, 'Nueva dirección');
    expect(supplier.notes, 'Datos actualizados');
  });

  test('Rechaza actualizar un proveedor inexistente', () async {
    await expectLater(
      repository.updateSupplier(
        id: 'proveedor-inexistente',
        name: 'Proveedor',
        taxId: null,
        phone: null,
        email: null,
        address: null,
        notes: null,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Rechaza actualizar con nombre vacío', () async {
    final id = await repository.createSupplier(name: 'Proveedor inicial');

    await expectLater(
      repository.updateSupplier(
        id: id,
        name: ' ',
        taxId: null,
        phone: null,
        email: null,
        address: null,
        notes: null,
      ),
      throwsArgumentError,
    );
  });

  test('Permite consultar solamente proveedores activos', () async {
    final activeId = await repository.createSupplier(name: 'Proveedor activo');

    final inactiveId = await repository.createSupplier(
      name: 'Proveedor inactivo',
    );

    await repository.setActive(inactiveId, false);

    final suppliers = await repository.watchAll().first;

    expect(suppliers.length, 1);
    expect(suppliers.first.id, activeId);
  });

  test('Permite consultar también proveedores inactivos', () async {
    await repository.createSupplier(name: 'Proveedor activo');

    final inactiveId = await repository.createSupplier(
      name: 'Proveedor inactivo',
    );

    await repository.setActive(inactiveId, false);

    final suppliers = await repository.watchAll(includeInactive: true).first;

    expect(suppliers.length, 2);
  });

  test('Busca proveedores por nombre', () async {
    await repository.createSupplier(name: 'Distribuidora Central');

    await repository.createSupplier(name: 'Comercial del Norte');

    final results = await repository.search('Central');

    expect(results.length, 1);
    expect(results.first.name, 'Distribuidora Central');
  });

  test('Busca proveedores por identificación fiscal', () async {
    await repository.createSupplier(
      name: 'Proveedor de materiales',
      taxId: 'ABC-12345',
    );

    final results = await repository.search('ABC-12345');

    expect(results.length, 1);
    expect(results.first.taxId, 'ABC-12345');
  });

  test('No devuelve proveedores inactivos en búsquedas normales', () async {
    final id = await repository.createSupplier(name: 'Proveedor especial');

    await repository.setActive(id, false);

    final results = await repository.search('Proveedor especial');

    expect(results, isEmpty);
  });

  test('Permite buscar proveedores inactivos explícitamente', () async {
    final id = await repository.createSupplier(name: 'Proveedor especial');

    await repository.setActive(id, false);

    final results = await repository.search(
      'Proveedor especial',
      includeInactive: true,
    );

    expect(results.length, 1);
    expect(results.first.id, id);
  });

  test('Una búsqueda vacía devuelve una lista vacía', () async {
    await repository.createSupplier(name: 'Proveedor de prueba');

    final results = await repository.search('   ');

    expect(results, isEmpty);
  });

  test('Desactivar un proveedor conserva su información', () async {
    final id = await repository.createSupplier(
      name: 'Proveedor conservado',
      taxId: '123456',
    );

    await repository.setActive(id, false);

    final supplier = await repository.findById(id);

    expect(supplier, isNotNull);
    expect(supplier!.isActive, isFalse);
    expect(supplier.name, 'Proveedor conservado');
    expect(supplier.taxId, '123456');
  });

  test('Permite reactivar un proveedor', () async {
    final id = await repository.createSupplier(name: 'Proveedor reactivado');

    await repository.setActive(id, false);
    await repository.setActive(id, true);

    final supplier = await repository.findById(id);

    expect(supplier!.isActive, isTrue);
  });

  test('Rechaza modificar un proveedor inexistente', () async {
    await expectLater(
      repository.setActive('proveedor-inexistente', false),
      throwsA(isA<StateError>()),
    );
  });
}
