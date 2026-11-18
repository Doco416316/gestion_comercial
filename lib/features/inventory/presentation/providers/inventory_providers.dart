import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(appDatabaseProvider));
});

final inventoryStreamProvider = StreamProvider<List<InventoryStock>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchInventory();
});

final recentInventoryMovementsProvider =
    StreamProvider<List<InventoryMovementEntry>>((ref) {
      return ref.watch(inventoryRepositoryProvider).watchRecentMovements();
    });
