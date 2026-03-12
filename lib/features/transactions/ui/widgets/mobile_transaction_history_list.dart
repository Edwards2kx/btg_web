import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

/// A mobile-optimized list view for transaction history.
///
/// Displays each transaction as a card-like tile with an icon
/// indicating the transaction type, the fund name, amount,
/// type badge, and date — optimized for narrow screens.
class MobileTransactionHistoryList extends StatelessWidget {
  const MobileTransactionHistoryList({
    required this.transactions,
    super.key,
  });

  final List<Transaction> transactions;

  String _formatDateTime(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month $day, $year · ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'TRANSACCIONES RECIENTES',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        // Transaction tiles
        ...transactions.map((tx) {
          final isSubscription = tx.type == TransactionType.subscription;
          final isCancellation = tx.type == TransactionType.cancellation;
          final isDeposit = tx.type == TransactionType.deposit;

          String typeLabel = 'Otro';
          Color statusColor = Colors.grey;
          IconData iconData = Icons.swap_horiz;

          if (isSubscription) {
            typeLabel = 'Suscripción';
            statusColor = const Color(0xFF1B5E20);
            iconData = Icons.north_east;
          } else if (isCancellation) {
            typeLabel = 'Liquidación';
            statusColor = const Color(0xFFC62828);
            iconData = Icons.south_west;
          } else if (isDeposit) {
            typeLabel = 'Depósito';
            statusColor = Colors.orange;
            iconData = Icons.account_balance_wallet_outlined;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                children: [
                  // Transaction type icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Fund name + type badge + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.fundName ?? (isDeposit ? 'Billetera BTG' : 'Fondo'),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                typeLabel.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 10,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _formatDateTime(tx.date),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Amount
                  Text(
                    _formatCurrency(tx.amount),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
