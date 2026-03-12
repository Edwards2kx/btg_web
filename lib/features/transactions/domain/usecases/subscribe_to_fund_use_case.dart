import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'get_available_balance_use_case.dart';

class InsufficientBalanceException implements Exception {
  final String message;
  InsufficientBalanceException(this.message);
}

class SubscribeToFundUseCase {
  final TransactionRepository repository;
  final GetAvailableBalanceUseCase getAvailableBalanceUseCase;

  SubscribeToFundUseCase({
    required this.repository,
    required this.getAvailableBalanceUseCase,
  });

  Future<void> call({
    required String fundId,
    required String fundName,
    required double amount,
    required NotificationMethod notificationMethod,
  }) async {
    final balance = await getAvailableBalanceUseCase.call();
    
    if (balance < amount) {
      throw InsufficientBalanceException(
          'No tiene saldo suficiente para suscribirse a $fundName. Saldo disponible: \$$balance, Monto requerido: \$$amount');
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      fundId: fundId,
      fundName: fundName,
      date: DateTime.now(),
      amount: amount,
      type: TransactionType.subscription,
      notificationMethod: notificationMethod,
    );

    await repository.addTransaction(transaction);
  }
}
