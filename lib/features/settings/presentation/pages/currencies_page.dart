import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/database_providers.dart';
import '../../../../app/utils/error_messages.dart';
import '../../../../core/database/app_database.dart';

class CurrenciesPage extends ConsumerStatefulWidget {
  const CurrenciesPage({super.key});

  @override
  ConsumerState<CurrenciesPage> createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends ConsumerState<CurrenciesPage> {
  final Set<String> _busyCodes = <String>{};

  Future<void> _showCreateDialog() async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSave =
                !saving &&
                codeController.text.trim().isNotEmpty &&
                nameController.text.trim().isNotEmpty &&
                symbolController.text.trim().isNotEmpty;

            return AlertDialog(
              title: const Text('Nueva moneda'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Código'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  TextField(
                    controller: symbolController,
                    decoration: const InputDecoration(labelText: 'Símbolo'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: canSave
                      ? () async {
                          setDialogState(() => saving = true);
                          try {
                            await ref
                                .read(currencyRepositoryProvider)
                                .create(
                                  code: codeController.text.trim(),
                                  name: nameController.text.trim(),
                                  symbol: symbolController.text.trim(),
                                );
                            if (!mounted || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Moneda creada')),
                            );
                            Navigator.of(dialogContext).pop();
                          } catch (error) {
                            if (mounted && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(readableErrorMessage(error)),
                                ),
                              );
                              setDialogState(() => saving = false);
                            }
                          }
                        }
                      : null,
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _setActive(Currency currency, bool value) async {
    setState(() => _busyCodes.add(currency.code));
    try {
      await ref
          .read(currencyRepositoryProvider)
          .setActive(currency.code, value);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Moneda actualizada')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busyCodes.remove(currency.code));
    }
  }

  Future<void> _setBase(Currency currency) async {
    setState(() => _busyCodes.add(currency.code));
    try {
      await ref.read(currencyRepositoryProvider).setBaseCurrency(currency.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moneda base actualizada')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(readableErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busyCodes.remove(currency.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(currencyRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
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
              final busy = _busyCodes.contains(currency.code);
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currency.isBase) const Text('Base'),
                    Switch(
                      value: currency.isActive,
                      onChanged: currency.isBase || busy
                          ? null
                          : (value) => _setActive(currency, value),
                    ),
                    if (!currency.isBase)
                      TextButton(
                        onPressed: (!currency.isActive || busy)
                            ? null
                            : () => _setBase(currency),
                        child: const Text('Marcar como base'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
