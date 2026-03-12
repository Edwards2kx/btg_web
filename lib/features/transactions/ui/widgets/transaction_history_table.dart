import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_header.dart';

class TransactionHistoryTable extends StatelessWidget {
  const TransactionHistoryTable({
    required this.transactions,
    super.key,
  });

  final List<Transaction> transactions;

  String _formatDateTime(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$month $day, $year - ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  String _formatCurrency(double amount) {
    return '\$ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Header Row
        Container(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Row(
            children: [
              Expanded(flex: 3, child: TransactionColumnHeader('FECHA Y HORA')),
              Expanded(flex: 3, child: TransactionColumnHeader('NOMBRE DEL FONDO')),
              Expanded(flex: 2, child: TransactionColumnHeader('TIPO')),
              Expanded(
                flex: 2, 
                child: TransactionColumnHeader('MONTO', alignment: Alignment.centerRight),
              ),
            ],
          ),
        ),
        // Data Rows
        ...transactions.map((tx) {
          final isSubscription = tx.type == TransactionType.subscription;
          final isCancellation = tx.type == TransactionType.cancellation;
          final isDeposit = tx.type == TransactionType.deposit;

          String typeLabel = 'Otro';
          Color statusColor = Colors.grey;
          if (isSubscription) {
            typeLabel = 'Suscripción';
            statusColor = Colors.green;
          } else if (isCancellation) {
            typeLabel = 'Liquidación';
            statusColor = Colors.blue;
          } else if (isDeposit) {
            typeLabel = 'Depósito';
            statusColor = Colors.orange;
          }

          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatDateTime(tx.date),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    tx.fundName ?? (isDeposit ? 'Billetera BTG' : 'Fondo'),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeLabel,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatCurrency(tx.amount),
                    textAlign: TextAlign.right,
                    style: textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
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
