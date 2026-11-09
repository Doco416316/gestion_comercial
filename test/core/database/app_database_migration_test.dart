import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/core/database/app_database.dart';

void main() {
  Future<void> verifyMigrationFrom(int oldVersion) async {
    final executor = NativeDatabase.memory(
      setup: (db) {
        db.execute('''
          CREATE TABLE products (
            id TEXT NOT NULL PRIMARY KEY,
            sku TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            unit TEXT NOT NULL DEFAULT 'unidad',
            track_inventory INTEGER NOT NULL DEFAULT 1,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE inventory_movements (
            id TEXT NOT NULL PRIMARY KEY,
            product_id TEXT NOT NULL,
            movement_type TEXT NOT NULL,
            quantity_milli_units INTEGER NOT NULL,
            reason TEXT NOT NULL,
            reference TEXT,
            correction_of_id TEXT,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          INSERT INTO products (id, sku, name)
          VALUES ('product-1', 'SKU-1', 'Producto de prueba')
        ''');

        db.execute('''
          INSERT INTO inventory_movements (
            id,
            product_id,
            movement_type,
            quantity_milli_units,
            reason
          )
          VALUES (
            'original',
            'product-1',
            'entry',
            1000,
            'Entrada inicial'
          )
        ''');

        db.execute('PRAGMA user_version = $oldVersion');
      },
    );

    final database = AppDatabase.forTesting(executor);

    try {
      final existing = await database
          .customSelect('SELECT id FROM inventory_movements')
          .get();

      expect(existing.length, 1);
      expect(existing.first.read<String>('id'), 'original');

      // El saldo histórico debe reconstruirse.
      final initialStock = await database
          .customSelect(
            "SELECT quantity_milli_units "
            "FROM inventory_balances "
            "WHERE product_id = 'product-1'",
          )
          .getSingle();

      expect(initialStock.read<int>('quantity_milli_units'), 1000);

      // La primera corrección debe permitirse.
      await database.customStatement('''
        INSERT INTO inventory_movements (
          id,
          product_id,
          movement_type,
          quantity_milli_units,
          reason,
          correction_of_id
        )
        VALUES (
          'compensation',
          'product-1',
          'exit',
          1000,
          'Corrección de entrada',
          'original'
        )
      ''');

      final correctedStock = await database
          .customSelect(
            "SELECT quantity_milli_units "
            "FROM inventory_balances "
            "WHERE product_id = 'product-1'",
          )
          .getSingle();

      expect(correctedStock.read<int>('quantity_milli_units'), 0);

      // No debe permitirse corregir una compensación.
      await expectLater(
        database.customStatement('''
          INSERT INTO inventory_movements (
            id,
            product_id,
            movement_type,
            quantity_milli_units,
            reason,
            correction_of_id
          )
          VALUES (
            'chained',
            'product-1',
            'entry',
            1000,
            'Corrección encadenada',
            'compensation'
          )
        '''),
        throwsA(anything),
      );

      // Tampoco se debe permitir un saldo negativo.
      await expectLater(
        database.customStatement('''
          INSERT INTO inventory_movements (
            id,
            product_id,
            movement_type,
            quantity_milli_units,
            reason
          )
          VALUES (
            'invalid-exit',
            'product-1',
            'exit',
            1,
            'Salida inválida'
          )
        '''),
        throwsA(anything),
      );

      // No se debe permitir un tipo desconocido.
      await expectLater(
        database.customStatement('''
          INSERT INTO inventory_movements (
            id,
            product_id,
            movement_type,
            quantity_milli_units,
            reason
          )
          VALUES (
            'invalid-type',
            'product-1',
            'unknown',
            1,
            'Tipo inválido'
          )
        '''),
        throwsA(anything),
      );

      final finalMovements = await database
          .customSelect('SELECT id FROM inventory_movements')
          .get();

      expect(finalMovements.length, 2);
    } finally {
      await database.close();
    }
  }

  test('migra de version 3 a 6', () async {
    await verifyMigrationFrom(3);
  });

  test('migra de version 4 a 6', () async {
    await verifyMigrationFrom(4);
  });

  test('migra de version 5 a 6', () async {
    await verifyMigrationFrom(5);
  });

  Future<void> verifyMigrationFrom7To11() async {
    const timestamp = 1735689600000;

    final executor = NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');

        // Esquema anterior: versión 7.
        db.execute('''
          CREATE TABLE currencies (
            code TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            symbol TEXT NOT NULL,
            decimal_digits INTEGER NOT NULL DEFAULT 2,
            is_active INTEGER NOT NULL DEFAULT 1,
            is_base INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE products (
            id TEXT NOT NULL PRIMARY KEY,
            sku TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            unit TEXT NOT NULL DEFAULT 'unidad',
            track_inventory INTEGER NOT NULL DEFAULT 1,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE product_prices (
            product_id TEXT NOT NULL,
            currency_code TEXT NOT NULL,
            amount_minor_units INTEGER NOT NULL,
            updated_at INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (product_id, currency_code),
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE CASCADE,
            FOREIGN KEY (currency_code)
              REFERENCES currencies(code)
          )
        ''');

        db.execute('''
          CREATE TABLE inventory_movements (
            id TEXT NOT NULL PRIMARY KEY,
            product_id TEXT NOT NULL,
            movement_type TEXT NOT NULL,
            quantity_milli_units INTEGER NOT NULL,
            reason TEXT NOT NULL,
            reference TEXT,
            correction_of_id TEXT,
            created_at INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE RESTRICT,
            FOREIGN KEY (correction_of_id)
              REFERENCES inventory_movements(id) ON DELETE RESTRICT
          )
        ''');

        db.execute('''
          CREATE TABLE inventory_balances (
            product_id TEXT NOT NULL PRIMARY KEY,
            quantity_milli_units INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE RESTRICT
          )
        ''');

        // Índices que ya existían en la versión 7.
        db.execute('''
          CREATE UNIQUE INDEX unique_base_currency
          ON currencies (is_base)
          WHERE is_base = 1
        ''');

        db.execute('''
          CREATE UNIQUE INDEX unique_inventory_movement_correction
          ON inventory_movements (correction_of_id)
          WHERE correction_of_id IS NOT NULL
        ''');

        // Datos históricos.
        db.execute('''
          INSERT INTO currencies (
            code,
            name,
            symbol,
            decimal_digits,
            is_active,
            is_base,
            created_at
          )
          VALUES (
            'CUP',
            'Peso cubano',
            'CUP',
            2,
            1,
            1,
            $timestamp
          )
        ''');

        db.execute('''
          INSERT INTO products (
            id,
            sku,
            name,
            description,
            category,
            unit,
            track_inventory,
            is_active,
            created_at,
            updated_at
          )
          VALUES (
            'product-1',
            'SKU-001',
            'Producto de prueba',
            'Descripción histórica',
            'General',
            'unidad',
            1,
            1,
            $timestamp,
            $timestamp
          )
        ''');

        db.execute('''
          INSERT INTO product_prices (
            product_id,
            currency_code,
            amount_minor_units,
            updated_at
          )
          VALUES (
            'product-1',
            'CUP',
            15000,
            $timestamp
          )
        ''');

        db.execute('''
          INSERT INTO inventory_movements (
            id,
            product_id,
            movement_type,
            quantity_milli_units,
            reason,
            reference,
            correction_of_id,
            created_at
          )
          VALUES (
            'movement-1',
            'product-1',
            'entry',
            12500,
            'Inventario inicial',
            'REF-001',
            NULL,
            $timestamp
          )
        ''');

        db.execute('''
          INSERT INTO inventory_balances (
            product_id,
            quantity_milli_units,
            updated_at
          )
          VALUES (
            'product-1',
            12500,
            $timestamp
          )
        ''');

        // Simula una base de datos que ya estaba en versión 7.
        db.execute('PRAGMA user_version = 7');
      },
    );

    final database = AppDatabase.forTesting(executor);

    try {
      // La primera consulta fuerza la apertura y migración.
      final currencies = await database.select(database.currencies).get();

      expect(currencies, hasLength(1));
      expect(currencies.single.code, 'CUP');
      expect(currencies.single.isBase, isTrue);

      // Comprueba que los productos se conservaron.
      final products = await database.select(database.products).get();

      expect(products, hasLength(1));
      expect(products.single.id, 'product-1');
      expect(products.single.sku, 'SKU-001');
      expect(products.single.name, 'Producto de prueba');

      // Comprueba los precios históricos.
      final prices = await database.select(database.productPrices).get();

      expect(prices, hasLength(1));
      expect(prices.single.amountMinorUnits, 15000);

      // Comprueba los movimientos históricos.
      final movements = await database
          .select(database.inventoryMovements)
          .get();

      expect(movements, hasLength(1));
      expect(movements.single.id, 'movement-1');
      expect(movements.single.quantityMilliUnits, 12500);

      // La migración no debe reconstruir ni alterar los saldos.
      final balances = await database.select(database.inventoryBalances).get();

      expect(balances, hasLength(1));
      expect(balances.single.productId, 'product-1');
      expect(balances.single.quantityMilliUnits, 12500);

      // Comprueba que las siete tablas nuevas fueron creadas.
      final tableRows = await database.customSelect('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
      ''').get();

      final tableNames = tableRows
          .map((row) => row.read<String>('name'))
          .toSet();

      const newTables = {
        'suppliers',
        'exchange_rates',
        'purchases',
        'purchase_details',
        'purchase_receipts',
        'purchase_receipt_details',
        'supplier_payments',
      };

      expect(tableNames, containsAll(newTables));

      // Comprueba los índices nuevos.
      final indexRows = await database.customSelect('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index'
      ''').get();

      final indexNames = indexRows
          .map((row) => row.read<String>('name'))
          .toSet();

      const expectedIndexes = {
        'unique_exchange_rate_currency_effective_at',
        'unique_supplier_purchase_document',
        'unique_purchase_receipt_inventory_movement',
        'idx_purchases_supplier',
        'idx_purchase_details_purchase',
        'idx_purchase_details_product',
        'idx_purchase_receipts_purchase',
        'idx_receipt_details_purchase_detail',
        'idx_supplier_payments_purchase',
      };

      expect(indexNames, containsAll(expectedIndexes));

      // Los índices anteriores también deben permanecer.
      expect(indexNames, contains('unique_base_currency'));
      expect(indexNames, contains('unique_inventory_movement_correction'));

      // Verifica que la versión quedó actualizada.
      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(versionRow.read<int>('user_version'), 11);

      // Comprueba la integridad de las relaciones.
      final foreignKeyViolations = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();

      expect(foreignKeyViolations, isEmpty);
    } finally {
      await database.close();
    }
  }

  Future<void> verifyMigrationFrom9To11() async {
    const timestamp = 1735689600000;

    final executor = NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');

        // Esquema mínimo de la versión 9 necesario para esta migración.
        db.execute('''
          CREATE TABLE currencies (
            code TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            symbol TEXT NOT NULL,
            decimal_digits INTEGER NOT NULL DEFAULT 2,
            is_active INTEGER NOT NULL DEFAULT 1,
            is_base INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE suppliers (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            tax_id TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            notes TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE products (
            id TEXT NOT NULL PRIMARY KEY,
            sku TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            unit TEXT NOT NULL DEFAULT 'unidad',
            track_inventory INTEGER NOT NULL DEFAULT 1,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE purchases (
            id TEXT NOT NULL PRIMARY KEY,
            supplier_id TEXT NOT NULL,
            document_number TEXT,
            purchase_date INTEGER NOT NULL,
            currency_code TEXT NOT NULL,
            exchange_rate_to_base_snapshot TEXT NOT NULL,
            subtotal_minor_units INTEGER NOT NULL,
            discount_minor_units INTEGER NOT NULL DEFAULT 0,
            tax_minor_units INTEGER NOT NULL DEFAULT 0,
            total_minor_units INTEGER NOT NULL,
            notes TEXT,
            created_at INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (supplier_id)
              REFERENCES suppliers(id) ON DELETE RESTRICT,
            FOREIGN KEY (currency_code)
              REFERENCES currencies(code)
          )
        ''');

        db.execute('''
          CREATE TABLE purchase_details (
            id TEXT NOT NULL PRIMARY KEY,
            purchase_id TEXT NOT NULL,
            product_id TEXT NOT NULL,
            sku_snapshot TEXT NOT NULL,
            product_name_snapshot TEXT NOT NULL,
            unit_snapshot TEXT NOT NULL,
            quantity_milli_units INTEGER NOT NULL,
            unit_cost_minor_units INTEGER NOT NULL,
            discount_minor_units INTEGER NOT NULL DEFAULT 0,
            tax_minor_units INTEGER NOT NULL DEFAULT 0,
            total_minor_units INTEGER NOT NULL,
            FOREIGN KEY (purchase_id)
              REFERENCES purchases(id) ON DELETE RESTRICT,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE RESTRICT
          )
        ''');

        // Estas tablas ya existían en la versión 9.
        // Se incluyen porque los triggers de la versión 11 las consultan
        // al proteger recepciones y pagos de compras.
        db.execute('''
          CREATE TABLE inventory_movements (
            id TEXT NOT NULL PRIMARY KEY,
            product_id TEXT NOT NULL,
            movement_type TEXT NOT NULL,
            quantity_milli_units INTEGER NOT NULL,
            reason TEXT NOT NULL,
            reference TEXT,
            correction_of_id TEXT,
            created_at INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE RESTRICT,
            FOREIGN KEY (correction_of_id)
              REFERENCES inventory_movements(id) ON DELETE RESTRICT
          )
        ''');

        db.execute('''
          CREATE TABLE purchase_receipts (
            id TEXT NOT NULL PRIMARY KEY,
            purchase_id TEXT NOT NULL
              REFERENCES purchases(id) ON DELETE RESTRICT,
            received_at INTEGER NOT NULL,
            reference TEXT,
            notes TEXT,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          CREATE TABLE purchase_receipt_details (
            id TEXT NOT NULL PRIMARY KEY,
            receipt_id TEXT NOT NULL
              REFERENCES purchase_receipts(id) ON DELETE RESTRICT,
            purchase_detail_id TEXT NOT NULL
              REFERENCES purchase_details(id) ON DELETE RESTRICT,
            quantity_milli_units INTEGER NOT NULL,
            inventory_movement_id TEXT
              REFERENCES inventory_movements(id) ON DELETE RESTRICT
          )
        ''');

        db.execute('''
          CREATE TABLE supplier_payments (
            id TEXT NOT NULL PRIMARY KEY,
            purchase_id TEXT NOT NULL
              REFERENCES purchases(id) ON DELETE RESTRICT,
            amount_minor_units INTEGER NOT NULL,
            currency_code TEXT NOT NULL
              REFERENCES currencies(code),
            exchange_rate_to_base_snapshot TEXT NOT NULL,
            applied_amount_minor_units INTEGER NOT NULL,
            payment_date INTEGER NOT NULL,
            payment_method TEXT NOT NULL,
            reference TEXT,
            notes TEXT,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');

        db.execute('''
          INSERT INTO currencies (
            code, name, symbol, decimal_digits, is_active, is_base
          )
          VALUES ('CUP', 'Peso cubano', 'CUP', 2, 1, 1)
        ''');

        db.execute('''
          INSERT INTO suppliers (id, name)
          VALUES ('supplier-1', 'Proveedor de prueba')
        ''');

        db.execute('''
          INSERT INTO products (id, sku, name)
          VALUES ('product-1', 'SKU-001', 'Producto histórico')
        ''');

        db.execute('''
          INSERT INTO purchases (
            id,
            supplier_id,
            purchase_date,
            currency_code,
            exchange_rate_to_base_snapshot,
            subtotal_minor_units,
            discount_minor_units,
            tax_minor_units,
            total_minor_units,
            created_at
          )
          VALUES (
            'purchase-1',
            'supplier-1',
            $timestamp,
            'CUP',
            '1',
            10000,
            1000,
            1800,
            10800,
            $timestamp
          )
        ''');

        // Detalle histórico creado antes de la versión 10.
        db.execute('''
          INSERT INTO purchase_details (
            id,
            purchase_id,
            product_id,
            sku_snapshot,
            product_name_snapshot,
            unit_snapshot,
            quantity_milli_units,
            unit_cost_minor_units,
            discount_minor_units,
            tax_minor_units,
            total_minor_units
          )
          VALUES (
            'detail-1',
            'purchase-1',
            'product-1',
            'SKU-001',
            'Producto histórico',
            'unidad',
            2000,
            5000,
            1000,
            1800,
            10800
          )
        ''');

        db.execute('PRAGMA user_version = 9');
      },
    );

    final database = AppDatabase.forTesting(executor);

    try {
      // Esta consulta fuerza la apertura y migración.
      final details = await database.customSelect('''
        SELECT *
        FROM purchase_details
        WHERE id = 'detail-1'
      ''').get();

      expect(details, hasLength(1));

      final historicalDetail = details.single;

      // Los datos históricos deben permanecer intactos.
      expect(historicalDetail.read<String>('id'), 'detail-1');
      expect(historicalDetail.read<String>('purchase_id'), 'purchase-1');
      expect(historicalDetail.read<String>('product_id'), 'product-1');
      expect(historicalDetail.read<String>('sku_snapshot'), 'SKU-001');
      expect(
        historicalDetail.read<String>('product_name_snapshot'),
        'Producto histórico',
      );
      expect(historicalDetail.read<int>('quantity_milli_units'), 2000);
      expect(historicalDetail.read<int>('unit_cost_minor_units'), 5000);
      expect(historicalDetail.read<int>('discount_minor_units'), 1000);
      expect(historicalDetail.read<int>('tax_minor_units'), 1800);
      expect(historicalDetail.read<int>('total_minor_units'), 10800);

      // Los registros anteriores reciben valores compatibles.
      expect(historicalDetail.read<String>('discount_type'), 'fixed');
      expect(historicalDetail.read<String>('tax_type'), 'fixed');
      expect(historicalDetail.data['discount_rate'], isNull);
      expect(historicalDetail.data['tax_rate'], isNull);

      // La cabecera histórica debe conservar sus importes.
      final purchase = await database.customSelect('''
        SELECT
          subtotal_minor_units,
          discount_minor_units,
          tax_minor_units,
          total_minor_units,
          status,
          confirmed_at,
          cancelled_at,
          cancellation_reason
        FROM purchases
        WHERE id = 'purchase-1'
      ''').getSingle();

      expect(purchase.read<int>('subtotal_minor_units'), 10000);
      expect(purchase.read<int>('discount_minor_units'), 1000);
      expect(purchase.read<int>('tax_minor_units'), 1800);
      expect(purchase.read<int>('total_minor_units'), 10800);

      // Las compras existentes deben migrarse como confirmadas.
      expect(purchase.read<String>('status'), 'confirmed');
      expect(purchase.read<int>('confirmed_at'), timestamp);
      expect(purchase.data['cancelled_at'], isNull);
      expect(purchase.data['cancellation_reason'], isNull);

      // Creamos una compra nueva en borrador.
      // El estado draft se establece mediante el valor predeterminado.
      await database.customStatement('''
        INSERT INTO purchases (
          id,
          supplier_id,
          purchase_date,
          currency_code,
          exchange_rate_to_base_snapshot,
          subtotal_minor_units,
          discount_minor_units,
          tax_minor_units,
          total_minor_units,
          created_at
        )
        VALUES (
          'purchase-2',
          'supplier-1',
          $timestamp,
          'CUP',
          '1',
          5000,
          500,
          900,
          5400,
          $timestamp
        )
      ''');

      // Verificamos el estado inicial de la nueva compra.
      final draftPurchase = await database.customSelect('''
        SELECT
          status,
          confirmed_at,
          cancelled_at,
          cancellation_reason
        FROM purchases
        WHERE id = 'purchase-2'
      ''').getSingle();

      expect(draftPurchase.read<String>('status'), 'draft');
      expect(draftPurchase.data['confirmed_at'], isNull);
      expect(draftPurchase.data['cancelled_at'], isNull);
      expect(draftPurchase.data['cancellation_reason'], isNull);

      // Los nuevos detalles pueden conservar porcentajes.
      // Se insertan en purchase-2 porque purchase-1 ya está confirmada.
      await database.customStatement('''
        INSERT INTO purchase_details (
          id,
          purchase_id,
          product_id,
          sku_snapshot,
          product_name_snapshot,
          unit_snapshot,
          quantity_milli_units,
          unit_cost_minor_units,
          discount_minor_units,
          discount_type,
          discount_rate,
          tax_minor_units,
          tax_type,
          tax_rate,
          total_minor_units
        )
        VALUES (
          'detail-2',
          'purchase-2',
          'product-1',
          'SKU-001',
          'Producto histórico',
          'unidad',
          1000,
          5000,
          500,
          'percentage',
          '10',
          900,
          'percentage',
          '20',
          5400
        )
      ''');

      final newDetail = await database.customSelect('''
        SELECT
          discount_type,
          discount_rate,
          tax_type,
          tax_rate
        FROM purchase_details
        WHERE id = 'detail-2'
      ''').getSingle();

      expect(newDetail.read<String>('discount_type'), 'percentage');
      expect(newDetail.read<String>('discount_rate'), '10');
      expect(newDetail.read<String>('tax_type'), 'percentage');
      expect(newDetail.read<String>('tax_rate'), '20');

      // Las relaciones deben continuar siendo válidas.
      final foreignKeyViolations = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();

      expect(foreignKeyViolations, isEmpty);

      // La versión debe quedar actualizada.
      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(versionRow.read<int>('user_version'), 11);
    } finally {
      await database.close();
    }
  }

  test('migra correctamente de version 7 a 11', verifyMigrationFrom7To11);

  test('migra correctamente de version 9 a 11', verifyMigrationFrom9To11);
}
