import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetActiveSubscriptionsUseCase {
  final TransactionRepository repository;

  GetActiveSubscriptionsUseCase(this.repository);

  Future<List<Transaction>> call() async {
    final transactions = await repository.getTransactions();
    final Map<String, Transaction> activeSubscriptions = {};

    for (final transaction in transactions) {
      if (transaction.fundId == null) continue;

      if (transaction.type == TransactionType.subscription) {
        activeSubscriptions[transaction.fundId!] = transaction;
      } else if (transaction.type == TransactionType.cancellation) {
        activeSubscriptions.remove(transaction.fundId!);
      }
    }

    final result = activeSubscriptions.values.toList();
    result.sort((a, b) => (a.fundName ?? '').compareTo(b.fundName ?? ''));
    return result;
  }
}
