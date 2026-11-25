import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(appDatabaseProvider));
});

final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  return ref.watch(salesRepositoryProvider).watchAll();
});

final salesCustomersProvider = StreamProvider<List<Customer>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.customers)
        ..where((row) => row.isActive.equals(true))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .watch();
});

final salesProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.products)
        ..where((row) => row.isActive.equals(true))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .watch();
});

final salesCurrenciesProvider = StreamProvider<List<Currency>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.currencies)
        ..where((row) => row.isActive.equals(true))
        ..orderBy([(row) => OrderingTerm.asc(row.code)]))
      .watch();
});

final saleByIdProvider = StreamProvider.family<Sale?, String>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.sales,
  )..where((row) => row.id.equals(id))).watchSingleOrNull();
});

final saleDetailsProvider = StreamProvider.family<List<SaleDetail>, String>((
  ref,
  id,
) {
  return ref.watch(salesRepositoryProvider).watchDetails(id);
});

final salePaymentsProvider = StreamProvider.family<List<SalePayment>, String>((
  ref,
  id,
) {
  return ref.watch(salesRepositoryProvider).watchPayments(id);
});
