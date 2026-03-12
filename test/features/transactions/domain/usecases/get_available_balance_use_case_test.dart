import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/get_available_balance_use_case.dart';

// Manual Mock to respect FIRST (Independent, Fast) avoiding mockito code-gen overhead
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
  late GetAvailableBalanceUseCase useCase;
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
    useCase = GetAvailableBalanceUseCase(repository);
  });

  test('should return 0.0 when there are no transactions', () async {
    // Arrange
    repository.transactionsToReturn = [];

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, equals(0.0));
  });

  test('should compute correct balance from deposits, subscriptions, and cancellations', () async {
    // Arrange
    repository.transactionsToReturn = [
      Transaction(
        id: '1',
        date: DateTime.now(),
        amount: 500000.0,
        type: TransactionType.deposit,
      ),
      Transaction(
        id: '2',
        fundId: 'fund_1',
        date: DateTime.now(),
        amount: 75000.0,
        type: TransactionType.subscription,
      ),
      Transaction(
        id: '3',
        fundId: 'fund_1', // Canceling the same fund
        date: DateTime.now(),
        amount: 75000.0,
        type: TransactionType.cancellation,
      ),
      Transaction(
        id: '4',
        fundId: 'fund_2',
        date: DateTime.now(),
        amount: 100000.0,
        type: TransactionType.subscription,
      ),
    ];

    // Act
    final result = await useCase.call();

    // Assert (Initial 500.000 - 75.000 + 75.000 - 100.000 = 400.000)
    expect(result, equals(400000.0));
  });
}
