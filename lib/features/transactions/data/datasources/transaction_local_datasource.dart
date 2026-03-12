import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

class TransactionLocalDataSource {
  // In-memory list to act as the single source of truth for the session
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'init_deposit',
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 500000.0,
      type: TransactionType.deposit,
    ),
  ];

  Future<List<TransactionModel>> getTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_transactions);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _transactions.add(transaction);
  }
}
