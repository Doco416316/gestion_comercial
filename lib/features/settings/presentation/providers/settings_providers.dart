import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/currency_repository.dart';
import '../../../../core/database/app_database.dart';
import '../../data/exchange_rate_repository.dart';

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository(ref.watch(appDatabaseProvider));
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepository(ref.watch(appDatabaseProvider));
});

final settingsCurrenciesProvider = StreamProvider<List<Currency>>((ref) {
  return ref.watch(currencyRepositoryProvider).watchAll();
});

final currencyRatesProvider = StreamProvider.family<List<ExchangeRate>, String>(
  (ref, code) {
    return ref.watch(exchangeRateRepositoryProvider).watchRates(code);
  },
);
