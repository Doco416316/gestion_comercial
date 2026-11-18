import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
});

final productsStreamProvider = StreamProvider.family<List<Product>, bool>((
  ref,
  includeInactive,
) {
  return ref
      .watch(productRepositoryProvider)
      .watchAll(includeInactive: includeInactive);
});
