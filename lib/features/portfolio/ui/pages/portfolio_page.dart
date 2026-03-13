import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:btg_web/app/utils/responsive_layout_builder.dart';

import '../../../auth/di/user_injection.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/fund.dart';
import '../provider/funds_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/fund_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../../../../app/theme/theme_provider.dart';

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

  Widget _buildTopBar(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          if (!isMobile)
            Expanded(
              child: Text(
                'Resumen de Cartera',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isMobile) const Spacer(),
          // Search
          if (!isMobile)
            SizedBox(
              width: 220,
              height: 40,
              child: SearchBar(
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(colorScheme.surface),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                hintText: 'Buscar fondos...',
                leading: const Icon(Icons.search, size: 20),
                enabled: false,
              ),
            )
          else
            IconButton(icon: const Icon(Icons.search), onPressed: null),
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
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.settings_outlined),
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (mode) {
              ref.read(themeModeNotifierProvider.notifier).setThemeMode(mode);
            },
            itemBuilder: (context) {
              final currentMode = ref.watch(themeModeNotifierProvider);
              return [
                const PopupMenuItem<ThemeMode>(
                  enabled: false,
                  height: 32,
                  child: Text(
                    'Apariencia',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(Icons.light_mode_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('Modo claro'),
                      if (currentMode == ThemeMode.light) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.check, size: 20),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('Modo oscuro'),
                      if (currentMode == ThemeMode.dark) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.check, size: 20),
                      ],
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(Icons.devices_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('Sistema'),
                      if (currentMode == ThemeMode.system) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.check, size: 20),
                      ],
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    final userAsync = ref.watch(_userInfoProvider);
    final fundsAsync = ref.watch(
      availableFundsProvider(category: _selectedCategory),
    );

    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildTopBar(isMobile),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Balance + Recent Transactions row ─────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    final balanceCard = BalanceCard(
                      userAsync: userAsync,
                      isMobile: isMobile,
                    );
                    final recentTransactionsCard = const RecentTransactionsCard();
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: balanceCard),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: recentTransactionsCard),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        balanceCard,
                        const SizedBox(height: 16),
                        recentTransactionsCard,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── Investment Funds header + filters ─────────────────
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fondos de Inversión',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryFilterChip(
                              label: 'Todos',
                              isSelected: _selectedCategory == null,
                              onTap:
                                  () =>
                                      setState(() => _selectedCategory = null),
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
                      ),
                    ],
                  )
                else
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
                  data: (funds) {
                    if (funds.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            isMobile
                                ? 1
                                : (MediaQuery.of(context).size.width > 1100
                                    ? 3
                                    : 2),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 1.4 : 1.6,
                      ),
                      itemCount: funds.length,
                      itemBuilder:
                          (context, index) => FundCard(fund: funds[index]),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayoutBuilder(
          desktop: _buildContent(false),
          mobile: _buildContent(true),
        ),
      ),
    );
  }
}
