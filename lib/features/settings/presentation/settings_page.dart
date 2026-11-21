import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import 'providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String? _selectedCurrency;

  Future<void> _showCurrencyForm([Currency? currency]) async {
    var codeValue = currency?.code ?? '';
    var nameValue = currency?.name ?? '';
    var symbolValue = currency?.symbol ?? '';
    var digits = currency?.decimalDigits ?? 2;
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(currency == null ? 'Registrar moneda' : 'Editar moneda'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: codeValue,
                      onChanged: (value) => codeValue = value,
                      enabled: currency == null,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        labelText: 'Código (ISO de 3 letras)',
                        counterText: '',
                      ),
                      validator: (v) =>
                          v == null ||
                              !RegExp(r'^[A-Za-z]{3}$').hasMatch(v.trim())
                          ? 'Usa exactamente tres letras.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: nameValue,
                      onChanged: (value) => nameValue = value,
                      maxLength: 60,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: symbolValue,
                      onChanged: (value) => symbolValue = value,
                      maxLength: 8,
                      decoration: const InputDecoration(labelText: 'Símbolo'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: digits,
                      decoration: const InputDecoration(labelText: 'Decimales'),
                      items: [
                        for (var i = 0; i <= 4; i++)
                          DropdownMenuItem(value: i, child: Text('$i')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => digits = value ?? 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      try {
        final repository = ref.read(currencyRepositoryProvider);
        if (currency == null) {
          await repository.create(
            code: codeValue,
            name: nameValue,
            symbol: symbolValue,
            decimalDigits: digits,
          );
          final currencies = await repository.watchAll().first;
          if (currencies.where((c) => c.isBase).isEmpty) {
            await repository.setBaseCurrency(codeValue);
          }
        } else {
          await repository.updateDetails(
            code: currency.code,
            name: nameValue,
            symbol: symbolValue,
            decimalDigits: digits,
          );
        }
        if (!mounted) return;
        _message(
          currency == null ? 'Moneda registrada.' : 'Moneda actualizada.',
        );
      } catch (error) {
        if (mounted) _message(_cleanError(error), isError: true);
      }
    }
  }

  Future<void> _setBase(Currency currency) async {
    try {
      await ref.read(currencyRepositoryProvider).setBaseCurrency(currency.code);
      if (mounted) _message('${currency.code} es ahora la moneda base.');
    } catch (error) {
      if (mounted) _message(_cleanError(error), isError: true);
    }
  }

  Future<void> _toggleActive(Currency currency) async {
    try {
      await ref
          .read(currencyRepositoryProvider)
          .setActive(currency.code, !currency.isActive);
    } catch (error) {
      if (mounted) _message(_cleanError(error), isError: true);
    }
  }

  Future<void> _showRateForm(Currency currency) async {
    var rateValue = '';
    DateTime effectiveAt = DateTime.now();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tasa de cambio · ${currency.code}'),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: rateValue,
                    onChanged: (value) => rateValue = value,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          'Unidades de moneda base por 1 ${currency.code}',
                      hintText: 'Ej. 400.00',
                    ),
                    validator: (v) {
                      final value = Decimal.tryParse(
                        (v ?? '').trim().replaceAll(',', '.'),
                      );
                      return value == null || value <= Decimal.zero
                          ? 'Introduce una tasa mayor que cero.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha de vigencia'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(effectiveAt),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: effectiveAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null) {
                        setDialogState(
                          () => effectiveAt = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      try {
        await ref
            .read(exchangeRateRepositoryProvider)
            .registerRate(
              currencyCode: currency.code,
              rateToBase: Decimal.parse(rateValue.trim().replaceAll(',', '.')),
              effectiveAt: effectiveAt,
            );
        if (mounted) _message('Tasa registrada.');
      } catch (error) {
        if (mounted) _message(_cleanError(error), isError: true);
      }
    }
  }

  void _message(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _cleanError(Object error) => error
      .toString()
      .replaceFirst('StateError: ', '')
      .replaceFirst('ArgumentError: ', '');

  @override
  Widget build(BuildContext context) {
    final currenciesAsync = ref.watch(settingsCurrenciesProvider);
    return Scaffold(
      body: currenciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('No se pudieron cargar las monedas: $error')),
        data: (currencies) {
          final active = currencies.where((c) => c.isActive).toList();
          Currency? selected;
          for (final currency in active) {
            if (currency.code == _selectedCurrency) selected = currency;
          }
          selected ??= active.isNotEmpty ? active.first : null;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monedas y tasas de cambio',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Administra las monedas utilizadas en compras y ventas.',
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () => _showCurrencyForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva moneda'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (currencies.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.currency_exchange, size: 44),
                        const SizedBox(height: 12),
                        const Text(
                          'Todavía no hay monedas registradas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Registra la primera moneda. Se establecerá como moneda base automáticamente.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _showCurrencyForm(),
                          child: const Text('Registrar primera moneda'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Monedas registradas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (final currency in currencies)
                        _currencyTile(currency),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasas de cambio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (active.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selected?.code,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Moneda'),
                      items: [
                        for (final c in active)
                          DropdownMenuItem(
                            value: c.code,
                            child: Text(
                              '${c.code} · ${c.name}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCurrency = value),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (selected == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Registra y activa una moneda para administrar sus tasas.',
                    ),
                  ),
                )
              else if (selected.isBase)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'La moneda base utiliza una tasa fija de 1. No necesita registros de cambio.',
                    ),
                  ),
                )
              else
                _ratesPanel(selected),
            ],
          );
        },
      ),
    );
  }

  Widget _currencyTile(Currency currency) => ListTile(
    leading: CircleAvatar(child: Text(currency.code.substring(0, 1))),
    title: Text('${currency.code} · ${currency.name}'),
    subtitle: Text(
      'Símbolo: ${currency.symbol}  ·  ${currency.decimalDigits} decimales${currency.isBase ? '  ·  Moneda base' : ''}${!currency.isActive ? '  ·  Inactiva' : ''}',
    ),
    isThreeLine: false,
    trailing: Wrap(
      spacing: 0,
      children: [
        if (!currency.isBase && currency.isActive)
          IconButton(
            tooltip: 'Establecer como base',
            onPressed: () => _setBase(currency),
            icon: const Icon(Icons.star_outline),
          ),
        IconButton(
          tooltip: 'Editar',
          onPressed: () => _showCurrencyForm(currency),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: currency.isActive ? 'Desactivar' : 'Activar',
          onPressed: currency.isBase ? null : () => _toggleActive(currency),
          icon: Icon(currency.isActive ? Icons.toggle_on : Icons.toggle_off),
        ),
      ],
    ),
  );

  Widget _ratesPanel(Currency currency) {
    final ratesAsync = ref.watch(currencyRatesProvider(currency.code));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Historial registrado',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _showRateForm(currency),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva tasa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ratesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error al cargar tasas: $e'),
              data: (rates) => rates.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No hay tasas registradas para esta moneda.'),
                    )
                  : Column(
                      children: [
                        for (final rate in rates)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.trending_up),
                            title: Text(
                              '1 ${currency.code} = ${rate.rateToBase} unidades de moneda base',
                            ),
                            subtitle: Text(
                              'Vigente desde ${DateFormat('dd/MM/yyyy').format(rate.effectiveAt)}',
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
