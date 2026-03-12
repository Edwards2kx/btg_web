import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/get_active_subscriptions_use_case.dart';

class MockTransactionRepository implements TransactionRepository {
  List<Transaction> transactionsToReturn = [];

  @override
  Future<List<Transaction>> getTransactions() async {
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

  test('should return list of active subscriptions resolving cancellations', () async {
    // Arrange
    repository.transactionsToReturn = [
      Transaction(
        id: '1',
        date: DateTime.now(),
        amount: 500000.0,
        type: TransactionType.deposit,
      ),
      Transaction( // Subscribed to FPV_BTG_PACTUAL_RECAUDADORA
        id: '2',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        date: DateTime.now(),
        amount: 75000.0,
        type: TransactionType.subscription,
      ),
      Transaction( // Subscribed to FPV_BTG_PACTUAL_ECOPETROL
        id: '3',
        fundId: '2',
        fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
        date: DateTime.now(),
        amount: 125000.0,
        type: TransactionType.subscription,
      ),
      Transaction( // Cancelled FPV_BTG_PACTUAL_RECAUDADORA
        id: '4',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        date: DateTime.now(),
        amount: 75000.0,
        type: TransactionType.cancellation,
      ),
    ];

    // Act
    final result = await useCase.call();

    // Assert
    // Verify there is only one active subscription (EcoPetrol) because Recaudadora was cancelled.
    expect(
        result,
        predicate((List<Transaction> list) =>
            list.length == 1 && list.first.fundId == '2'));
  });
}
