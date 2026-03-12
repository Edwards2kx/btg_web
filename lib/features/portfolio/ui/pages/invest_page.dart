import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/di/transaction_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../widgets/cancel_subscription_dialog.dart';

class InvestPage extends ConsumerStatefulWidget {
  const InvestPage({super.key});

  @override
  ConsumerState<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends ConsumerState<InvestPage> {
  int _selectedDateFilter = 0;

  void _liquidate(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CancelSubscriptionDialog(transaction: transaction),
    );

    if (confirmed != true) return;

    final cancelUseCase = ref.read(cancelSubscriptionUseCaseProvider);
    await cancelUseCase.call(
      fundId: transaction.fundId ?? '',
      fundName: transaction.fundName ?? '',
      amount: transaction.amount,
    );

    ref.invalidate(availableBalanceProvider);
    ref.invalidate(activeSubscriptionsProvider);
    ref.invalidate(transactionHistoryProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inversión en ${transaction.fundName} liquidada con éxito.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portafolio de Inversión',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tu asignación actual de activos.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Date Filters
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DateFilterButton(
                          label: 'Hoy',
                          isSelected: _selectedDateFilter == 0,
                          onTap: () => setState(() => _selectedDateFilter = 0),
                        ),
                        _DateFilterButton(
                          label: 'Mensual',
                          isSelected: _selectedDateFilter == 1,
                          onTap: () => setState(() => _selectedDateFilter = 1),
                        ),
                        _DateFilterButton(
                          label: 'Anual',
                          isSelected: _selectedDateFilter == 2,
                          onTap: () => setState(() => _selectedDateFilter = 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Active Investments Section
              Row(
                children: [
                  Icon(Icons.analytics, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Mis Inversiones Activas',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Investments Table (Custom Flex Layout to Avoid Overflow)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Consumer(
                  builder: (context, ref, child) {
                    final subscriptionsAsync = ref.watch(
                      activeSubscriptionsProvider,
                    );

                    return subscriptionsAsync.when(
                      data: (subscriptions) {
                        if (subscriptions.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(
                              child: Text(
                                'No tienes inversiones activas en este momento.',
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Header Row
                            Container(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _ColumnHeader('NOMBRE DEL FONDO'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _ColumnHeader('VALOR ACTUAL'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _ColumnHeader('ACCIÓN'),
                                    ),
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
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            inv.fundName ?? 'Fondo Desconocido',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Suscripción Activa',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
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
                                          onPressed: () => _liquidate(inv),
                                          child: Text('LIQUIDAR'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                      loading:
                          () => const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      error:
                          (error, stack) => Padding(
                            padding: const EdgeInsets.all(48),
                            child: Center(
                              child: Text(
                                'Error al cargar las inversiones',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.surfaceContainerHighest
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color:
                isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
