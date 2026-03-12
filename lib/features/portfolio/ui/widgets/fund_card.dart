import 'package:flutter/material.dart';

import '../../domain/entities/fund.dart';

class FundCard extends StatelessWidget {
  const FundCard({super.key, required this.fund, this.onSubscribe});

  final Fund fund;
  final VoidCallback? onSubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (categoryLabel, categoryColor) = switch (fund.category) {
      FundCategory.fpv => ('FPV', colorScheme.primary),
      FundCategory.fic => ('FIC', colorScheme.tertiary),
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + category badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    fund.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoryLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Minimum amount
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Monto mínimo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${fund.minimumAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onSubscribe,
                child: const Text('Suscribirse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
