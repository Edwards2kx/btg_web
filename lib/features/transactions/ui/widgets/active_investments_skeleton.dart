import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/transaction.dart';
import 'active_investments_table.dart';
import 'mobile_active_investments_list.dart';

final _mockSubscriptions = List.generate(
  3,
  (i) => Transaction(
    id: 'skeleton_$i',
    fundId: 'fund_$i',
    fundName: 'FPV_BTG_PACTUAL_FONDO_MOCK',
    date: DateTime.now(),
    amount: 1000000.0,
    type: TransactionType.subscription,
  ),
);

class ActiveInvestmentsTableSkeleton extends StatelessWidget {
  const ActiveInvestmentsTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ActiveInvestmentsTable(
        subscriptions: _mockSubscriptions,
        onLiquidate: (_) {},
      ),
    );
  }
}

class MobileActiveInvestmentsListSkeleton extends StatelessWidget {
  const MobileActiveInvestmentsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: MobileActiveInvestmentsList(
        subscriptions: _mockSubscriptions,
        onLiquidate: (_) {},
      ),
    );
  }
}
