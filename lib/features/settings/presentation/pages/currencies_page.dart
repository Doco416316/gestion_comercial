import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class CurrenciesPage extends ConsumerWidget {
  const CurrenciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(currencyRepositoryProvider);

    return Scaffold(
      body: StreamBuilder<List<Currency>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(readableErrorMessage(snapshot.error!)));
          }

          final currencies = snapshot.data ?? const <Currency>[];

          if (currencies.isEmpty) {
            return const Center(child: Text('No hay monedas'));
          }

          return ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(currency.code),
                    const SizedBox(width: 8),
                    Text(currency.name),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(currency.symbol),
                    const SizedBox(width: 8),
                    Text('${currency.decimalDigits}'),
                  ],
                ),
                trailing: currency.isBase ? const Text('Base') : null,
              );
            },
          );
        },
      ),
    );
  }
}
