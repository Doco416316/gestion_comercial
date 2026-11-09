import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

/// Una línea que se recibirá de una compra.
class PurchaseReceiptLineInput {
  const PurchaseReceiptLineInput({
    required this.purchaseDetailId,
    required this.quantityMilliUnits,
  });

  final String purchaseDetailId;
  final int quantityMilliUnits;
}

/// Gestiona las recepciones parciales y completas de compras.
///
/// Cada recepción y sus movimientos de inventario se registran
/// dentro de una única transacción.
///
/// Los movimientos de inventario son insertados antes de los
/// detalles de recepción para respetar la inmutabilidad de estos.
class PurchaseReceiptRepository {
  PurchaseReceiptRepository(this._database);

  final AppDatabase _database;

  static const Uuid _uuid = Uuid();

  /// Registra una recepción completa o parcial.
  ///
  /// Reglas:
  /// - La compra debe estar confirmada.
  /// - Debe contener al menos una línea.
  /// - No se permiten líneas duplicadas.
  /// - La cantidad recibida debe ser positiva.
  /// - No se puede superar la cantidad pendiente.
  /// - Los productos que controlan inventario generan
  ///   un movimiento de entrada.
  /// - Los productos que no controlan inventario no generan
  ///   movimientos.
  /// - Toda la operación es atómica.
  Future<String> createReceipt({
    required String purchaseId,
    required List<PurchaseReceiptLineInput> lines,
    DateTime? receivedAt,
    String? reference,
    String? notes,
  }) async {
    if (purchaseId.trim().isEmpty) {
      throw ArgumentError('El identificador de la compra es obligatorio.');
    }

    if (lines.isEmpty) {
      throw ArgumentError('La recepción debe contener al menos una línea.');
    }

    final normalizedReference = _normalizeOptional(reference);
    final normalizedNotes = _normalizeOptional(notes);

    final detailIds = <String>{};

    for (final line in lines) {
      if (line.purchaseDetailId.trim().isEmpty) {
        throw ArgumentError(
          'El identificador del detalle de compra es obligatorio.',
        );
      }

      if (line.quantityMilliUnits <= 0) {
        throw ArgumentError('La cantidad recibida debe ser mayor que cero.');
      }

      if (!detailIds.add(line.purchaseDetailId)) {
        throw ArgumentError(
          'No se permiten líneas duplicadas en una misma recepción.',
        );
      }
    }

    final receiptId = _uuid.v4();
    final date = receivedAt ?? DateTime.now();

    await _database.transaction(() async {
      final purchase = await (_database.select(
        _database.purchases,
      )..where((table) => table.id.equals(purchaseId))).getSingleOrNull();

      if (purchase == null) {
        throw StateError('La compra no existe.');
      }

      if (purchase.status != 'confirmed') {
        throw StateError('Solo se pueden recibir compras confirmadas.');
      }

      final purchaseDetails = await (_database.select(
        _database.purchaseDetails,
      )..where((table) => table.purchaseId.equals(purchaseId))).get();

      if (purchaseDetails.isEmpty) {
        throw StateError('La compra no contiene detalles.');
      }

      final detailsById = {
        for (final detail in purchaseDetails) detail.id: detail,
      };

      // Calcula las cantidades recibidas anteriormente.
      final receivedRows = await _database
          .select(_database.purchaseReceiptDetails)
          .join([
            innerJoin(
              _database.purchaseReceipts,
              _database.purchaseReceipts.id.equalsExp(
                _database.purchaseReceiptDetails.receiptId,
              ),
            ),
          ])
          .get();

      final receivedByDetail = <String, int>{};

      for (final row in receivedRows) {
        final receipt = row.readTable(_database.purchaseReceipts);

        if (receipt.purchaseId != purchaseId) {
          continue;
        }

        final detail = row.readTable(_database.purchaseReceiptDetails);

        final current = receivedByDetail[detail.purchaseDetailId] ?? 0;

        if (current > 9223372036854775807 - detail.quantityMilliUnits) {
          throw StateError(
            'El acumulado de cantidades recibidas supera el límite permitido.',
          );
        }

        receivedByDetail[detail.purchaseDetailId] =
            current + detail.quantityMilliUnits;
      }

      // Validar todas las líneas antes de insertar registros.
      for (final line in lines) {
        final purchaseDetail = detailsById[line.purchaseDetailId];

        if (purchaseDetail == null) {
          throw StateError(
            'El detalle ${line.purchaseDetailId} no pertenece a esta compra.',
          );
        }

        final alreadyReceived = receivedByDetail[line.purchaseDetailId] ?? 0;

        if (alreadyReceived > purchaseDetail.quantityMilliUnits ||
            line.quantityMilliUnits >
                purchaseDetail.quantityMilliUnits - alreadyReceived) {
          throw StateError(
            'La cantidad recibida supera la cantidad pendiente '
            'del producto ${purchaseDetail.productNameSnapshot}.',
          );
        }

        final product =
            await (_database.select(_database.products)
                  ..where((table) => table.id.equals(purchaseDetail.productId)))
                .getSingleOrNull();

        if (product == null) {
          throw StateError(
            'No existe el producto asociado al detalle de compra.',
          );
        }

        if (product.trackInventory && !product.isActive) {
          throw StateError(
            'No se puede recibir inventario de un producto inactivo: '
            '${product.name}.',
          );
        }
      }

      // Crear la cabecera de recepción.
      await _database
          .into(_database.purchaseReceipts)
          .insert(
            PurchaseReceiptsCompanion.insert(
              id: receiptId,
              purchaseId: purchaseId,
              receivedAt: date,
              reference: Value(normalizedReference),
              notes: Value(normalizedNotes),
            ),
          );

      // Crear movimientos y detalles.
      // El movimiento debe existir antes del detalle que lo referencia.
      for (final line in lines) {
        final purchaseDetail = detailsById[line.purchaseDetailId]!;

        final product =
            await (_database.select(_database.products)
                  ..where((table) => table.id.equals(purchaseDetail.productId)))
                .getSingle();

        String? movementId;

        if (product.trackInventory) {
          movementId = _uuid.v4();

          await _database
              .into(_database.inventoryMovements)
              .insert(
                InventoryMovementsCompanion.insert(
                  id: movementId,
                  productId: purchaseDetail.productId,
                  movementType: 'entry',
                  quantityMilliUnits: line.quantityMilliUnits,
                  reason: 'Recepción de compra',
                  reference: Value(
                    'receipt:$receiptId;detail:${line.purchaseDetailId}',
                  ),
                ),
              );
        }

        await _database
            .into(_database.purchaseReceiptDetails)
            .insert(
              PurchaseReceiptDetailsCompanion.insert(
                id: _uuid.v4(),
                receiptId: receiptId,
                purchaseDetailId: line.purchaseDetailId,
                quantityMilliUnits: line.quantityMilliUnits,
                inventoryMovementId: Value(movementId),
              ),
            );
      }
    });

    return receiptId;
  }

  /// Observa las recepciones de una compra.
  Stream<List<PurchaseReceipt>> watchByPurchase(String purchaseId) {
    return (_database.select(_database.purchaseReceipts)
          ..where((table) => table.purchaseId.equals(purchaseId))
          ..orderBy([
            (table) => OrderingTerm.desc(table.receivedAt),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  /// Obtiene las recepciones de una compra.
  Future<List<PurchaseReceipt>> getByPurchase(String purchaseId) {
    return (_database.select(_database.purchaseReceipts)
          ..where((table) => table.purchaseId.equals(purchaseId))
          ..orderBy([
            (table) => OrderingTerm.desc(table.receivedAt),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .get();
  }

  /// Obtiene los detalles de una recepción.
  Future<List<PurchaseReceiptDetail>> getReceiptDetails(String receiptId) {
    return (_database.select(
      _database.purchaseReceiptDetails,
    )..where((table) => table.receiptId.equals(receiptId))).get();
  }

  /// Devuelve las cantidades recibidas acumuladas por detalle de compra.
  ///
  /// La clave es purchaseDetailId y el valor es quantityMilliUnits.
  Future<Map<String, int>> getReceivedQuantities(String purchaseId) async {
    final rows = await _database.select(_database.purchaseReceiptDetails).join([
      innerJoin(
        _database.purchaseReceipts,
        _database.purchaseReceipts.id.equalsExp(
          _database.purchaseReceiptDetails.receiptId,
        ),
      ),
    ]).get();

    final result = <String, int>{};

    for (final row in rows) {
      final receipt = row.readTable(_database.purchaseReceipts);

      if (receipt.purchaseId != purchaseId) {
        continue;
      }

      final detail = row.readTable(_database.purchaseReceiptDetails);

      final current = result[detail.purchaseDetailId] ?? 0;

      if (current > 9223372036854775807 - detail.quantityMilliUnits) {
        throw StateError(
          'El acumulado de cantidades recibidas supera el límite permitido.',
        );
      }

      result[detail.purchaseDetailId] = current + detail.quantityMilliUnits;
    }

    return result;
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
