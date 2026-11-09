import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_comercial/core/database/app_database.dart';
import 'package:gestion_comercial/features/products/data/product_repository.dart';

void main() {
  late AppDatabase database;
  late ProductRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProductRepository(database);

    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'CUP',
            name: 'Peso cubano',
            symbol: '\$',
          ),
        );

    await database
        .into(database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: 'USD',
            name: 'Dólar estadounidense',
            symbol: '\$',
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('Registra un producto correctamente', () async {
    final id = await repository.createProduct(
      sku: 'llav-001',
      name: 'Llavero personalizado',
    );

    final product = await repository.findById(id);

    expect(product, isNotNull);
    expect(product!.sku, 'LLAV-001');
    expect(product.name, 'Llavero personalizado');
    expect(product.isActive, isTrue);
  });

  test('Permite asignar precios independientes en CUP y USD', () async {
    final id = await repository.createProduct(
      sku: 'LLAV-002',
      name: 'Llavero personalizado',
    );

    await repository.setPrice(
      productId: id,
      currencyCode: 'CUP',
      amountMinorUnits: 25000,
    );

    await repository.setPrice(
      productId: id,
      currencyCode: 'USD',
      amountMinorUnits: 200,
    );

    final cupPrice = await repository.findPrice(
      productId: id,
      currencyCode: 'CUP',
    );

    final usdPrice = await repository.findPrice(
      productId: id,
      currencyCode: 'USD',
    );

    expect(cupPrice!.amountMinorUnits, 25000);
    expect(usdPrice!.amountMinorUnits, 200);
  });

  test('Actualizar un precio no crea duplicados', () async {
    final id = await repository.createProduct(sku: 'LLAV-003', name: 'Llavero');

    await repository.setPrice(
      productId: id,
      currencyCode: 'CUP',
      amountMinorUnits: 25000,
    );

    await repository.setPrice(
      productId: id,
      currencyCode: 'CUP',
      amountMinorUnits: 30000,
    );

    final prices = await repository.watchPrices(id).first;

    expect(prices.length, 1);
    expect(prices.first.amountMinorUnits, 30000);
  });

  test('Rechaza precios negativos', () async {
    final id = await repository.createProduct(sku: 'LLAV-004', name: 'Llavero');

    expect(
      () => repository.setPrice(
        productId: id,
        currencyCode: 'CUP',
        amountMinorUnits: -100,
      ),
      throwsArgumentError,
    );
  });

  test('Rechaza monedas inexistentes', () async {
    final id = await repository.createProduct(sku: 'LLAV-005', name: 'Llavero');

    await expectLater(
      repository.setPrice(
        productId: id,
        currencyCode: 'EUR',
        amountMinorUnits: 100,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('No permite asignar precios en monedas inactivas', () async {
    final id = await repository.createProduct(sku: 'LLAV-006', name: 'Llavero');

    await (database.update(database.currencies)
          ..where((table) => table.code.equals('USD')))
        .write(const CurrenciesCompanion(isActive: Value(false)));

    await expectLater(
      repository.setPrice(
        productId: id,
        currencyCode: 'USD',
        amountMinorUnits: 200,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Desactivar un producto conserva su información', () async {
    final id = await repository.createProduct(sku: 'LLAV-007', name: 'Llavero');

    await repository.setActive(id, false);

    final product = await repository.findById(id);

    expect(product, isNotNull);
    expect(product!.isActive, isFalse);
    expect(product.sku, 'LLAV-007');
  });

  test('Rechaza registrar un SKU duplicado', () async {
    await repository.createProduct(sku: 'LLAV-100', name: 'Primer producto');

    await expectLater(
      repository.createProduct(sku: 'llav-100', name: 'Segundo producto'),
      throwsA(isA<StateError>()),
    );
  });

  test('Actualiza correctamente un producto', () async {
    final id = await repository.createProduct(
      sku: 'LLAV-101',
      name: 'Llavero inicial',
    );

    await repository.updateProduct(
      id: id,
      sku: 'LLAV-102',
      name: 'Llavero actualizado',
      description: 'Descripción nueva',
      category: 'Accesorios',
      unit: 'unidad',
      trackInventory: true,
    );

    final product = await repository.findById(id);

    expect(product!.sku, 'LLAV-102');
    expect(product.name, 'Llavero actualizado');
    expect(product.description, 'Descripción nueva');
    expect(product.category, 'Accesorios');
  });

  test('Rechaza actualizar un producto inexistente', () async {
    await expectLater(
      repository.updateProduct(
        id: 'producto-inexistente',
        sku: 'LLAV-103',
        name: 'Producto',
        description: null,
        category: null,
        unit: 'unidad',
        trackInventory: true,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
