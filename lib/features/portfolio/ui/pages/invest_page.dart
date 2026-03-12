import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveInvestment {
  final String name;
  final String description;
  final String currentValue;
  final String returns;
  final bool isPositive;

  const ActiveInvestment({
    required this.name,
    required this.description,
    required this.currentValue,
    required this.returns,
    required this.isPositive,
  });
}

const _mockActiveInvestments = [
  ActiveInvestment(
    name: 'BTG Pactual Recaudadora',
    description: 'Conservative • Fixed Income',
    currentValue: '\$12,450.00',
    returns: '+4.2%',
    isPositive: true,
  ),
  ActiveInvestment(
    name: 'BTG Pactual Ecopetrol',
    description: 'Aggressive • Commodities',
    currentValue: '\$8,200.50',
    returns: '+12.8%',
    isPositive: true,
  ),
  ActiveInvestment(
    name: 'BTG Pactual Acciones',
    description: 'Moderate • Equity Market',
    currentValue: '\$5,100.00',
    returns: '-1.5%',
    isPositive: false,
  ),
];

class AvailableFund {
  final String name;
  final String description;
  final String minInvestment;
  final IconData icon;
  final Color baseColor;

  const AvailableFund({
    required this.name,
    required this.description,
    required this.minInvestment,
    required this.icon,
    required this.baseColor,
  });
}

const _mockAvailableFunds = [
  AvailableFund(
    name: 'Recaudadora',
    description: 'Steady capital growth with low risk index.',
    minInvestment: '\$50.00',
    icon: Icons.security,
    baseColor: Colors.blue,
  ),
  AvailableFund(
    name: 'Ecopetrol',
    description: 'Exposure to the energy sector and dividends.',
    minInvestment: '\$200.00',
    icon: Icons.water_drop, // oil_barrel alternative
    baseColor: Colors.orange,
  ),
  AvailableFund(
    name: 'DeudaPrivada',
    description: 'Invest in top-tier corporate credit instruments.',
    minInvestment: '\$100.00',
    icon: Icons.corporate_fare,
    baseColor: Colors.indigo,
  ),
  AvailableFund(
    name: 'Acciones',
    description: 'Diversified equity portfolio for high yield.',
    minInvestment: '\$150.00',
    icon: Icons.trending_up,
    baseColor: Colors.green, // emerald alternative
  ),
  AvailableFund(
    name: 'Dinamica',
    description: 'Active management for superior market performance.',
    minInvestment: '\$250.00',
    icon: Icons.rocket_launch,
    baseColor: Colors.purple,
  ),
];

class InvestPage extends ConsumerStatefulWidget {
  const InvestPage({super.key});

  @override
  ConsumerState<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends ConsumerState<InvestPage> {
  int _selectedDateFilter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                          'Investment Portfolio',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your current asset allocation and available growth opportunities.',
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
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DateFilterButton(
                          label: 'Today',
                          isSelected: _selectedDateFilter == 0,
                          onTap: () => setState(() => _selectedDateFilter = 0),
                        ),
                        _DateFilterButton(
                          label: 'Monthly',
                          isSelected: _selectedDateFilter == 1,
                          onTap: () => setState(() => _selectedDateFilter = 1),
                        ),
                        _DateFilterButton(
                          label: 'Yearly',
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
                    'My Active Investments',
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
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                    dividerThickness: 1,
                    dataRowMinHeight: 76,
                    dataRowMaxHeight: 76,
                    columns: [
                      DataColumn(label: _ColumnHeader('FUND NAME')),
                      DataColumn(label: _ColumnHeader('CURRENT VALUE')),
                      DataColumn(label: _ColumnHeader('RETURNS (YOY)')),
                      DataColumn(label: _ColumnHeader('ACTION')),
                    ],
                    rows: _mockActiveInvestments.map((inv) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inv.description,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              inv.currentValue,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: inv.isPositive
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                inv.returns,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: inv.isPositive ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'LIQUIDATE',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Available Funds Catalog
              Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Available Funds Catalog',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              LayoutBuilder(
                builder: (context, constraints) {
                  // Determine number of columns based on width
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 5;
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _mockAvailableFunds.length,
                    itemBuilder: (context, index) {
                      final fund = _mockAvailableFunds[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: fund.baseColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                fund.icon,
                                color: fund.baseColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              fund.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                leadingDistribution: TextLeadingDistribution.even,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fund.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'MIN. INVESTMENT',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fund.minInvestment,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {},
                                child: const Text('Subscribe'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
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
          color: isSelected ? colorScheme.surfaceContainerHighest : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
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
