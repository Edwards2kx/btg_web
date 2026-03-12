import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/di/user_injection.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/fund.dart';
import '../provider/funds_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/fund_card.dart';
import '../widgets/quick_subscription_card.dart';

// ─── Provider ──────────────────────────────────────────────────────────────

final _userInfoProvider = FutureProvider.autoDispose<User>((ref) {
  return ref.watch(getUserInfoUseCaseProvider).call();
});

// ─── Page ──────────────────────────────────────────────────────────────────

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  FundCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(_userInfoProvider);
    final fundsAsync = ref.watch(
      availableFundsProvider(category: _selectedCategory),
    );

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest.withValues(
                  alpha: 0.9,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resumen de Cartera',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Search (non-functional)
                  SizedBox(
                    width: 220,
                    height: 40,
                    child: SearchBar(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        colorScheme.surface,
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      hintText: 'Buscar fondos...',
                      leading: const Icon(Icons.search, size: 20),
                      enabled: false, // no functionality
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notifications
                  Badge(
                    smallSize: 8,
                    child: IconButton.outlined(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Settings
                  IconButton.outlined(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: null,
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Balance + Quick Subscription row ─────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final balanceCard = BalanceCard(userAsync: userAsync);
                        final quickCard = const QuickSubscriptionCard();
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: balanceCard),
                              const SizedBox(width: 16),
                              Expanded(child: quickCard),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            balanceCard,
                            const SizedBox(height: 16),
                            quickCard,
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Investment Funds header + filters ─────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Fondos de Inversión',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CategoryFilterChip(
                          label: 'Todos los Fondos',
                          isSelected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        CategoryFilterChip(
                          label: 'FIC',
                          isSelected: _selectedCategory == FundCategory.fic,
                          onTap:
                              () => setState(
                                () => _selectedCategory = FundCategory.fic,
                              ),
                        ),
                        const SizedBox(width: 8),
                        CategoryFilterChip(
                          label: 'FPV',
                          isSelected: _selectedCategory == FundCategory.fpv,
                          onTap:
                              () => setState(
                                () => _selectedCategory = FundCategory.fpv,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Fund Cards Grid ───────────────────────────────────
                    fundsAsync.when(
                      loading:
                          () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      error:
                          (err, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error al cargar los fondos: $err',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      data:
                          (funds) => LayoutBuilder(
                            builder: (context, constraints) {
                              int cols = 1;
                              if (constraints.maxWidth > 1100) {
                                cols = 3;
                              } else if (constraints.maxWidth > 650) {
                                cols = 2;
                              }

                              if (funds.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Text(
                                      'No hay fondos disponibles para esta categoría.',
                                      style: textTheme.bodyLarge,
                                    ),
                                  ),
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.6,
                                    ),
                                itemCount: funds.length,
                                itemBuilder:
                                    (context, index) =>
                                        FundCard(fund: funds[index]),
                              );
                            },
                          ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
