import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/di/transaction_providers.dart';

class QuickSubscriptionCard extends ConsumerWidget {
  const QuickSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeSubscriptionsAsync = ref.watch(activeSubscriptionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Suscripciones Activas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            activeSubscriptionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(
                'Error al cargar suscripciones',
                style: TextStyle(color: colorScheme.error),
              ),
              data: (subscriptions) {
                if (subscriptions.isEmpty) {
                  return Text(
                    'No tienes suscripciones activas.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subscriptions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        sub.fundName ?? 'Fondo Desconocido',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '\$${sub.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                        onPressed: () async {
                          final cancelUseCase = ref.read(cancelSubscriptionUseCaseProvider);
                          await cancelUseCase.call(
                            fundId: sub.fundId ?? '',
                            fundName: sub.fundName ?? '',
                            amount: sub.amount,
                          );
                          ref.invalidate(availableBalanceProvider);
                          ref.invalidate(activeSubscriptionsProvider);
                          ref.invalidate(transactionHistoryProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Suscripción a ${sub.fundName} cancelada.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
