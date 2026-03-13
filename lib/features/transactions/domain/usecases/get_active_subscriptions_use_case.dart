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
        if (activeSubscriptions.containsKey(transaction.fundId!)) {
          // Accumulate the amount for the same fund
          final existing = activeSubscriptions[transaction.fundId!]!;
          activeSubscriptions[transaction.fundId!] = existing.copyWith(
            amount: existing.amount + transaction.amount,
          );
        } else {
          // Add new fund subscription
          activeSubscriptions[transaction.fundId!] = transaction;
        }
      } else if (transaction.type == TransactionType.cancellation) {
        if (activeSubscriptions.containsKey(transaction.fundId!)) {
          // Subtract the cancelled amount
          final existing = activeSubscriptions[transaction.fundId!]!;
          final newAmount = existing.amount - transaction.amount;
          
          // Using a small epsilon to account for floating-point inaccuracies
          if (newAmount <= 0.01) { 
            activeSubscriptions.remove(transaction.fundId!);
          } else {
            activeSubscriptions[transaction.fundId!] = existing.copyWith(
              amount: newAmount,
            );
          }
        }
      }
    }

    final result = activeSubscriptions.values.toList();
    result.sort((a, b) => (a.fundName ?? '').compareTo(b.fundName ?? ''));
    return result;
  }
}
