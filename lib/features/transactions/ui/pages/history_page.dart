import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:btg_web/app/utils/responsive_layout_builder.dart';
import '../../di/transaction_providers.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/transaction_filter_chip.dart';
import '../widgets/transaction_history_table.dart';
import '../widgets/mobile_transaction_history_list.dart';
import '../widgets/transaction_history_skeleton.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  TransactionType? _selectedType;

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          TransactionFilterChip(
            label: 'Todo',
            isSelected: _selectedType == null,
            onTap: () => setState(() => _selectedType = null),
          ),
          const SizedBox(width: 8),
          TransactionFilterChip(
            label: 'Suscripciones',
            isSelected: _selectedType == TransactionType.subscription,
            onTap: () => setState(() => _selectedType = TransactionType.subscription),
          ),
          const SizedBox(width: 8),
          TransactionFilterChip(
            label: 'Liquidaciones',
            isSelected: _selectedType == TransactionType.cancellation,
            onTap: () => setState(() => _selectedType = TransactionType.cancellation),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncContent({
    required AsyncValue<List<Transaction>> historyAsync,
    required Widget Function(List<Transaction>) dataBuilder,
    required Widget loadingWidget,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return historyAsync.when(
      skipLoadingOnRefresh: false,
      data: (transactions) {
        if (transactions.isEmpty) {
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
                    'No se encontraron transacciones.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return dataBuilder(transactions);
      },
      loading: () => loadingWidget,
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            'Error al cargar el historial.',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  // ─── Desktop Layout ────────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(transactionHistoryProvider(type: _selectedType));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Fondos BTG',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Administra y rastrea tu historial de transacciones',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Filters
              _buildFilterChips(),

              const SizedBox(height: 32),

              // Table Container
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
                  historyAsync: historyAsync,
                  dataBuilder: (txs) => TransactionHistoryTable(transactions: txs),
                  loadingWidget: const TransactionHistoryTableSkeleton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Mobile Layout ─────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(transactionHistoryProvider(type: _selectedType));

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
                  'Historial de Transacciones',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filters
              _buildFilterChips(),

              const SizedBox(height: 24),

              // Transaction list
              _buildAsyncContent(
                historyAsync: historyAsync,
                dataBuilder: (txs) =>
                    MobileTransactionHistoryList(transactions: txs),
                loadingWidget: const MobileTransactionHistoryListSkeleton(),
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
