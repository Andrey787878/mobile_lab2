import 'package:flutter/material.dart';

import 'conversion_record.dart';
import 'converter_state.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _state = ConverterState();
  final _amountController = TextEditingController();
  static const _amountStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );

  @override
  void dispose() {
    _amountController.dispose();
    _state.dispose();
    super.dispose();
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    _state.convert();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Center(
            child: SizedBox(
              width: 420,
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Конвертер', style: TextStyle(fontSize: 24)),
                  ),
                  IconButton(
                    tooltip: 'История конвертаций',
                    onPressed: _showHistory,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade900,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.history, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Center(child: SizedBox(width: 420, child: _form())),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _amountCard(),
        _swapButton(),
        _resultCard(),
        const SizedBox(height: 16),
        _feedbackPanel(),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('convertButton'),
          onPressed: _state.isLoading ? null : _convert,
          child: Text(
            _state.isLoading ? 'Конвертируем…' : 'Конвертировать',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _swapButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: IconButton.filled(
          tooltip: 'Обменять валюты местами',
          onPressed: _state.isLoading ? null : _state.swapCurrencies,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[850],
            foregroundColor: Colors.amber.shade700,
            fixedSize: const Size(48, 48),
          ),
          icon: const Icon(Icons.swap_vert, size: 28),
        ),
      ),
    );
  }

  Widget _card(String label, Widget amount, {required bool source}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 6),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(56),
            child: amount,
          ),
          const SizedBox(height: 12),
          _currencyButton(source: source),
        ],
      ),
    );
  }

  Widget _currencyButton({required bool source}) {
    final currency = source ? _state.fromCurrency : _state.toCurrency;
    final label = source ? 'Исходная валюта' : 'Целевая валюта';
    final name = ConverterState.currencyNames[currency]!;
    final VoidCallback? onTap = _state.isLoading
        ? null
        : () => _selectCurrency(source: source);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$label: $currency, $name',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.grey[850],
        shape: shape,
        child: ListTile(
          key: ValueKey(source ? 'fromCurrency' : 'toCurrency'),
          onTap: onTap,
          shape: shape,
          minTileHeight: 56,
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          horizontalTitleGap: 12,
          leading: SizedBox(
            width: 48,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                currency,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          subtitle: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          trailing: Icon(
            Icons.expand_more,
            color: Colors.amber.shade700,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _amountCard() {
    return _card(
      'Сумма',
      TextField(
        key: const ValueKey('amountInput'),
        controller: _amountController,
        readOnly: _state.isLoading,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        textInputAction: TextInputAction.done,
        onChanged: _state.setAmount,
        onSubmitted: (_) => _convert(),
        style: _amountStyle,
        cursorColor: Colors.amber.shade700,
        decoration: const InputDecoration(
          hintText: '0,00',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      source: true,
    );
  }

  Widget _resultCard() {
    final result = _state.result;
    return _card(
      'Результат',
      Semantics(
        liveRegion: true,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              result == null ? '—' : formatAmount(result),
              style: _amountStyle,
            ),
          ),
        ),
      ),
      source: false,
    );
  }

  Widget _feedbackPanel() {
    final error = _state.error;
    final rate = _state.rate;
    var message =
        'Введите сумму и выберите валюты.\nКурс загрузится при конвертации.';
    var icon = Icons.info_outline;
    Color color = Colors.grey;
    if (_state.isLoading) {
      message = 'Загружаем актуальный курс…';
      color = Colors.white;
    } else if (error != null) {
      message = error;
      icon = Icons.error_outline;
      color = const Color(0xFFEF9A9A);
    } else if (rate != null) {
      icon = Icons.currency_exchange;
      color = Colors.amber.shade700;
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('feedbackPanel'),
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: error == null
              ? const Color(0xFF141414)
              : const Color(0xFF23191A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: error == null
                ? const Color(0xFF252525)
                : const Color(0xFF513034),
          ),
        ),
        child: Row(
          children: [
            _state.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.amber.shade700,
                    ),
                  )
                : Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                child: rate == null
                    ? Text(
                        message,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      )
                    : _rateInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateInfo() {
    final rate = _state.rate!;
    var value = rate.value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    if (rate.value < 0.000001 || rate.value >= 1e12) {
      value = rate.value.toStringAsPrecision(6);
    }
    var dateText = 'Одинаковые валюты · курс 1';
    final date = rate.date;
    if (date != null) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      dateText = 'Дата курса: $day.$month.${date.year}';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '1 ${rate.fromCurrency} = ${value.replaceAll('.', ',')} ${rate.toCurrency}',
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          dateText,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Future<T?> _showSheet<T>(Widget child) {
    FocusScope.of(context).unfocus();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 440),
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: child,
        ),
      ),
    );
  }

  Widget _sheetHeader(
    String title,
    String closeTooltip, {
    List<Widget> actions = const [],
  }) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 22))),
        ...actions,
        IconButton(
          tooltip: closeTooltip,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Future<void> _selectCurrency({required bool source}) async {
    final currency = await _showSheet<String>(_currencyList(source: source));
    if (!mounted || currency == null) return;
    _state.setCurrency(currency, source: source);
  }

  Widget _currencyList({required bool source}) {
    final selected = source ? _state.fromCurrency : _state.toCurrency;
    final currencies = ConverterState.currencies.toList();
    return Column(
      children: [
        _sheetHeader(
          source ? 'Исходная валюта' : 'Целевая валюта',
          'Закрыть выбор валюты',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            key: const ValueKey('currencyList'),
            padding: EdgeInsets.zero,
            itemCount: currencies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final code = currencies[index];
              final isSelected = code == selected;
              return Material(
                color: isSelected
                    ? const Color(0xFF3B3020)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  key: ValueKey('currencyOption$code'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  title: Text(
                    code,
                    style: TextStyle(
                      color: isSelected ? Colors.amber.shade700 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    ConverterState.currencyNames[code]!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.amber.shade700,
                          size: 22,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, code),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showHistory() {
    _showSheet<void>(
      ListenableBuilder(
        listenable: _state,
        builder: (context, child) => _historyList(),
      ),
    );
  }

  Widget _historyList() {
    final history = _state.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sheetHeader(
          'История',
          'Закрыть историю',
          actions: [
            IconButton(
              tooltip: 'Очистить историю',
              onPressed: history.isEmpty ? null : _state.clearHistory,
              icon: const Icon(Icons.delete_outline),
              color: Colors.amber.shade700,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Последние 10 операций',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: history.isEmpty
              ? const Center(
                  child: Text(
                    'Здесь появятся ваши конвертации',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) => _historyItem(history[index]),
                ),
        ),
      ],
    );
  }

  Widget _historyItem(ConversionRecord record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatAmount(record.amount)} ${record.fromCurrency}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            '${formatAmount(record.result)} ${record.toCurrency}',
            style: TextStyle(color: Colors.amber.shade700, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
