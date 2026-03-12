import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/get_transaction_history_use_case.dart';

// Manual Mock to respect FIRST (Independent, Fast)
class MockTransactionRepository implements TransactionRepository {
  List<Transaction> transactionsToReturn = [];

  @override
  Future<List<Transaction>> getTransactions({TransactionType? type}) async {
    if (type != null) {
      return transactionsToReturn.where((t) => t.type == type).toList();
    }
    return transactionsToReturn;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    // Not needed here
  }
}

void main() {
  late GetTransactionHistoryUseCase useCase;
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
    useCase = GetTransactionHistoryUseCase(repository);
  });

  test('should retrieve transactions and sort them by date descending (most recent first)', () async {
    // Arrange
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    repository.transactionsToReturn = [
      Transaction(id: '1', date: today, amount: 100, type: TransactionType.deposit),
      Transaction(id: '2', date: yesterday, amount: 200, type: TransactionType.deposit),
      Transaction(id: '3', date: tomorrow, amount: 300, type: TransactionType.subscription),
    ];

    // Act
    final result = await useCase.call();

    // Assert
    expect(result.length, equals(3));
    // Ordered: tomorrow, today, yesterday
    expect(result[0].id, equals('3')); // tomorrow
    expect(result[1].id, equals('1')); // today
    expect(result[2].id, equals('2')); // yesterday
  });

  test('should filter by TransactionType if provided', () async {
    // Arrange
    final today = DateTime.now();
    
    repository.transactionsToReturn = [
      Transaction(id: '1', date: today, amount: 100, type: TransactionType.deposit),
      Transaction(id: '2', date: today, amount: 200, type: TransactionType.subscription),
      Transaction(id: '3', date: today, amount: 300, type: TransactionType.cancellation),
    ];

    // Act
    final result = await useCase.call(type: TransactionType.subscription);

    // Assert
    expect(result.length, equals(1));
    expect(result[0].id, equals('2'));
    expect(result[0].type, equals(TransactionType.subscription));
  });
}
