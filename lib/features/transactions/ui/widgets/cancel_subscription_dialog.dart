import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/transaction.dart';
import '../../di/transaction_providers.dart';

class CancelSubscriptionDialog extends ConsumerStatefulWidget {
  final Transaction transaction;

  const CancelSubscriptionDialog({super.key, required this.transaction});

  @override
  ConsumerState<CancelSubscriptionDialog> createState() => _CancelSubscriptionDialogState();
}

class _CancelSubscriptionDialogState extends ConsumerState<CancelSubscriptionDialog> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cancelState = ref.watch(cancelSubscriptionControllerProvider);
    final isLoading = cancelState.isLoading;

    ref.listen(cancelSubscriptionControllerProvider, (previous, next) {
      if (next.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error inesperado. Intente de nuevo.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(24),
            ),
          );
        }
      } else if (!next.isLoading && previous?.isLoading == true && !next.hasError) {
        if (mounted) {
          context.pop(true);
        }
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                  'Liquidar Fondo',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (mounted) {
                            context.pop(false);
                          }
                        },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Estás a punto de liquidar tu inversión en ${widget.transaction.fundName ?? 'este fondo'}.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Deseas continuar con el procedimiento?',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (mounted) {
                            context.pop(false);
                          }
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(cancelSubscriptionControllerProvider.notifier).cancel(
                                fundId: widget.transaction.fundId ?? '',
                                fundName: widget.transaction.fundName ?? '',
                                amount: widget.transaction.amount,
                              );
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Visibility(
                        visible: !isLoading,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: const Text('Continuar'),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
