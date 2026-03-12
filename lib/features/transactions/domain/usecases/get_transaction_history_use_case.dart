import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionHistoryUseCase {
  final TransactionRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<List<Transaction>> call({TransactionType? type}) async {
    final transactions = await repository.getTransactions(type: type);
    // Sort by date descending (most recent first) — business rule
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}
