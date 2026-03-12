import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionHistoryUseCase {
  final TransactionRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<List<Transaction>> call() async {
    return repository.getTransactions();
  }
}
