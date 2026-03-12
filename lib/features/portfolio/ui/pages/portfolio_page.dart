import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/di/user_injection.dart';
import '../../../auth/domain/entities/user.dart';

// ─── Mock data ─────────────────────────────────────────────────────────────

class _FundItem {
  final String name;
  final String description;
  final String category;
  final String minAmount;
  final IconData icon;
  final Color color;

  const _FundItem({
    required this.name,
    required this.description,
    required this.category,
    required this.minAmount,
    required this.icon,
    required this.color,
  });
}

const _fundItems = [
  _FundItem(
    name: 'BTG Pactual Liquidez',
    description: 'Low risk, high liquidity fund for daily management.',
    category: 'FIC',
    minAmount: '\$20,000 COP',
    icon: Icons.show_chart,
    color: Colors.green,
  ),
  _FundItem(
    name: 'Skandia Pensiones',
    description: 'Long-term retirement planning with tax benefits.',
    category: 'FPV',
    minAmount: '\$100,000 COP',
    icon: Icons.account_balance,
    color: Colors.blue,
  ),
  _FundItem(
    name: 'Global Equity Fund',
    description: 'High yield exposure to international stock markets.',
    category: 'FIC',
    minAmount: '\$50,000 COP',
    icon: Icons.public,
    color: Colors.indigo,
  ),
  _FundItem(
    name: 'Real Estate Prime',
    description: 'Diversified commercial property investment portfolio.',
    category: 'FPV',
    minAmount: '\$250,000 COP',
    icon: Icons.home_work,
    color: Colors.amber,
  ),
  _FundItem(
    name: 'ESG Sustainable Fund',
    description: 'Investments focused on environmental and social impact.',
    category: 'FIC',
    minAmount: '\$15,000 COP',
    icon: Icons.eco,
    color: Colors.purple,
  ),
  _FundItem(
    name: 'High Yield Debt',
    description: 'Fixed income strategies for higher risk-adjusted returns.',
    category: 'FIC',
    minAmount: '\$75,000 COP',
    icon: Icons.payments,
    color: Colors.red,
  ),
];

class _TxItem {
  final String fundName;
  final String type;
  final String date;
  final String amount;
  final bool amountNegative;
  final bool completed;

  const _TxItem({
    required this.fundName,
    required this.type,
    required this.date,
    required this.amount,
    this.amountNegative = false,
    required this.completed,
  });
}

const _recentTx = [
  _TxItem(
    fundName: 'BTG Liquidez',
    type: 'Subscription',
    date: 'Oct 12, 2023',
    amount: '\$10,000,000',
    completed: true,
  ),
  _TxItem(
    fundName: 'Skandia Pensiones',
    type: 'Monthly Contribution',
    date: 'Oct 05, 2023',
    amount: '\$500,000',
    completed: true,
  ),
  _TxItem(
    fundName: 'Global Equity',
    type: 'Redemption',
    date: 'Sep 28, 2023',
    amount: '-\$2,000,000',
    amountNegative: true,
    completed: false,
  ),
];

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
  int _filterIndex = 0; // 0 = All, 1 = FIC, 2 = FPV

  List<_FundItem> get _filteredFunds {
    if (_filterIndex == 1) return _fundItems.where((f) => f.category == 'FIC').toList();
    if (_filterIndex == 2) return _fundItems.where((f) => f.category == 'FPV').toList();
    return _fundItems;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(_userInfoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Portfolio Overview',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Search (non-functional)
                  SizedBox(
                    width: 220,
                    height: 40,
                    child: SearchBar(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(colorScheme.surface),
                      side: WidgetStateProperty.all(BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6))),
                      hintText: 'Search funds...',
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
                        final balanceCard = _BalanceCard(userAsync: userAsync);
                        final quickCard = _QuickSubscriptionCard();
                        if (isWide) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: balanceCard),
                                const SizedBox(width: 16),
                                Expanded(child: quickCard),
                              ],
                            ),
                          );
                        }
                        return Column(children: [
                          balanceCard,
                          const SizedBox(height: 16),
                          quickCard,
                        ]);
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Investment Funds header + filters ─────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Investment Funds',
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _CategoryFilterChip(
                          label: 'All Funds',
                          isSelected: _filterIndex == 0,
                          onTap: () => setState(() => _filterIndex = 0),
                        ),
                        const SizedBox(width: 8),
                        _CategoryFilterChip(
                          label: 'FIC',
                          isSelected: _filterIndex == 1,
                          onTap: () => setState(() => _filterIndex = 1),
                        ),
                        const SizedBox(width: 8),
                        _CategoryFilterChip(
                          label: 'FPV',
                          isSelected: _filterIndex == 2,
                          onTap: () => setState(() => _filterIndex = 2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Fund Cards Grid ───────────────────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int cols = 1;
                        if (constraints.maxWidth > 1100) {
                          cols = 3;
                        } else if (constraints.maxWidth > 650) {
                          cols = 2;
                        }
                        final funds = _filteredFunds;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.6,
                          ),
                          itemCount: funds.length,
                          itemBuilder: (context, index) => _FundCard(fund: funds[index]),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Recent Transactions ───────────────────────────────
                    _RecentTransactions(),
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

// ─── Balance Card ───────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.userAsync});

  final AsyncValue<User> userAsync;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF001E61);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Account Balance',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          userAsync.when(
            loading: () => const SizedBox(
              height: 44,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            error: (_, __) => Text(
              '\$0.00 COP',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
            ),
            data: (user) => Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${user.balance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'COP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Growth',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
                      const SizedBox(height: 2),
                      const Text('+2.4%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6ee7b7))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Funds',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
                      const SizedBox(height: 2),
                      const Text('12 Funds',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Subscription Card ────────────────────────────────────────────────

class _QuickSubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_card, size: 28, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Quick Subscription',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Invest in new opportunities with just one click.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: const Text('Invest Now'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fund Card ──────────────────────────────────────────────────────────────

class _FundCard extends StatelessWidget {
  const _FundCard({required this.fund});

  final _FundItem fund;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fund.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(fund.icon, color: fund.color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fund.category,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(fund.name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              fund.description,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min. Amount',
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fund.minAmount,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Transactions ────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text('Recent Transactions',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              columns: [
                DataColumn(label: _TxColumnHeader('FUND NAME')),
                DataColumn(label: _TxColumnHeader('TYPE')),
                DataColumn(label: _TxColumnHeader('DATE')),
                DataColumn(label: _TxColumnHeader('AMOUNT')),
                DataColumn(label: _TxColumnHeader('STATUS')),
              ],
              rows: _recentTx.map((tx) {
                return DataRow(cells: [
                  DataCell(Text(tx.fundName,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  DataCell(Text(tx.type,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))),
                  DataCell(Text(tx.date,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))),
                  DataCell(Text(
                    tx.amount,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tx.amountNegative ? Colors.red[600] : null,
                    ),
                  )),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tx.completed
                            ? Colors.green.withValues(alpha: 0.1)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tx.completed ? 'Completed' : 'Pending',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tx.completed ? Colors.green[700] : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxColumnHeader extends StatelessWidget {
  const _TxColumnHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      );
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
