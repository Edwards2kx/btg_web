import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

class MobileActiveInvestmentsList extends StatelessWidget {
  const MobileActiveInvestmentsList({
    required this.subscriptions,
    required this.onLiquidate,
    super.key,
  });

  final List<Transaction> subscriptions;
  final Function(Transaction) onLiquidate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subscriptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final inv = subscriptions[index];
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inv.fundName ?? 'Fondo Desconocido',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALOR ACTUAL',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${inv.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} COP',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () => onLiquidate(inv),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('LIQUIDAR'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
