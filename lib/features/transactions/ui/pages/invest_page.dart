import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:btg_web/app/utils/responsive_layout_builder.dart';
import '../../di/transaction_providers.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/cancel_subscription_dialog.dart';
import '../widgets/active_investments_table.dart';
import '../widgets/mobile_active_investments_list.dart';
import '../widgets/active_investments_skeleton.dart';

class InvestPage extends ConsumerStatefulWidget {
  const InvestPage({super.key});

  @override
  ConsumerState<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends ConsumerState<InvestPage> {
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

  Widget _buildAsyncContent({
    required AsyncValue<List<Transaction>> subscriptionsAsync,
    required Widget Function(List<Transaction>) dataBuilder,
    required Widget loadingWidget,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return subscriptionsAsync.when(
      skipLoadingOnRefresh: false,
      data: (subscriptions) {
        if (subscriptions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/images/empty_wallet.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No tienes inversiones activas en este momento.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return dataBuilder(subscriptions);
      },
      loading: () => loadingWidget,
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            'Error al cargar las inversiones',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Active Investments Table
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
                child: _buildAsyncContent(
                  subscriptionsAsync: subscriptionsAsync,
                  loadingWidget: const ActiveInvestmentsTableSkeleton(),
                  dataBuilder: (subscriptions) => ActiveInvestmentsTable(
                    subscriptions: subscriptions,
                    onLiquidate: _liquidate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  'Mi Portafolio',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Investments Section
              Row(
                children: [
                  Icon(Icons.analytics, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Inversiones Activas',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Investments List
              _buildAsyncContent(
                subscriptionsAsync: subscriptionsAsync,
                loadingWidget: const MobileActiveInvestmentsListSkeleton(),
                dataBuilder: (subscriptions) => MobileActiveInvestmentsList(
                  subscriptions: subscriptions,
                  onLiquidate: _liquidate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      desktop: _buildDesktopLayout(),
      mobile: _buildMobileLayout(),
    );
  }
}
