import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CancelSubscriptionUseCase {
  final TransactionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  Future<void> call({
    required String fundId,
    required String fundName,
    required double amount,
  }) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      fundId: fundId,
      fundName: fundName,
      date: DateTime.now(),
      amount: amount,
      type: TransactionType.cancellation,
    );

    await repository.addTransaction(transaction);
  }
}
