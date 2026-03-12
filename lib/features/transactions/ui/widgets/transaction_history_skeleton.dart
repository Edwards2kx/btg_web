import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_history_table.dart';
import 'mobile_transaction_history_list.dart';

/// Mock transactions used to generate skeleton placeholders.
/// The actual text values don't matter — skeletonizer converts
/// them into shimmering blocks of the same dimensions.
final _mockTransactions = List.generate(
  5,
  (i) => Transaction(
    id: 'skeleton_$i',
    fundId: 'fund_$i',
    fundName: 'FPV_BTG_PACTUAL_FONDO',
    date: DateTime.now(),
    amount: 125000.0,
    type: TransactionType.subscription,
  ),
);

/// Desktop skeleton — wraps [TransactionHistoryTable] with mock data.
class TransactionHistoryTableSkeleton extends StatelessWidget {
  const TransactionHistoryTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: TransactionHistoryTable(transactions: _mockTransactions),
    );
  }
}

/// Mobile skeleton — wraps [MobileTransactionHistoryList] with mock data.
class MobileTransactionHistoryListSkeleton extends StatelessWidget {
  const MobileTransactionHistoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: MobileTransactionHistoryList(transactions: _mockTransactions),
    );
  }
}
