import 'package:flutter_test/flutter_test.dart';
import 'package:btg_web/features/transactions/domain/entities/transaction.dart';
import 'package:btg_web/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_web/features/transactions/domain/usecases/get_available_balance_use_case.dart';
import 'package:btg_web/features/transactions/domain/usecases/subscribe_to_fund_use_case.dart';

// Manual Mocks to respect FIRST (Independent, Fast)
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

class MockGetAvailableBalanceUseCase implements GetAvailableBalanceUseCase {
  double balanceToReturn = 0.0;
  
  @override
  final TransactionRepository repository;

  MockGetAvailableBalanceUseCase(this.repository);

  @override
  Future<double> call() async {
    return balanceToReturn;
  }
}

void main() {
  late SubscribeToFundUseCase useCase;
  late MockTransactionRepository repository;
  late MockGetAvailableBalanceUseCase getAvailableBalanceUseCase;

  setUp(() {
    repository = MockTransactionRepository();
    getAvailableBalanceUseCase = MockGetAvailableBalanceUseCase(repository);
    useCase = SubscribeToFundUseCase(
      repository: repository,
      getAvailableBalanceUseCase: getAvailableBalanceUseCase,
    );
  });

  test('should successfully create and add a subscription transaction when balance is sufficient', () async {
    // Arrange
    const fundId = 'fund_1';
    const fundName = 'Fund 1';
    const amount = 50000.0;
    const notification = NotificationMethod.email;
    
    getAvailableBalanceUseCase.balanceToReturn = 100000.0; // Sufficient balance

    // Act
    await useCase.call(
      fundId: fundId,
      fundName: fundName,
      amount: amount,
      notificationMethod: notification,
    );

    // Assert
    expect(repository.savedTransactions.length, equals(1));
    final transaction = repository.savedTransactions.first;
    expect(transaction.fundId, equals(fundId));
    expect(transaction.fundName, equals(fundName));
    expect(transaction.amount, equals(amount));
    expect(transaction.type, equals(TransactionType.subscription));
    expect(transaction.notificationMethod, equals(notification));
  });

  test('should throw InsufficientBalanceException when balance is less than required amount', () async {
    // Arrange
    const fundId = 'fund_1';
    const fundName = 'Fund 1';
    const amount = 50000.0;
    const notification = NotificationMethod.sms;
    
    getAvailableBalanceUseCase.balanceToReturn = 20000.0; // Insufficient balance

    // Act & Assert
    expect(
      () => useCase.call(
        fundId: fundId,
        fundName: fundName,
        amount: amount,
        notificationMethod: notification,
      ),
      throwsA(isA<InsufficientBalanceException>()
          .having((e) => e.message, 'message', contains('No tiene saldo suficiente'))),
    );
    
    // Assure no transaction was added
    expect(repository.savedTransactions.isEmpty, isTrue);
  });
}
