import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/cancel_subscription_use_case.dart';

// Manual Mock to respect FIRST (Independent, Fast) avoiding mockito overhead
class MockTransactionRepository implements TransactionRepository {
  List<Transaction> savedTransactions = [];

  @override
  Future<List<Transaction>> getTransactions({TransactionType? type}) async {
    return savedTransactions;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    savedTransactions.add(transaction);
  }
}

void main() {
  late CancelSubscriptionUseCase useCase;
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
    useCase = CancelSubscriptionUseCase(repository);
  });

  test('should create and add a cancellation transaction to the repository', () async {
    // Arrange
    const fundId = 'fund_1';
    const fundName = 'Fund 1';
    const amount = 50000.0;

    // Act
    await useCase.call(
      fundId: fundId,
      fundName: fundName,
      amount: amount,
    );

    // Assert
    expect(repository.savedTransactions.length, equals(1));
    final transaction = repository.savedTransactions.first;
    expect(transaction.fundId, equals(fundId));
    expect(transaction.fundName, equals(fundName));
    expect(transaction.amount, equals(amount));
    expect(transaction.type, equals(TransactionType.cancellation));
    expect(transaction.notificationMethod, isNull); // Optional, typically null for cancellation here
  });
}
