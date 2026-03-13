import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../transactions/di/transaction_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';

class RecentTransactionsCard extends ConsumerWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(transactionHistoryProvider());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Transacciones Recientes',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                historyAsync.maybeWhen(
                  data: (transactions) => transactions.length > 3
                      ? TextButton(
                          onPressed: () {
                            context.go('/history');
                          },
                          child: const Text('Ver todas'),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Text(
                    'Error al cargar transacciones',
                    style: TextStyle(color: colorScheme.error),
                  ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Text(
                    'No tienes transacciones recientes.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }

                final displayTransactions = transactions.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayTransactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = displayTransactions[index];
                        final isDeposit = tx.type == TransactionType.deposit;
                        final isSubscription =
                            tx.type == TransactionType.subscription;

                        String getTitle() {
                          if (isDeposit) {
                            return tx.fundName ?? 'Depósito a cuenta';
                          }
                          return tx.fundName ?? 'Fondo Desconocido';
                        }

                        String getSubtitle() {
                          if (isDeposit) return 'Depósito';
                          return isSubscription ? 'Suscripción' : 'Cancelación';
                        }

                        Color? getSubtitleColor() {
                          if (isDeposit) return Colors.blue[600];
                          return isSubscription
                              ? Colors.green[600]
                              : Colors.orange[600];
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTitle(),
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    getSubtitle(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: getSubtitleColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
