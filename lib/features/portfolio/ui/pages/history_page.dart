import 'package:flutter/material.dart';

class TransactionItem {
  final String date;
  final String fundName;
  final String type;
  final String amount;
  final bool isSubscription;

  const TransactionItem({
    required this.date,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.isSubscription,
  });
}

const _mockTransactions = [
  TransactionItem(
    date: 'Oct 24, 2023 - 10:30 AM',
    fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
    type: 'Subscription',
    amount: '\$ 2.500.000 COP',
    isSubscription: true,
  ),
  TransactionItem(
    date: 'Oct 22, 2023 - 02:15 PM',
    fundName: 'BTG_PACTUAL_ACCIONES_CO',
    type: 'Cancellation',
    amount: '\$ 1.200.000 COP',
    isSubscription: false,
  ),
  TransactionItem(
    date: 'Oct 20, 2023 - 09:45 AM',
    fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
    type: 'Subscription',
    amount: '\$ 5.000.000 COP',
    isSubscription: true,
  ),
  TransactionItem(
    date: 'Oct 18, 2023 - 11:20 AM',
    fundName: 'BTG_PACTUAL_TES_LP',
    type: 'Subscription',
    amount: '\$ 800.000 COP',
    isSubscription: true,
  ),
  TransactionItem(
    date: 'Oct 15, 2023 - 04:50 PM',
    fundName: 'BTG_PACTUAL_ACCIONES_CO',
    type: 'Cancellation',
    amount: '\$ 3.450.000 COP',
    isSubscription: false,
  ),
];

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BTG Funds',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and track your fund transaction history',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilterIndex == 0,
                    onTap: () => setState(() => _selectedFilterIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Subscriptions',
                    isSelected: _selectedFilterIndex == 1,
                    onTap: () => setState(() => _selectedFilterIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Cancellations',
                    isSelected: _selectedFilterIndex == 2,
                    onTap: () => setState(() => _selectedFilterIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Table Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        dataRowMaxHeight: 70,
                        dataRowMinHeight: 70,
                        columns: [
                          DataColumn(label: _ColumnHeader('DATE & TIME')),
                          DataColumn(label: _ColumnHeader('FUND NAME')),
                          DataColumn(label: _ColumnHeader('TYPE')),
                          DataColumn(label: _ColumnHeader('AMOUNT')),
                        ],
                        rows: _mockTransactions.where((t) {
                          if (_selectedFilterIndex == 1) return t.isSubscription;
                          if (_selectedFilterIndex == 2) return !t.isSubscription;
                          return true;
                        }).map((tx) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  tx.date,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  tx.fundName,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tx.isSubscription
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tx.type,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: tx.isSubscription ? Colors.green[700] : Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  tx.amount,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
