import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(ref.watch(appDatabaseProvider));
});

final suppliersStreamProvider =
    StreamProvider.family<List<Supplier>, bool>((ref, includeInactive) {
  return ref
      .watch(supplierRepositoryProvider)
      .watchAll(includeInactive: includeInactive);
});
