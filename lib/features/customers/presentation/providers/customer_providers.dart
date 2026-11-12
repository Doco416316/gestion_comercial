import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return CustomerRepository(database);
});

final customersStreamProvider = StreamProvider.family<List<Customer>, bool>((
  ref,
  includeInactive,
) {
  final repository = ref.watch(customerRepositoryProvider);

  return repository.watchAll(includeInactive: includeInactive);
});
