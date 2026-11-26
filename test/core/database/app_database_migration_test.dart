import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
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

  Future<void> verifyMigrationFrom7To14() async {
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
        'customers',
        'sales',
        'sale_details',
        'sale_payments',
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
        'unique_customer_document',
        'unique_sale_document_number',
        'unique_sale_detail_inventory_movement',
        'idx_sales_customer_date',
        'idx_sales_date',
        'idx_sale_details_sale',
        'idx_sale_details_product',
        'idx_sale_payments_sale_date',
      };

      expect(indexNames, containsAll(expectedIndexes));

      // Los índices anteriores también deben permanecer.
      expect(indexNames, contains('unique_base_currency'));
      expect(indexNames, contains('unique_inventory_movement_correction'));

      // Verifica que la versión quedó actualizada.
      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(versionRow.read<int>('user_version'), 18);

      // Comprueba la integridad de las relaciones.
      final foreignKeyViolations = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();

      expect(foreignKeyViolations, isEmpty);
    } finally {
      await database.close();
    }
  }

  Future<void> verifyMigrationFrom9To14() async {
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
          CREATE TABLE exchange_rates (
            id TEXT NOT NULL PRIMARY KEY,
            currency_code TEXT NOT NULL,
            rate_to_base TEXT NOT NULL,
            effective_at INTEGER NOT NULL,
            created_by_user_id TEXT,
            created_at INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (currency_code)
              REFERENCES currencies(code)
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

      expect(versionRow.read<int>('user_version'), 18);
    } finally {
      await database.close();
    }
  }

  Future<void> verifyMigrationFrom11To14() async {
    const timestamp = 1735689600000;

    final executor = NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');

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
        CREATE TABLE exchange_rates (
          id TEXT NOT NULL PRIMARY KEY,
          currency_code TEXT NOT NULL,
          rate_to_base TEXT NOT NULL,
          effective_at INTEGER NOT NULL,
          created_by_user_id TEXT,
          created_at INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (currency_code)
            REFERENCES currencies(code)
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
          status TEXT NOT NULL DEFAULT 'draft',
          confirmed_at INTEGER,
          cancelled_at INTEGER,
          cancellation_reason TEXT,
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
          discount_type TEXT NOT NULL DEFAULT 'fixed',
          discount_rate TEXT,
          tax_minor_units INTEGER NOT NULL DEFAULT 0,
          tax_type TEXT NOT NULL DEFAULT 'fixed',
          tax_rate TEXT,
          total_minor_units INTEGER NOT NULL,
          FOREIGN KEY (purchase_id)
            REFERENCES purchases(id) ON DELETE RESTRICT,
          FOREIGN KEY (product_id)
            REFERENCES products(id) ON DELETE RESTRICT
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
        VALUES ('supplier-1', 'Proveedor histórico')
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
          status,
          confirmed_at,
          created_at
        )
        VALUES (
          'purchase-1',
          'supplier-1',
          $timestamp,
          'CUP',
          '1',
          10000,
          0,
          0,
          10000,
          'confirmed',
          $timestamp,
          $timestamp
        )
      ''');

        db.execute('PRAGMA user_version = 11');
      },
    );

    final database = AppDatabase.forTesting(executor);

    try {
      // Fuerza la apertura y migración.
      final customersTable = await database.customSelect('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'customers'
    ''').get();

      expect(customersTable, hasLength(1));

      // Comprueba que el índice único existe.
      final indexes = await database.customSelect('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'index'
        AND name = 'unique_customer_document'
    ''').get();

      expect(indexes, hasLength(1));

      // Cliente individual válido.
      await database.customStatement('''
      INSERT INTO customers (
        id,
        customer_type,
        name,
        document_type,
        document_number
      )
      VALUES (
        'customer-1',
        'individual',
        'Cliente individual',
        'CI',
        '123456'
      )
    ''');

      // Empresa válida sin documento.
      await database.customStatement('''
      INSERT INTO customers (
        id,
        customer_type,
        name
      )
      VALUES (
        'customer-2',
        'business',
        'Empresa de prueba'
      )
    ''');

      // No debe aceptar documentos duplicados.
      await expectLater(
        database.customStatement('''
        INSERT INTO customers (
          id,
          customer_type,
          name,
          document_type,
          document_number
        )
        VALUES (
          'customer-3',
          'individual',
          'Otro cliente',
          'CI',
          '123456'
        )
      '''),
        throwsA(anything),
      );

      // No debe aceptar tipos desconocidos.
      await expectLater(
        database.customStatement('''
        INSERT INTO customers (
          id,
          customer_type,
          name
        )
        VALUES (
          'customer-invalid-type',
          'unknown',
          'Cliente inválido'
        )
      '''),
        throwsA(anything),
      );

      // No debe aceptar nombres vacíos.
      await expectLater(
        database.customStatement('''
        INSERT INTO customers (
          id,
          customer_type,
          name
        )
        VALUES (
          'customer-invalid-name',
          'individual',
          '   '
        )
      '''),
        throwsA(anything),
      );

      // Tipo y número de documento deben proporcionarse juntos.
      await expectLater(
        database.customStatement('''
        INSERT INTO customers (
          id,
          customer_type,
          name,
          document_type
        )
        VALUES (
          'customer-invalid-document',
          'individual',
          'Cliente inválido',
          'CI'
        )
      '''),
        throwsA(anything),
      );

      // La protección también debe actuar al actualizar.
      await expectLater(
        database.customStatement('''
        UPDATE customers
        SET customer_type = 'unknown'
        WHERE id = 'customer-1'
      '''),
        throwsA(anything),
      );

      // Los dos clientes válidos deben conservarse.
      final customers = await database.customSelect('''
      SELECT id, customer_type, name
      FROM customers
      ORDER BY id
    ''').get();

      expect(customers, hasLength(2));
      expect(customers.first.read<String>('id'), 'customer-1');
      expect(customers.last.read<String>('id'), 'customer-2');

      // Comprueba las validaciones de pagos instaladas por la migración.
      await database.customStatement('''
        INSERT INTO sales (
          id,
          sale_date,
          currency_code,
          exchange_rate_to_base_snapshot,
          subtotal_minor_units,
          total_minor_units,
          payment_type,
          status
        )
        VALUES (
          'sale-payment-test',
          $timestamp,
          'CUP',
          '1',
          10000,
          10000,
          'credit',
          'draft'
        )
      ''');

      // Agrega un detalle mientras la venta sigue en borrador.
      await database.customStatement('''
        INSERT INTO sale_details (
          id,
          sale_id,
          product_id,
          sku_snapshot,
          product_name_snapshot,
          unit_snapshot,
          quantity_milli_units,
          unit_price_minor_units,
          total_minor_units
        )
        VALUES (
          'sale-detail-payment-test',
          'sale-payment-test',
          'product-1',
          'SKU-001',
          'Producto histórico',
          'unidad',
          1000,
          10000,
          10000
        )
      ''');

      // Confirma la venta después de agregar el detalle.
      await database.customStatement('''
        UPDATE sales
        SET
          status = 'confirmed',
          confirmed_at = $timestamp
        WHERE id = 'sale-payment-test'
      ''');

      // Un pago válido debe ser aceptado.
      await database.customStatement('''
        INSERT INTO sale_payments (
          id,
          sale_id,
          amount_minor_units,
          currency_code,
          exchange_rate_to_base_snapshot,
          applied_amount_minor_units,
          payment_date,
          payment_method
        )
        VALUES (
          'payment-valid',
          'sale-payment-test',
          4000,
          'CUP',
          '1',
          4000,
          $timestamp,
          'cash'
        )
      ''');

      // No debe permitir aplicar más que el saldo pendiente (6000).
      await expectLater(
        database.customStatement('''
          INSERT INTO sale_payments (
            id,
            sale_id,
            amount_minor_units,
            currency_code,
            exchange_rate_to_base_snapshot,
            applied_amount_minor_units,
            payment_date,
            payment_method
          )
          VALUES (
            'payment-overdue',
            'sale-payment-test',
            7000,
            'CUP',
            '1',
            6001,
            $timestamp,
            'cash'
          )
        '''),
        throwsA(anything),
      );

      // No debe aceptar un importe total igual a cero.
      await expectLater(
        database.customStatement('''
          INSERT INTO sale_payments (
            id,
            sale_id,
            amount_minor_units,
            currency_code,
            exchange_rate_to_base_snapshot,
            applied_amount_minor_units,
            payment_date,
            payment_method
          )
          VALUES (
            'payment-zero-amount',
            'sale-payment-test',
            0,
            'CUP',
            '1',
            1000,
            $timestamp,
            'cash'
          )
        '''),
        throwsA(anything),
      );

      // No debe aceptar un importe aplicado igual a cero.
      await expectLater(
        database.customStatement('''
          INSERT INTO sale_payments (
            id,
            sale_id,
            amount_minor_units,
            currency_code,
            exchange_rate_to_base_snapshot,
            applied_amount_minor_units,
            payment_date,
            payment_method
          )
          VALUES (
            'payment-zero-applied',
            'sale-payment-test',
            1000,
            'CUP',
            '1',
            0,
            $timestamp,
            'cash'
          )
        '''),
        throwsA(anything),
      );

      // El pago válido debe conservarse y los rechazados no deben insertarse.
      final payments = await database.customSelect('''
        SELECT id, applied_amount_minor_units
        FROM sale_payments
        WHERE sale_id = 'sale-payment-test'
      ''').get();

      expect(payments, hasLength(1));
      expect(payments.single.read<String>('id'), 'payment-valid');
      expect(payments.single.read<int>('applied_amount_minor_units'), 4000);

      // Comprueba integridad referencial.
      final foreignKeyViolations = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();

      expect(foreignKeyViolations, isEmpty);

      // Comprueba versión final.
      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(versionRow.read<int>('user_version'), 18);
    } finally {
      await database.close();
    }
  }

  test('migra correctamente de version 7 a 16', verifyMigrationFrom7To14);

  test('migra correctamente de version 9 a 16', verifyMigrationFrom9To14);

  test('migra correctamente de version 11 a 16', verifyMigrationFrom11To14);

  test('crea la estructura de ventas en una base de datos nueva', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    try {
      // Fuerza la apertura y creación del esquema.
      final tables = await database.customSelect('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
      ''').get();

      final tableNames = tables.map((row) => row.read<String>('name')).toSet();

      expect(
        tableNames,
        containsAll({'sales', 'sale_details', 'sale_payments'}),
      );

      final saleColumns = await database
          .customSelect('PRAGMA table_info(sales)')
          .get();
      final saleColumnNames = saleColumns
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(
        saleColumnNames,
        containsAll({
          'customer_id',
          'currency_code',
          'exchange_rate_to_base_snapshot',
          'payment_type',
          'status',
          'total_minor_units',
        }),
      );

      final detailColumns = await database
          .customSelect('PRAGMA table_info(sale_details)')
          .get();
      final detailColumnNames = detailColumns
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(
        detailColumnNames,
        containsAll({
          'sale_id',
          'product_id',
          'sku_snapshot',
          'quantity_milli_units',
          'unit_price_minor_units',
          'inventory_movement_id',
        }),
      );

      final paymentColumns = await database
          .customSelect('PRAGMA table_info(sale_payments)')
          .get();
      final paymentColumnNames = paymentColumns
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(
        paymentColumnNames,
        containsAll({
          'sale_id',
          'amount_minor_units',
          'currency_code',
          'exchange_rate_to_base_snapshot',
          'applied_amount_minor_units',
          'payment_date',
          'payment_method',
        }),
      );

      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(versionRow.read<int>('user_version'), 18);

      final salesTriggers = await database.customSelect('''
        SELECT name FROM sqlite_master
        WHERE type = 'trigger' AND name IN (
          'prevent_confirmed_sale_update',
          'prevent_confirmed_sale_delete',
          'validate_sale_confirmation',
          'validate_sale_cancellation',
          'validate_sale_detail_insert',
          'validate_sale_detail_update',
          'validate_sale_detail_delete',
          'validate_sale_payment_insert',
          'prevent_sale_payment_update',
          'prevent_sale_payment_delete'
        )
      ''').get();
      expect(salesTriggers, hasLength(10));

      final foreignKeyViolations = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(foreignKeyViolations, isEmpty);
    } finally {
      await database.close();
    }
  });
  test('migra ventas confirmadas de la versión 16 a la 18', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'sales_migration_test_',
    );
    final databaseFile = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}migration.sqlite',
    );

    final confirmedAt = DateTime(2026, 1, 10, 12);
    final paymentDate = DateTime(2026, 1, 10, 13);

    var database = AppDatabase.forTesting(NativeDatabase(databaseFile));

    try {
      // Prepara los datos históricos con el esquema actual.
      await database
          .into(database.currencies)
          .insert(
            CurrenciesCompanion.insert(
              code: 'CUP',
              name: 'Peso cubano',
              symbol: 'CUP',
              isBase: const Value(true),
            ),
          );

      await database
          .into(database.sales)
          .insert(
            SalesCompanion.insert(
              id: 'sale-migration-1',
              saleDate: DateTime(2026, 1, 10),
              currencyCode: 'CUP',
              exchangeRateToBaseSnapshot: '1',
              subtotalMinorUnits: 10000,
              totalMinorUnits: 10000,
              paymentType: 'cash',
              status: const Value('confirmed'),
              confirmedAt: Value(confirmedAt),
            ),
          );

      await database
          .into(database.salePayments)
          .insert(
            SalePaymentsCompanion.insert(
              id: 'payment-migration-1',
              saleId: 'sale-migration-1',
              amountMinorUnits: 2500,
              currencyCode: 'CUP',
              exchangeRateToBaseSnapshot: '1',
              appliedAmountMinorUnits: 2500,
              paymentDate: paymentDate,
              paymentMethod: 'cash',
            ),
          );

      // Simula la protección que existía en la versión 16.
      await database.customStatement('''
        DROP TRIGGER IF EXISTS validate_sale_cancellation
      ''');

      await database.customStatement('''
        DROP TRIGGER IF EXISTS prevent_confirmed_sale_update
      ''');

      await database.customStatement('''
        CREATE TRIGGER prevent_confirmed_sale_update
        BEFORE UPDATE ON sales
        WHEN OLD.status <> 'draft'
        BEGIN
          SELECT RAISE(
            ABORT,
            'Solo se pueden modificar ventas en borrador'
          );
        END
      ''');

      await database.customStatement('PRAGMA user_version = 16');

      await database.close();

      // Reabre el archivo: Drift debe ejecutar la migración 16 -> 17.
      database = AppDatabase.forTesting(NativeDatabase(databaseFile));

      final versionRow = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(versionRow.read<int>('user_version'), 18);

      // Comprueba que la venta y el pago históricos siguen intactos.
      final sale = await (database.select(
        database.sales,
      )..where((row) => row.id.equals('sale-migration-1'))).getSingle();

      expect(sale.status, 'confirmed');
      expect(sale.confirmedAt, confirmedAt);
      expect(sale.totalMinorUnits, 10000);
      expect(sale.cancelledAt, isNull);
      expect(sale.cancellationReason, isNull);

      final payment = await (database.select(
        database.salePayments,
      )..where((row) => row.id.equals('payment-migration-1'))).getSingle();

      expect(payment.saleId, 'sale-migration-1');
      expect(payment.amountMinorUnits, 2500);
      expect(payment.appliedAmountMinorUnits, 2500);

      // La versión 17 permite la cancelación controlada.
      await (database.update(
        database.sales,
      )..where((row) => row.id.equals('sale-migration-1'))).write(
        SalesCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(DateTime(2026, 1, 11, 10)),
          cancellationReason: const Value('Cancelación de prueba'),
        ),
      );

      final cancelledSale = await (database.select(
        database.sales,
      )..where((row) => row.id.equals('sale-migration-1'))).getSingle();

      expect(cancelledSale.status, 'cancelled');
      expect(cancelledSale.cancellationReason, 'Cancelación de prueba');
      expect(cancelledSale.totalMinorUnits, 10000);

      // No permite una segunda cancelación.
      await expectLater(
        (database.update(
          database.sales,
        )..where((row) => row.id.equals('sale-migration-1'))).write(
          SalesCompanion(
            status: const Value('cancelled'),
            cancelledAt: Value(DateTime(2026, 1, 12)),
            cancellationReason: const Value('Segundo intento'),
          ),
        ),
        throwsA(anything),
      );

      // No permite modificar el historial de una venta cancelada.
      await expectLater(
        (database.update(database.sales)
              ..where((row) => row.id.equals('sale-migration-1')))
            .write(const SalesCompanion(totalMinorUnits: Value(9000))),
        throwsA(anything),
      );

      // No permite registrar nuevos pagos después de cancelar.
      await expectLater(
        database
            .into(database.salePayments)
            .insert(
              SalePaymentsCompanion.insert(
                id: 'payment-migration-2',
                saleId: 'sale-migration-1',
                amountMinorUnits: 1000,
                currencyCode: 'CUP',
                exchangeRateToBaseSnapshot: '1',
                appliedAmountMinorUnits: 1000,
                paymentDate: DateTime(2026, 1, 12),
                paymentMethod: 'cash',
              ),
            ),
        throwsA(anything),
      );

      // Los pagos históricos siguen siendo inmutables.
      await expectLater(
        (database.update(database.salePayments)
              ..where((row) => row.id.equals('payment-migration-1')))
            .write(const SalePaymentsCompanion(amountMinorUnits: Value(3000))),
        throwsA(anything),
      );

      await expectLater(
        (database.delete(
          database.salePayments,
        )..where((row) => row.id.equals('payment-migration-1'))).go(),
        throwsA(anything),
      );

      final remainingPayments = await database
          .select(database.salePayments)
          .get();

      expect(remainingPayments, hasLength(1));
      expect(remainingPayments.single.amountMinorUnits, 2500);
    } finally {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'instala la protección de vínculos de recepción al migrar de 17 a 18',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'receipt_inventory_link_migration_test_',
      );
      final databaseFile = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}migration.sqlite',
      );

      var database = AppDatabase.forTesting(NativeDatabase(databaseFile));

      try {
        await database.customStatement('''
        DROP TRIGGER IF EXISTS
        validate_purchase_receipt_detail_inventory_link
      ''');

        await database.customStatement('PRAGMA user_version = 17');
        await database.close();

        database = AppDatabase.forTesting(NativeDatabase(databaseFile));

        final versionRow = await database
            .customSelect('PRAGMA user_version')
            .getSingle();

        expect(versionRow.read<int>('user_version'), 18);

        final trigger = await database.customSelect('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'trigger'
          AND name = 'validate_purchase_receipt_detail_inventory_link'
      ''').get();

        expect(trigger, hasLength(1));
        expect(
          trigger.single.read<String>('name'),
          'validate_purchase_receipt_detail_inventory_link',
        );
      } finally {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );
}
