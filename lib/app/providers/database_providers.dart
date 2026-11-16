import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../features/inventory/data/inventory_repository.dart';
import '../../features/products/data/product_repository.dart';
import '../../features/purchases/data/purchase_receipt_repository.dart';
import '../../features/purchases/data/purchase_repository.dart';
import '../../features/purchases/data/supplier_payment_repository.dart';
import '../../features/settings/data/currency_repository.dart';
import '../../features/settings/data/exchange_rate_repository.dart';
import '../../features/suppliers/data/supplier_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository(ref.watch(appDatabaseProvider));
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepository(ref.watch(appDatabaseProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(appDatabaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
});

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(ref.watch(appDatabaseProvider));
});

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
  return SupplierPaymentRepository(
    ref.watch(appDatabaseProvider),
    exchangeRateRepository: ref.watch(exchangeRateRepositoryProvider),
  );
});
