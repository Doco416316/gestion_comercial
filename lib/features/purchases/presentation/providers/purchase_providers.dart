import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/purchase_receipt_repository.dart';
import '../../data/purchase_repository.dart';
import '../../data/supplier_payment_repository.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository(ref.watch(appDatabaseProvider));
});

final purchaseReceiptRepositoryProvider = Provider<PurchaseReceiptRepository>((
  ref,
) {
  return PurchaseReceiptRepository(ref.watch(appDatabaseProvider));
});

final supplierPaymentRepositoryProvider = Provider<SupplierPaymentRepository>((
  ref,
) {
  return SupplierPaymentRepository(ref.watch(appDatabaseProvider));
});

final purchasesStreamProvider = StreamProvider<List<Purchase>>((ref) {
  return ref.watch(purchaseRepositoryProvider).watchAll();
});

final purchaseByIdProvider = StreamProvider.family<Purchase?, String>((
  ref,
  id,
) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.purchases,
  )..where((row) => row.id.equals(id))).watchSingleOrNull();
});

final purchaseDetailsProvider =
    StreamProvider.family<List<PurchaseDetail>, String>((ref, id) {
      return ref.watch(purchaseRepositoryProvider).watchDetails(id);
    });

final purchaseReceiptsProvider =
    StreamProvider.family<List<PurchaseReceipt>, String>((ref, id) {
      return ref.watch(purchaseReceiptRepositoryProvider).watchByPurchase(id);
    });

final purchaseReceivedQuantitiesProvider =
    FutureProvider.family<Map<String, int>, String>((ref, id) {
      ref.watch(purchaseReceiptsProvider(id));
      return ref
          .watch(purchaseReceiptRepositoryProvider)
          .getReceivedQuantities(id);
    });

final purchasePaymentsProvider =
    StreamProvider.family<List<SupplierPayment>, String>((ref, id) {
      return ref.watch(supplierPaymentRepositoryProvider).watchByPurchase(id);
    });

final purchaseSuppliersProvider = StreamProvider<List<Supplier>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.suppliers,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).watch();
});

final purchaseProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.products)
        ..where((row) => row.isActive.equals(true))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .watch();
});

final purchaseCurrenciesProvider = StreamProvider<List<Currency>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.currencies,
  )..orderBy([(row) => OrderingTerm.asc(row.code)])).watch();
});
