import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_header.dart';

class ActiveInvestmentsTable extends StatelessWidget {
  const ActiveInvestmentsTable({
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

    return Column(
      children: [
        // Header Row
        Container(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: TransactionColumnHeader('NOMBRE DEL FONDO'),
              ),
              Expanded(
                flex: 2,
                child: TransactionColumnHeader('VALOR ACTUAL'),
              ),
              Expanded(
                flex: 2,
                child: TransactionColumnHeader('ACCIÓN', alignment: Alignment.centerRight),
              ),
            ],
          ),
        ),
        // Data Rows
        ...subscriptions.map((inv) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.fundName ?? 'Fondo Desconocido',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Suscripción Activa',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '\$${inv.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} COP',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => onLiquidate(inv),
                      child: const Text('LIQUIDAR'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
