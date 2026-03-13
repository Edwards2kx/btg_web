import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/get_active_subscriptions_use_case.dart';

class MockTransactionRepository implements TransactionRepository {
  List<Transaction> transactionsToReturn = [];

  @override
  Future<List<Transaction>> getTransactions({TransactionType? type}) async {
    return transactionsToReturn;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    // Not needed for this test
  }
}

void main() {
  late GetActiveSubscriptionsUseCase useCase;
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
    useCase = GetActiveSubscriptionsUseCase(repository);
  });

  test('should return empty list when there are no transactions', () async {
    // Arrange
    repository.transactionsToReturn = [];

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, isEmpty);
  });

  test('should return list of active subscriptions grouping by fund and evaluating cancellations', () async {
    // Arrange
    repository.transactionsToReturn = [
      Transaction(
        id: '1',
        date: DateTime.now(),
        amount: 500000.0,
        type: TransactionType.deposit,
      ),
      Transaction( // Subscribed to FPV_BTG_PACTUAL_RECAUDADORA (First time) - 75k
        id: '2',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        date: DateTime.now(),
        amount: 75000.0,
        type: TransactionType.subscription,
      ),
      Transaction( // Subscribed to FPV_BTG_PACTUAL_ECOPETROL - 125k
        id: '3',
        fundId: '2',
        fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
        date: DateTime.now(),
        amount: 125000.0,
        type: TransactionType.subscription,
      ),
      Transaction( // Subscribed to FPV_BTG_PACTUAL_RECAUDADORA (Second time) - 20k
        id: '4',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        date: DateTime.now(),
        amount: 20000.0,
        type: TransactionType.subscription,
      ),
      Transaction( // Partial liquidation of FPV_BTG_PACTUAL_ECOPETROL - 50k
        id: '5',
        fundId: '2',
        fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
        date: DateTime.now(),
        amount: 50000.0,
        type: TransactionType.cancellation,
      ),
      Transaction( // Full liquidation of FPV_BTG_PACTUAL_RECAUDADORA - 95k
        id: '6',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        date: DateTime.now(),
        amount: 95000.0,
        type: TransactionType.cancellation,
      ),
    ];

    // Act
    final result = await useCase.call();

    // Assert
    // Verify there is only one active subscription remaining:
    // Recaudadora: 75k + 20k - 95k = 0 (Should be removed)
    // Ecopetrol: 125k - 50k = 75k (Should remain)
    expect(result.length, equals(1));
    final ecopetrol = result.first;
    expect(ecopetrol.fundId, equals('2'));
    expect(ecopetrol.amount, equals(75000.0));
  });
}
