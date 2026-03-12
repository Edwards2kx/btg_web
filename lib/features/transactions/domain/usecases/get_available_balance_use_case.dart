import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetAvailableBalanceUseCase {
  final TransactionRepository repository;

  GetAvailableBalanceUseCase(this.repository);

  Future<double> call() async {
    final transactions = await repository.getTransactions();
    double balance = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.deposit ||
          transaction.type == TransactionType.cancellation) {
        balance += transaction.amount;
      } else if (transaction.type == TransactionType.subscription) {
        balance -= transaction.amount;
      }
    }
    
    return balance;
  }
}
