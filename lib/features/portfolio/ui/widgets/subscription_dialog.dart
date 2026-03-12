import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fund.dart';
import '../../../transactions/di/transaction_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/subscribe_to_fund_use_case.dart';

class SubscriptionDialog extends ConsumerStatefulWidget {
  final Fund fund;

  const SubscriptionDialog({super.key, required this.fund});

  @override
  ConsumerState<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends ConsumerState<SubscriptionDialog> {
  late TextEditingController _amountController;
  NotificationMethod _selectedMethod = NotificationMethod.email;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.fund.minimumAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount < widget.fund.minimumAmount) {
      setState(() => _errorMessage = 'El monto mínimo es ${_formatCurrency(widget.fund.minimumAmount)}');
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final subscribeUseCase = ref.read(subscribeToFundUseCaseProvider);
      await subscribeUseCase.call(
        fundId: widget.fund.id,
        fundName: widget.fund.name,
        amount: amount,
        notificationMethod: _selectedMethod,
      );

      ref.invalidate(availableBalanceProvider);
      ref.invalidate(activeSubscriptionsProvider);
      ref.invalidate(transactionHistoryProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on InsufficientBalanceException catch (_) {
      setState(() => _errorMessage = 'FONDOS INSUFICIENTES');
    } catch (_) {
      setState(() => _errorMessage = 'Error inesperado. Intente de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final availableBalanceAsync = ref.watch(availableBalanceProvider);
    final availableBalance = availableBalanceAsync.valueOrNull ?? 0.0;

    final amountText = _amountController.text.replaceAll(',', '');
    final parsedAmount = double.tryParse(amountText) ?? 0.0;
    
    // Dynamic error logic decoupled into provider
    final isValidAmount = ref.watch(isValidInvestmentAmountProvider(parsedAmount));
    final isInsufficient = !isValidAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invertir en Fondo',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Available Balance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Saldo Disponible',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_formatCurrency(availableBalance)} COP',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            Text(
              'Monto a Invertir',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isInsufficient ? colorScheme.error : colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isInsufficient ? colorScheme.error : colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
            if (isInsufficient)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                    const SizedBox(width: 4),
                    Text(
                      'FONDOS INSUFICIENTES',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Notification Method
            Text(
              'Método de Notificación',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NotificationOption(
                    title: 'Email',
                    subtitle: 'Confirmación al correo',
                    isSelected: _selectedMethod == NotificationMethod.email,
                    onTap: () => setState(() {
                      _selectedMethod = NotificationMethod.email;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NotificationOption(
                    title: 'SMS',
                    subtitle: 'Alerta de texto rápida',
                    isSelected: _selectedMethod == NotificationMethod.sms,
                    onTap: () => setState(() {
                      _selectedMethod = NotificationMethod.sms;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isLoading || isInsufficient
                      ? null
                      : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Invertir Ahora'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotificationOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
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
