import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/customers/data/customer_repository.dart';

void main() {
  late AppDatabase database;
  late CustomerRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CustomerRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<String> createCustomer({
    String customerType = 'individual',
    String name = 'Cliente de prueba',
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
  }) {
    return repository.createCustomer(
      customerType: customerType,
      name: name,
      commercialName: commercialName,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
      email: email,
      address: address,
      municipality: municipality,
      province: province,
      country: country,
      contactPerson: contactPerson,
      notes: notes,
    );
  }

  Future<void> updateCustomer(
    String id, {
    String customerType = 'individual',
    String name = 'Cliente actualizado',
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
  }) {
    return repository.updateCustomer(
      id: id,
      customerType: customerType,
      name: name,
      commercialName: commercialName,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
      email: email,
      address: address,
      municipality: municipality,
      province: province,
      country: country,
      contactPerson: contactPerson,
      notes: notes,
    );
  }

  group('CustomerRepository', () {
    group('createCustomer', () {
      test('crea un cliente y genera un identificador', () async {
        final id = await createCustomer();

        expect(id, isNotEmpty);

        final customer = await repository.findById(id);

        expect(customer, isNotNull);
        expect(customer!.id, id);
        expect(customer.name, 'Cliente de prueba');
        expect(customer.customerType, 'individual');
        expect(customer.isActive, isTrue);
      });

      test('normaliza los espacios de los campos de texto', () async {
        final id = await createCustomer(
          name: '  Cliente normalizado  ',
          commercialName: '  Comercio  ',
          documentType: '  CI  ',
          documentNumber: '  123456  ',
          phone: '  55512345  ',
          email: '  cliente@example.com  ',
          address: '  Calle principal  ',
          municipality: '  Municipio  ',
          province: '  Provincia  ',
          country: '  Cuba  ',
          contactPerson: '  Contacto  ',
          notes: '  Observaciones  ',
        );

        final customer = await repository.findById(id);

        expect(customer!.name, 'Cliente normalizado');
        expect(customer.commercialName, 'Comercio');
        expect(customer.documentType, 'CI');
        expect(customer.documentNumber, '123456');
        expect(customer.phone, '55512345');
        expect(customer.email, 'cliente@example.com');
        expect(customer.address, 'Calle principal');
        expect(customer.municipality, 'Municipio');
        expect(customer.province, 'Provincia');
        expect(customer.country, 'Cuba');
        expect(customer.contactPerson, 'Contacto');
        expect(customer.notes, 'Observaciones');
      });

      test('convierte los campos opcionales vacíos en null', () async {
        final id = await createCustomer(
          commercialName: '   ',
          phone: '',
          email: '   ',
          address: '',
          notes: ' ',
        );

        final customer = await repository.findById(id);

        expect(customer!.commercialName, isNull);
        expect(customer.phone, isNull);
        expect(customer.email, isNull);
        expect(customer.address, isNull);
        expect(customer.notes, isNull);
      });

      test('rechaza un tipo de cliente no válido', () async {
        await expectLater(
          createCustomer(customerType: 'unknown'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rechaza un nombre vacío', () async {
        await expectLater(
          createCustomer(name: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rechaza un nombre superior a 150 caracteres', () async {
        await expectLater(
          createCustomer(name: 'A' * 151),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('acepta un nombre de exactamente 150 caracteres', () async {
        final id = await createCustomer(name: 'A' * 150);

        final customer = await repository.findById(id);

        expect(customer, isNotNull);
        expect(customer!.name.length, 150);
      });

      test('rechaza un documento con tipo pero sin número', () async {
        await expectLater(
          createCustomer(documentType: 'CI'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rechaza un documento con número pero sin tipo', () async {
        await expectLater(
          createCustomer(documentNumber: '123456'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('permite crear clientes sin documento', () async {
        final id = await createCustomer();

        final customer = await repository.findById(id);

        expect(customer!.documentType, isNull);
        expect(customer.documentNumber, isNull);
      });

      test('impide documentos duplicados', () async {
        await createCustomer(documentType: 'CI', documentNumber: '123456');

        await expectLater(
          createCustomer(
            name: 'Otro cliente',
            documentType: 'CI',
            documentNumber: '123456',
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('permite el mismo número con distinto tipo documental', () async {
        await createCustomer(documentType: 'CI', documentNumber: '123456');

        final secondId = await createCustomer(
          name: 'Segundo cliente',
          documentType: 'PASSPORT',
          documentNumber: '123456',
        );

        expect(await repository.findById(secondId), isNotNull);
      });
    });

    group('updateCustomer', () {
      test('actualiza los datos de un cliente existente', () async {
        final id = await createCustomer();

        await updateCustomer(
          id,
          name: 'Nuevo nombre',
          customerType: 'business',
          commercialName: 'Empresa actualizada',
          phone: '55500000',
          email: 'nuevo@example.com',
        );

        final customer = await repository.findById(id);

        expect(customer!.name, 'Nuevo nombre');
        expect(customer.customerType, 'business');
        expect(customer.commercialName, 'Empresa actualizada');
        expect(customer.phone, '55500000');
        expect(customer.email, 'nuevo@example.com');
      });

      test(
        'normaliza los campos opcionales durante la actualización',
        () async {
          final id = await createCustomer(
            commercialName: 'Comercio anterior',
            phone: '55512345',
          );

          await updateCustomer(id, commercialName: '   ', phone: '');

          final customer = await repository.findById(id);

          expect(customer!.commercialName, isNull);
          expect(customer.phone, isNull);
        },
      );

      test('rechaza la actualización de un cliente inexistente', () async {
        await expectLater(
          updateCustomer('id-inexistente'),
          throwsA(isA<StateError>()),
        );
      });

      test('rechaza datos inválidos durante la actualización', () async {
        final id = await createCustomer();

        await expectLater(
          updateCustomer(id, customerType: 'unknown'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'impide asignar un documento perteneciente a otro cliente',
        () async {
          await createCustomer(documentType: 'CI', documentNumber: '111111');

          final secondId = await createCustomer(name: 'Segundo cliente');

          await expectLater(
            updateCustomer(
              secondId,
              documentType: 'CI',
              documentNumber: '111111',
            ),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('watchAll', () {
      test('devuelve solamente clientes activos por defecto', () async {
        final activeId = await createCustomer(name: 'Activo');
        final inactiveId = await createCustomer(name: 'Inactivo');

        await repository.setActive(inactiveId, false);

        final customers = await repository.watchAll().first;

        expect(customers.map((customer) => customer.id), [activeId]);
      });

      test('incluye clientes inactivos cuando se solicita', () async {
        await createCustomer(name: 'Activo');

        final inactiveId = await createCustomer(name: 'Inactivo');
        await repository.setActive(inactiveId, false);

        final customers = await repository
            .watchAll(includeInactive: true)
            .first;

        expect(customers.length, 2);
      });

      test('ordena los clientes por nombre ascendente', () async {
        await createCustomer(name: 'Zulma');
        await createCustomer(name: 'Ana');
        await createCustomer(name: 'Carlos');

        final customers = await repository.watchAll().first;

        expect(customers.map((customer) => customer.name).toList(), [
          'Ana',
          'Carlos',
          'Zulma',
        ]);
      });
    });

    group('findById', () {
      test('devuelve null cuando el cliente no existe', () async {
        final customer = await repository.findById('inexistente');

        expect(customer, isNull);
      });

      test('devuelve el cliente correspondiente al identificador', () async {
        final id = await createCustomer(name: 'Cliente localizado');

        final customer = await repository.findById(id);

        expect(customer, isNotNull);
        expect(customer!.name, 'Cliente localizado');
      });
    });

    group('search', () {
      test('busca por nombre', () async {
        await createCustomer(name: 'Comercial Habana');

        final results = await repository.search('Habana');

        expect(results.length, 1);
        expect(results.first.name, 'Comercial Habana');
      });

      test('busca por nombre comercial', () async {
        await createCustomer(
          name: 'Juan Pérez',
          commercialName: 'Tienda Central',
        );

        final results = await repository.search('Tienda Central');

        expect(results.length, 1);
      });

      test('busca por documento', () async {
        await createCustomer(documentType: 'CI', documentNumber: '987654');

        final results = await repository.search('987654');

        expect(results.length, 1);
      });

      test('busca por teléfono', () async {
        await createCustomer(phone: '55598765');

        final results = await repository.search('55598765');

        expect(results.length, 1);
      });

      test('busca por correo electrónico', () async {
        await createCustomer(email: 'contacto@example.com');

        final results = await repository.search('contacto@example.com');

        expect(results.length, 1);
      });

      test('devuelve una lista vacía para una búsqueda vacía', () async {
        await createCustomer();

        final results = await repository.search('   ');

        expect(results, isEmpty);
      });

      test('excluye clientes inactivos por defecto', () async {
        final id = await createCustomer(name: 'Cliente inactivo');

        await repository.setActive(id, false);

        final results = await repository.search('inactivo');

        expect(results, isEmpty);
      });

      test('permite buscar clientes inactivos cuando se solicita', () async {
        final id = await createCustomer(name: 'Cliente inactivo');

        await repository.setActive(id, false);

        final results = await repository.search(
          'inactivo',
          includeInactive: true,
        );

        expect(results.length, 1);
        expect(results.first.id, id);
      });
    });

    group('setActive', () {
      test('desactiva un cliente sin eliminarlo', () async {
        final id = await createCustomer();

        await repository.setActive(id, false);

        final customer = await repository.findById(id);

        expect(customer, isNotNull);
        expect(customer!.isActive, isFalse);
      });

      test('permite reactivar un cliente', () async {
        final id = await createCustomer();

        await repository.setActive(id, false);
        await repository.setActive(id, true);

        final customer = await repository.findById(id);

        expect(customer!.isActive, isTrue);
      });

      test('rechaza la modificación de un cliente inexistente', () async {
        await expectLater(
          repository.setActive('inexistente', false),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
