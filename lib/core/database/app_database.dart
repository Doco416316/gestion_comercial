import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ============================================================
// MONEDAS
// ============================================================

class Currencies extends Table {
  TextColumn get code => text().withLength(min: 3, max: 3)();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  TextColumn get symbol => text().withLength(min: 1, max: 8)();

  IntColumn get decimalDigits => integer().withDefault(const Constant(2))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  BoolColumn get isBase => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {code};
}

// ============================================================
// PRODUCTOS
// ============================================================

class Products extends Table {
  TextColumn get id => text()();

  TextColumn get sku => text().withLength(min: 1, max: 40).unique()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  TextColumn get category => text().nullable()();

  TextColumn get unit => text().withDefault(const Constant('unidad'))();

  BoolColumn get trackInventory =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PRECIOS DE PRODUCTOS
// ============================================================

class ProductPrices extends Table {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();

  TextColumn get currencyCode => text().references(Currencies, #code)();

  IntColumn get amountMinorUnits => integer()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productId, currencyCode};
}

// ============================================================
// MOVIMIENTOS DE INVENTARIO
// ============================================================

class InventoryMovements extends Table {
  TextColumn get id => text()();

  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();

  TextColumn get movementType => text().withLength(min: 1, max: 30)();

  IntColumn get quantityMilliUnits => integer()();

  TextColumn get reason => text().withLength(min: 1, max: 250)();

  TextColumn get reference => text().nullable()();

  TextColumn get correctionOfId => text().nullable().references(
    InventoryMovements,
    #id,
    onDelete: KeyAction.restrict,
  )();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SALDOS DE INVENTARIO
// ============================================================

class InventoryBalances extends Table {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();

  IntColumn get quantityMilliUnits =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productId};
}

// ============================================================
// PROVEEDORES
// ============================================================

class Suppliers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 150)();

  TextColumn get taxId => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get notes => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// HISTORIAL DE TASAS DE CAMBIO
// ============================================================

/// Las tasas se expresan respecto a la moneda base.
///
/// Ejemplo:
/// Moneda base CUP:
/// USD = 400
/// EUR = 450
/// CUP = 1
///
/// rateToBase se almacena como texto decimal para evitar double.
/// Las tasas históricas no se sobrescriben.
class ExchangeRates extends Table {
  TextColumn get id => text()();

  TextColumn get currencyCode => text().references(Currencies, #code)();

  TextColumn get rateToBase => text()();

  DateTimeColumn get effectiveAt => dateTime()();

  TextColumn get createdByUserId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// COMPRAS
// ============================================================

class Purchases extends Table {
  TextColumn get id => text()();

  TextColumn get supplierId =>
      text().references(Suppliers, #id, onDelete: KeyAction.restrict)();

  TextColumn get documentNumber => text().nullable()();

  DateTimeColumn get purchaseDate => dateTime()();

  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// En borradores es provisional.
  /// Al confirmar, se sustituye por el snapshot histórico definitivo.
  TextColumn get exchangeRateToBaseSnapshot => text()();

  IntColumn get subtotalMinorUnits => integer()();

  IntColumn get discountMinorUnits =>
      integer().withDefault(const Constant(0))();

  IntColumn get taxMinorUnits => integer().withDefault(const Constant(0))();

  IntColumn get totalMinorUnits => integer()();

  TextColumn get notes => text().nullable()();

  /// Estados permitidos: draft, confirmed, cancelled.
  TextColumn get status => text().withDefault(const Constant('draft'))();

  DateTimeColumn get confirmedAt => dateTime().nullable()();

  DateTimeColumn get cancelledAt => dateTime().nullable()();

  TextColumn get cancellationReason => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// DETALLES DE COMPRAS
// ============================================================

class PurchaseDetails extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseId =>
      text().references(Purchases, #id, onDelete: KeyAction.restrict)();

  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();

  /// Datos históricos del producto al registrar la compra.
  TextColumn get skuSnapshot => text()();

  TextColumn get productNameSnapshot => text()();

  TextColumn get unitSnapshot => text()();

  IntColumn get quantityMilliUnits => integer()();

  IntColumn get unitCostMinorUnits => integer()();

  IntColumn get discountMinorUnits =>
      integer().withDefault(const Constant(0))();

  /// Forma en que se calculó el descuento.
  /// Valores permitidos: fixed, percentage.
  TextColumn get discountType => text().withDefault(const Constant('fixed'))();

  /// Porcentaje original del descuento, almacenado como decimal textual.
  /// Nulo cuando el descuento fue fijo.
  TextColumn get discountRate => text().nullable()();

  IntColumn get taxMinorUnits => integer().withDefault(const Constant(0))();

  /// Forma en que se calculó el impuesto.
  /// Valores permitidos: fixed, percentage.
  TextColumn get taxType => text().withDefault(const Constant('fixed'))();

  /// Porcentaje original del impuesto, almacenado como decimal textual.
  /// Nulo cuando el impuesto fue fijo.
  TextColumn get taxRate => text().nullable()();

  IntColumn get totalMinorUnits => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RECEPCIONES DE COMPRAS
// ============================================================

class PurchaseReceipts extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseId =>
      text().references(Purchases, #id, onDelete: KeyAction.restrict)();

  DateTimeColumn get receivedAt => dateTime()();

  TextColumn get reference => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// DETALLES DE RECEPCIONES
// ============================================================

class PurchaseReceiptDetails extends Table {
  TextColumn get id => text()();

  TextColumn get receiptId =>
      text().references(PurchaseReceipts, #id, onDelete: KeyAction.restrict)();

  TextColumn get purchaseDetailId =>
      text().references(PurchaseDetails, #id, onDelete: KeyAction.restrict)();

  IntColumn get quantityMilliUnits => integer()();

  /// Nulo cuando el producto no controla inventario.
  TextColumn get inventoryMovementId => text().nullable().references(
    InventoryMovements,
    #id,
    onDelete: KeyAction.restrict,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PAGOS A PROVEEDORES
// ============================================================

class SupplierPayments extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseId =>
      text().references(Purchases, #id, onDelete: KeyAction.restrict)();

  /// Importe realmente entregado al proveedor.
  IntColumn get amountMinorUnits => integer()();

  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// Tasa histórica de la moneda del pago respecto a la moneda base.
  TextColumn get exchangeRateToBaseSnapshot => text()();

  /// Equivalente aplicado a la deuda, en moneda de la compra.
  IntColumn get appliedAmountMinorUnits => integer()();

  DateTimeColumn get paymentDate => dateTime()();

  TextColumn get paymentMethod => text().withLength(min: 1, max: 40)();

  TextColumn get reference => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// BASE DE DATOS
// ============================================================

@DriftDatabase(
  tables: [
    Currencies,
    Products,
    ProductPrices,
    InventoryMovements,
    InventoryBalances,
    Suppliers,
    ExchangeRates,
    Purchases,
    PurchaseDetails,
    PurchaseReceipts,
    PurchaseReceiptDetails,
    SupplierPayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  static const List<String> _increasingTypes = [
    'entry',
    'positive_adjustment',
    'customer_return',
  ];

  static const List<String> _decreasingTypes = [
    'exit',
    'negative_adjustment',
    'supplier_return',
  ];

  static const List<String> _validMovementTypes = [
    ..._increasingTypes,
    ..._decreasingTypes,
  ];

  static final BigInt _maxSqliteInteger = BigInt.parse('9223372036854775807');

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      await customStatement('''
        CREATE UNIQUE INDEX IF NOT EXISTS unique_base_currency
        ON currencies (is_base)
        WHERE is_base = 1
      ''');

      await _createInventoryProtection();
      await _createInventoryBalanceTriggers();
      await _createPurchaseIndexes();
      await _createFinancialHistoryProtection();
      await _createPurchaseLifecycleProtection();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(currencies, currencies.decimalDigits);
        await m.createTable(products);
        await m.createTable(productPrices);

        await customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS unique_base_currency
          ON currencies (is_base)
          WHERE is_base = 1
        ''');
      }

      if (from < 3) {
        await m.createTable(inventoryMovements);
      }

      if (from < 4) {
        await _createInventoryProtection();
      } else if (from < 5) {
        await _createCorrectionChainProtection();
      }

      if (from < 6) {
        await m.createTable(inventoryBalances);
        await _rebuildInventoryBalances();
      }

      // Versión 7: recreación de triggers para corregir
      // el formato de las fechas almacenadas en updated_at.
      if (from < 7) {
        await _createInventoryBalanceTriggers();
      }

      // Versión 8: proveedores, compras, recepciones,
      // pagos a proveedores e historial de tasas.
      if (from < 8) {
        await m.createTable(suppliers);
        await m.createTable(exchangeRates);
        await m.createTable(purchases);
        await m.createTable(purchaseDetails);
        await m.createTable(purchaseReceipts);
        await m.createTable(purchaseReceiptDetails);
        await m.createTable(supplierPayments);

        await _createPurchaseIndexes();
      }

      if (from < 9 && to >= 9) {
        await _createFinancialHistoryProtection();
      }

      // Versión 10: conservar el tipo y porcentaje original
      // de descuentos e impuestos de cada detalle de compra.
      //
      // Las bases anteriores a v8 crean purchase_details durante
      // esta misma migración utilizando el esquema actual de Drift.
      // Por eso solamente agregamos las columnas cuando la tabla
      // ya existía antes de comenzar la migración v10.
      if (from >= 8 && from < 10 && to >= 10) {
        await m.addColumn(purchaseDetails, purchaseDetails.discountType);
        await m.addColumn(purchaseDetails, purchaseDetails.discountRate);
        await m.addColumn(purchaseDetails, purchaseDetails.taxType);
        await m.addColumn(purchaseDetails, purchaseDetails.taxRate);
      }

      // Versión 11: ciclo de vida de las compras.
      //
      // Las compras que ya existían antes de esta migración
      // son operaciones históricas y deben conservarse como
      // confirmadas, nunca como borradores.
      //
      // Para bases anteriores a v8, las tablas financieras
      // se crean durante esta misma migración con el esquema
      // actual. En esos casos no hay compras históricas que
      // deban actualizarse.
      if (from >= 8 && from < 11 && to >= 11) {
        await m.addColumn(purchases, purchases.status);
        await m.addColumn(purchases, purchases.confirmedAt);
        await m.addColumn(purchases, purchases.cancelledAt);
        await m.addColumn(purchases, purchases.cancellationReason);

        await customStatement('''
          UPDATE purchases
          SET
            status = 'confirmed',
            confirmed_at = created_at
        ''');
      }

      if (to >= 11) {
        await _createPurchaseLifecycleProtection();
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'gestion_comercial');
  }

  // ==========================================================
  // ÍNDICES DE COMPRAS Y PROVEEDORES
  // ==========================================================

  Future<void> _createPurchaseIndexes() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS
      unique_exchange_rate_currency_effective_at
      ON exchange_rates (currency_code, effective_at)
    ''');

    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS
      unique_supplier_purchase_document
      ON purchases (supplier_id, document_number)
      WHERE document_number IS NOT NULL
        AND length(trim(document_number)) > 0
    ''');

    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS
      unique_purchase_receipt_inventory_movement
      ON purchase_receipt_details (inventory_movement_id)
      WHERE inventory_movement_id IS NOT NULL
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_purchases_supplier
      ON purchases (supplier_id, purchase_date)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_purchase_details_purchase
      ON purchase_details (purchase_id)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_purchase_details_product
      ON purchase_details (product_id)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_purchase_receipts_purchase
      ON purchase_receipts (purchase_id, received_at)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_receipt_details_purchase_detail
      ON purchase_receipt_details (purchase_detail_id)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS
      idx_supplier_payments_purchase
      ON supplier_payments (purchase_id, payment_date)
    ''');
  }

  /// Protege la moneda base y la inmutabilidad de las tasas históricas.
  ///
  /// Estas reglas se aplican directamente en SQLite para que no
  /// dependan exclusivamente de los repositorios.

  Future<void> _createFinancialHistoryProtection() async {
    // Comprobar qué tablas existen realmente en la base de datos.
    final rows = await customSelect('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
  ''').get();

    final existingTables = rows.map((row) => row.read<String>('name')).toSet();

    // Si la base de datos todavía no tiene todas las tablas financieras,
    // no se deben instalar estos triggers.
    const requiredTables = {
      'currencies',
      'exchange_rates',
      'purchases',
      'supplier_payments',
    };

    if (!existingTables.containsAll(requiredTables)) {
      return;
    }

    // Impedir cambiar la moneda base cuando ya existe historial financiero.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_base_currency_change_after_history
    BEFORE UPDATE OF is_base ON currencies
    WHEN OLD.is_base = 1
      AND NEW.is_base = 0
      AND (
        EXISTS (SELECT 1 FROM exchange_rates)
        OR EXISTS (SELECT 1 FROM purchases)
        OR EXISTS (SELECT 1 FROM supplier_payments)
      )
    BEGIN
      SELECT RAISE(
        ABORT,
        'No se puede cambiar la moneda base después de registrar operaciones financieras'
      );
    END
  ''');

    // La moneda base siempre debe estar activa.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_inactive_currency_as_base
    BEFORE UPDATE OF is_base ON currencies
    WHEN NEW.is_base = 1
      AND NEW.is_active = 0
    BEGIN
      SELECT RAISE(
        ABORT,
        'La moneda base debe estar activa'
      );
    END
  ''');

    // Impedir desactivar la moneda base.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_base_currency_deactivation
    BEFORE UPDATE OF is_active ON currencies
    WHEN OLD.is_base = 1
      AND NEW.is_active = 0
    BEGIN
      SELECT RAISE(
        ABORT,
        'No se puede desactivar la moneda base'
      );
    END
  ''');

    // Las tasas históricas no pueden modificarse.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_exchange_rate_update
    BEFORE UPDATE ON exchange_rates
    BEGIN
      SELECT RAISE(
        ABORT,
        'Las tasas históricas son inmutables'
      );
    END
  ''');

    // Las tasas históricas no pueden eliminarse.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_exchange_rate_delete
    BEFORE DELETE ON exchange_rates
    BEGIN
      SELECT RAISE(
        ABORT,
        'Las tasas históricas no se pueden eliminar'
      );
    END
  ''');

    // La moneda base tiene una tasa fija de 1.
    await customStatement('''
    CREATE TRIGGER IF NOT EXISTS
    prevent_exchange_rate_for_base_currency
    BEFORE INSERT ON exchange_rates
    WHEN EXISTS (
      SELECT 1
      FROM currencies
      WHERE code = NEW.currency_code
        AND is_base = 1
    )
    BEGIN
      SELECT RAISE(
        ABORT,
        'La moneda base tiene una tasa fija de 1'
      );
    END
  ''');
  }

  // ==========================================================
  // PROTECCIÓN DEL CICLO DE VIDA DE COMPRAS
  // ==========================================================

  Future<void> _createPurchaseLifecycleProtection() async {
    // Solo se pueden crear compras nuevas como borradores.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_insert
      BEFORE INSERT ON purchases
      BEGIN
        SELECT RAISE(
          ABORT,
          'Una compra nueva debe comenzar como borrador'
        )
        WHERE NEW.status <> 'draft';

        SELECT RAISE(
          ABORT,
          'Un borrador no puede tener fecha de confirmación o anulación'
        )
        WHERE NEW.confirmed_at IS NOT NULL
          OR NEW.cancelled_at IS NOT NULL
          OR NEW.cancellation_reason IS NOT NULL;
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_status_update
      BEFORE UPDATE OF status ON purchases
      BEGIN
        SELECT RAISE(
          ABORT,
          'Estado de compra no válido'
        )
        WHERE NEW.status NOT IN (
          'draft',
          'confirmed',
          'cancelled'
        );

        SELECT RAISE(
          ABORT,
          'Un borrador solo puede permanecer como borrador o confirmarse'
        )
        WHERE OLD.status = 'draft'
          AND NEW.status NOT IN ('draft', 'confirmed');

        SELECT RAISE(
          ABORT,
          'Una compra anulada no puede cambiar de estado'
        )
        WHERE OLD.status = 'cancelled';
      END
    ''');

    // Una compra confirmada solo puede pasar a cancelada,
    // y únicamente si todavía no tiene pagos ni recepciones.
    //
    // Los demás datos de la compra confirmada son inmutables.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      protect_purchase_update
      BEFORE UPDATE ON purchases
      WHEN OLD.status <> 'draft'
      BEGIN
        SELECT RAISE(
          ABORT,
          'Una compra confirmada no puede modificarse'
        )
        WHERE NOT (
          OLD.status = 'confirmed'
          AND NEW.status = 'cancelled'

          AND NEW.id IS OLD.id
          AND NEW.supplier_id IS OLD.supplier_id
          AND NEW.document_number IS OLD.document_number
          AND NEW.purchase_date IS OLD.purchase_date
          AND NEW.currency_code IS OLD.currency_code
          AND NEW.exchange_rate_to_base_snapshot
              IS OLD.exchange_rate_to_base_snapshot
          AND NEW.subtotal_minor_units IS OLD.subtotal_minor_units
          AND NEW.discount_minor_units IS OLD.discount_minor_units
          AND NEW.tax_minor_units IS OLD.tax_minor_units
          AND NEW.total_minor_units IS OLD.total_minor_units
          AND NEW.notes IS OLD.notes
          AND NEW.confirmed_at IS OLD.confirmed_at
          AND NEW.created_at IS OLD.created_at
        );

        SELECT RAISE(
          ABORT,
          'El motivo de anulación es obligatorio'
        )
        WHERE NEW.status = 'cancelled'
          AND (
            NEW.cancelled_at IS NULL
            OR NEW.cancellation_reason IS NULL
            OR length(trim(NEW.cancellation_reason)) = 0
          );

        SELECT RAISE(
          ABORT,
          'No se puede anular una compra con pagos registrados'
        )
        WHERE NEW.status = 'cancelled'
          AND EXISTS (
            SELECT 1
            FROM supplier_payments
            WHERE purchase_id = OLD.id
          );

        SELECT RAISE(
          ABORT,
          'No se puede anular una compra con recepciones registradas'
        )
        WHERE NEW.status = 'cancelled'
          AND EXISTS (
            SELECT 1
            FROM purchase_receipts
            WHERE purchase_id = OLD.id
          );
      END
    ''');

    // No se pueden borrar compras confirmadas ni anuladas.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_non_draft_purchase_delete
      BEFORE DELETE ON purchases
      WHEN OLD.status <> 'draft'
      BEGIN
        SELECT RAISE(
          ABORT,
          'Solo se pueden eliminar compras en borrador'
        );
      END
    ''');

    // Solo se pueden agregar, modificar o quitar detalles
    // mientras la compra correspondiente sea un borrador.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_detail_insert
      BEFORE INSERT ON purchase_details
      WHEN NOT EXISTS (
        SELECT 1
        FROM purchases
        WHERE id = NEW.purchase_id
          AND status = 'draft'
      )
      BEGIN
        SELECT RAISE(
          ABORT,
          'Solo se pueden agregar detalles a compras en borrador'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_detail_update
      BEFORE UPDATE ON purchase_details
      WHEN NOT EXISTS (
        SELECT 1
        FROM purchases
        WHERE id = OLD.purchase_id
          AND status = 'draft'
      )
      OR NOT EXISTS (
        SELECT 1
        FROM purchases
        WHERE id = NEW.purchase_id
          AND status = 'draft'
      )
      BEGIN
        SELECT RAISE(
          ABORT,
          'Solo se pueden modificar detalles de compras en borrador'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_detail_delete
      BEFORE DELETE ON purchase_details
      WHEN NOT EXISTS (
        SELECT 1
        FROM purchases
        WHERE id = OLD.purchase_id
          AND status = 'draft'
      )
      BEGIN
        SELECT RAISE(
          ABORT,
          'Solo se pueden eliminar detalles de compras en borrador'
        );
      END
    ''');

    // Una compra solo puede confirmarse si tiene al menos
    // un detalle y una fecha de confirmación.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_confirmation
      BEFORE UPDATE OF status ON purchases
      WHEN OLD.status = 'draft'
        AND NEW.status = 'confirmed'
      BEGIN
        SELECT RAISE(
          ABORT,
          'La fecha de confirmación es obligatoria'
        )
        WHERE NEW.confirmed_at IS NULL;

        SELECT RAISE(
          ABORT,
          'No se puede confirmar una compra sin detalles'
        )
        WHERE NOT EXISTS (
          SELECT 1
          FROM purchase_details
          WHERE purchase_id = NEW.id
        );
      END
    ''');

    // Solo se pueden registrar recepciones de compras confirmadas.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_receipt_insert
      BEFORE INSERT ON purchase_receipts
      WHEN NOT EXISTS (
        SELECT 1
        FROM purchases
        WHERE id = NEW.purchase_id
          AND status = 'confirmed'
      )
      BEGIN
        SELECT RAISE(
          ABORT,
          'Solo se pueden recibir compras confirmadas'
        );
      END
    ''');

    // Las recepciones registradas son históricas e inmutables.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_purchase_receipt_update
      BEFORE UPDATE ON purchase_receipts
      BEGIN
        SELECT RAISE(
          ABORT,
          'Las recepciones registradas son inmutables'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_purchase_receipt_delete
      BEFORE DELETE ON purchase_receipts
      BEGIN
        SELECT RAISE(
          ABORT,
          'Las recepciones registradas no se pueden eliminar'
        );
      END
    ''');

    // Solo se pueden agregar detalles a recepciones de compras
    // confirmadas y deben corresponder a detalles de esa compra.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_purchase_receipt_detail_insert
      BEFORE INSERT ON purchase_receipt_details
      BEGIN
        SELECT RAISE(
          ABORT,
          'La cantidad recibida debe ser mayor que cero'
        )
        WHERE typeof(NEW.quantity_milli_units) <> 'integer'
          OR NEW.quantity_milli_units <= 0;

        SELECT RAISE(
          ABORT,
          'El detalle no pertenece a la compra de la recepción'
        )
        WHERE NOT EXISTS (
          SELECT 1
          FROM purchase_receipts r
          JOIN purchase_details d
            ON d.id = NEW.purchase_detail_id
          WHERE r.id = NEW.receipt_id
            AND r.purchase_id = d.purchase_id
        );

        SELECT RAISE(
          ABORT,
          'La cantidad recibida supera la cantidad comprada'
        )
        WHERE NEW.quantity_milli_units > (
          SELECT d.quantity_milli_units
            - COALESCE((
                SELECT SUM(existing.quantity_milli_units)
                FROM purchase_receipt_details existing
                JOIN purchase_receipts existing_receipt
                  ON existing_receipt.id = existing.receipt_id
                WHERE existing_receipt.purchase_id = d.purchase_id
                  AND existing.purchase_detail_id = d.id
              ), 0)
          FROM purchase_details d
          WHERE d.id = NEW.purchase_detail_id
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_purchase_receipt_detail_update
      BEFORE UPDATE ON purchase_receipt_details
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los detalles de recepción son inmutables'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_purchase_receipt_detail_delete
      BEFORE DELETE ON purchase_receipt_details
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los detalles de recepción no se pueden eliminar'
        );
      END
    ''');

    // Los pagos solo pueden registrarse en compras confirmadas.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      validate_supplier_payment_insert
      BEFORE INSERT ON supplier_payments
      BEGIN
        SELECT RAISE(
          ABORT,
          'El importe del pago debe ser mayor que cero'
        )
        WHERE typeof(NEW.amount_minor_units) <> 'integer'
          OR NEW.amount_minor_units <= 0
          OR typeof(NEW.applied_amount_minor_units) <> 'integer'
          OR NEW.applied_amount_minor_units <= 0;

        SELECT RAISE(
          ABORT,
          'Solo se pueden pagar compras confirmadas'
        )
        WHERE NOT EXISTS (
          SELECT 1
          FROM purchases
          WHERE id = NEW.purchase_id
            AND status = 'confirmed'
        );

        SELECT RAISE(
          ABORT,
          'El pago supera el saldo pendiente de la compra'
        )
        WHERE NEW.applied_amount_minor_units > (
          SELECT p.total_minor_units
            - COALESCE((
                SELECT SUM(sp.applied_amount_minor_units)
                FROM supplier_payments sp
                WHERE sp.purchase_id = p.id
              ), 0)
          FROM purchases p
          WHERE p.id = NEW.purchase_id
        );
      END
    ''');

    // Los pagos son registros financieros inmutables.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_supplier_payment_update
      BEFORE UPDATE ON supplier_payments
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los pagos registrados son inmutables'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_supplier_payment_delete
      BEFORE DELETE ON supplier_payments
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los pagos registrados no se pueden eliminar'
        );
      END
    ''');
  }

  // ==========================================================
  // PROTECCIONES DE INVENTARIO
  // ==========================================================

  Future<void> _createInventoryProtection() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS
      unique_inventory_movement_correction
      ON inventory_movements (correction_of_id)
      WHERE correction_of_id IS NOT NULL
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_inventory_movement_update
      BEFORE UPDATE ON inventory_movements
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los movimientos de inventario son inmutables'
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_inventory_movement_delete
      BEFORE DELETE ON inventory_movements
      BEGIN
        SELECT RAISE(
          ABORT,
          'Los movimientos de inventario no se pueden eliminar'
        );
      END
    ''');

    await _createCorrectionChainProtection();
  }

  Future<void> _createCorrectionChainProtection() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS
      prevent_correction_of_correction
      BEFORE INSERT ON inventory_movements
      WHEN NEW.correction_of_id IS NOT NULL
        AND EXISTS (
          SELECT 1
          FROM inventory_movements
          WHERE id = NEW.correction_of_id
            AND correction_of_id IS NOT NULL
        )
      BEGIN
        SELECT RAISE(
          ABORT,
          'No se puede corregir un movimiento compensatorio'
        );
      END
    ''');
  }

  // ==========================================================
  // RECONSTRUCCIÓN DE SALDOS
  // ==========================================================

  /// Reconstruye los saldos históricos utilizando BigInt para evitar
  /// desbordamientos durante la migración.
  Future<void> _rebuildInventoryBalances() async {
    final existingProducts = await select(products).get();
    final movements = await select(inventoryMovements).get();

    final productIds = existingProducts.map((p) => p.id).toSet();
    final balances = <String, BigInt>{};

    for (final movement in movements) {
      if (!_validMovementTypes.contains(movement.movementType)) {
        throw StateError(
          'No se puede migrar: tipo de movimiento desconocido '
          '(${movement.movementType}).',
        );
      }

      if (movement.quantityMilliUnits <= 0) {
        throw StateError(
          'No se puede migrar: existe una cantidad de movimiento inválida.',
        );
      }

      if (movement.reason.trim().isEmpty) {
        throw StateError(
          'No se puede migrar: existe un movimiento sin motivo.',
        );
      }

      if (!productIds.contains(movement.productId)) {
        throw StateError(
          'No se puede migrar: existe un movimiento '
          'sin producto asociado.',
        );
      }

      final quantity = BigInt.from(movement.quantityMilliUnits);
      final current = balances[movement.productId] ?? BigInt.zero;

      final increasesStock = _increasingTypes.contains(movement.movementType);

      balances[movement.productId] = increasesStock
          ? current + quantity
          : current - quantity;
    }

    for (final product in existingProducts) {
      final balance = balances[product.id] ?? BigInt.zero;

      if (balance < BigInt.zero) {
        throw StateError(
          'No se puede migrar: el producto ${product.id} '
          'terminaría con inventario negativo.',
        );
      }

      if (balance > _maxSqliteInteger) {
        throw StateError(
          'No se puede migrar: el saldo del producto ${product.id} '
          'supera el límite de SQLite.',
        );
      }

      await into(inventoryBalances).insert(
        InventoryBalancesCompanion.insert(
          productId: product.id,
          quantityMilliUnits: Value(balance.toInt()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ==========================================================
  // TRIGGERS DE INVENTARIO
  // ==========================================================

  /// Crea los triggers que mantienen sincronizados los saldos.
  ///
  /// Se eliminan antes de crearlos para garantizar que las bases de datos
  /// existentes reciban las definiciones actualizadas.
  Future<void> _createInventoryBalanceTriggers() async {
    await customStatement(
      'DROP TRIGGER IF EXISTS initialize_inventory_balance',
    );

    await customStatement('DROP TRIGGER IF EXISTS restore_inventory_balance');

    await customStatement(
      'DROP TRIGGER IF EXISTS validate_inventory_movement_insert',
    );

    await customStatement(
      'DROP TRIGGER IF EXISTS apply_inventory_movement_to_balance',
    );

    // Crea un saldo inicial cuando se registra un producto con inventario.
    await customStatement('''
      CREATE TRIGGER initialize_inventory_balance
      AFTER INSERT ON products
      WHEN NEW.track_inventory = 1
      BEGIN
        INSERT OR IGNORE INTO inventory_balances (
          product_id,
          quantity_milli_units,
          updated_at
        )
        VALUES (
          NEW.id,
          0,
          CAST(strftime('%s', 'now') AS INTEGER) * 1000
        );
      END
    ''');

    // Si se activa el control de inventario posteriormente, crea el saldo.
    await customStatement('''
      CREATE TRIGGER restore_inventory_balance
      AFTER UPDATE OF track_inventory ON products
      WHEN NEW.track_inventory = 1
      BEGIN
        INSERT OR IGNORE INTO inventory_balances (
          product_id,
          quantity_milli_units,
          updated_at
        )
        VALUES (
          NEW.id,
          0,
          CAST(strftime('%s', 'now') AS INTEGER) * 1000
        );
      END
    ''');

    // Validaciones obligatorias antes de insertar cualquier movimiento.
    await customStatement('''
      CREATE TRIGGER validate_inventory_movement_insert
      BEFORE INSERT ON inventory_movements
      BEGIN
        SELECT RAISE(
          ABORT,
          'La cantidad debe ser un entero mayor que cero'
        )
        WHERE
          typeof(NEW.quantity_milli_units) <> 'integer'
          OR NEW.quantity_milli_units <= 0;

        SELECT RAISE(
          ABORT,
          'Tipo de movimiento no válido'
        )
        WHERE NEW.movement_type NOT IN (
          'entry',
          'exit',
          'positive_adjustment',
          'negative_adjustment',
          'customer_return',
          'supplier_return'
        );

        SELECT RAISE(
          ABORT,
          'El motivo del movimiento es obligatorio'
        )
        WHERE
          length(trim(NEW.reason)) NOT BETWEEN 1 AND 250;

        SELECT RAISE(
          ABORT,
          'El producto no existe, está inactivo o no controla inventario'
        )
        WHERE NEW.correction_of_id IS NULL
          AND NOT EXISTS (
            SELECT 1
            FROM products
            WHERE id = NEW.product_id
              AND is_active = 1
              AND track_inventory = 1
          );

        SELECT RAISE(
          ABORT,
          'El producto asociado a la corrección no existe'
        )
        WHERE NEW.correction_of_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM products
            WHERE id = NEW.product_id
          );

        SELECT RAISE(
          ABORT,
          'La corrección no coincide con el movimiento original'
        )
        WHERE NEW.correction_of_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM inventory_movements original
            WHERE original.id = NEW.correction_of_id
              AND original.product_id = NEW.product_id
              AND original.correction_of_id IS NULL
              AND original.quantity_milli_units =
                  NEW.quantity_milli_units
              AND (
                (original.movement_type = 'entry'
                  AND NEW.movement_type = 'exit')
                OR
                (original.movement_type = 'exit'
                  AND NEW.movement_type = 'entry')
                OR
                (original.movement_type = 'positive_adjustment'
                  AND NEW.movement_type = 'negative_adjustment')
                OR
                (original.movement_type = 'negative_adjustment'
                  AND NEW.movement_type = 'positive_adjustment')
                OR
                (original.movement_type = 'customer_return'
                  AND NEW.movement_type = 'supplier_return')
                OR
                (original.movement_type = 'supplier_return'
                  AND NEW.movement_type = 'customer_return')
              )
          );

        SELECT RAISE(
          ABORT,
          'No hay existencias suficientes'
        )
        WHERE NEW.movement_type IN (
          'exit',
          'negative_adjustment',
          'supplier_return'
        )
        AND COALESCE(
          (
            SELECT quantity_milli_units
            FROM inventory_balances
            WHERE product_id = NEW.product_id
          ),
          0
        ) < NEW.quantity_milli_units;

        SELECT RAISE(
          ABORT,
          'El saldo de inventario supera el límite permitido'
        )
        WHERE NEW.movement_type IN (
          'entry',
          'positive_adjustment',
          'customer_return'
        )
        AND COALESCE(
          (
            SELECT quantity_milli_units
            FROM inventory_balances
            WHERE product_id = NEW.product_id
          ),
          0
        ) > 9223372036854775807 - NEW.quantity_milli_units;
      END
    ''');

    // Actualiza el saldo en la misma operación que registra el movimiento.
    await customStatement('''
      CREATE TRIGGER apply_inventory_movement_to_balance
      AFTER INSERT ON inventory_movements
      BEGIN
        INSERT INTO inventory_balances (
          product_id,
          quantity_milli_units,
          updated_at
        )
        VALUES (
          NEW.product_id,
          CASE
            WHEN NEW.movement_type IN (
              'entry',
              'positive_adjustment',
              'customer_return'
            )
            THEN NEW.quantity_milli_units
            ELSE -NEW.quantity_milli_units
          END,
          CAST(strftime('%s', 'now') AS INTEGER) * 1000
        )
        ON CONFLICT(product_id)
        DO UPDATE SET
          quantity_milli_units =
            inventory_balances.quantity_milli_units
            + excluded.quantity_milli_units,
          updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000;
      END
    ''');
  }
}
