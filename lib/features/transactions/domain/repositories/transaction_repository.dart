import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions({TransactionType? type});
  Future<void> addTransaction(Transaction transaction);
}
