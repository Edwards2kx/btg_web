import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<List<Transaction>> getTransactions({TransactionType? type}) async {
    return await localDataSource.getTransactions(type: type);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await localDataSource.addTransaction(model);
  }
}
