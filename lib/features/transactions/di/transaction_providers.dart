import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/cancel_subscription_use_case.dart';
import '../domain/usecases/get_active_subscriptions_use_case.dart';
import '../domain/usecases/get_available_balance_use_case.dart';
import '../domain/usecases/get_transaction_history_use_case.dart';
import '../domain/usecases/subscribe_to_fund_use_case.dart';
import '../data/datasources/transaction_local_datasource.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/entities/transaction.dart';

part 'transaction_providers.g.dart';

// --- Data Layer ---
@Riverpod(keepAlive: true)
TransactionLocalDataSource transactionLocalDataSource(TransactionLocalDataSourceRef ref) {
  return TransactionLocalDataSource();
}

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  final localDataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(localDataSource);
}

// --- Domain Layer (Use Cases) ---
@riverpod
GetAvailableBalanceUseCase getAvailableBalanceUseCase(GetAvailableBalanceUseCaseRef ref) {
  return GetAvailableBalanceUseCase(ref.watch(transactionRepositoryProvider));
}

@riverpod
GetTransactionHistoryUseCase getTransactionHistoryUseCase(GetTransactionHistoryUseCaseRef ref) {
  return GetTransactionHistoryUseCase(ref.watch(transactionRepositoryProvider));
}

@riverpod
GetActiveSubscriptionsUseCase getActiveSubscriptionsUseCase(GetActiveSubscriptionsUseCaseRef ref) {
  return GetActiveSubscriptionsUseCase(ref.watch(transactionRepositoryProvider));
}

@riverpod
SubscribeToFundUseCase subscribeToFundUseCase(SubscribeToFundUseCaseRef ref) {
  return SubscribeToFundUseCase(
    repository: ref.watch(transactionRepositoryProvider),
    getAvailableBalanceUseCase: ref.watch(getAvailableBalanceUseCaseProvider),
  );
}

@riverpod
CancelSubscriptionUseCase cancelSubscriptionUseCase(CancelSubscriptionUseCaseRef ref) {
  return CancelSubscriptionUseCase(ref.watch(transactionRepositoryProvider));
}

// --- UI State Providers ---
@riverpod
Future<double> availableBalance(AvailableBalanceRef ref) {
  return ref.watch(getAvailableBalanceUseCaseProvider).call();
}

@riverpod
Future<List<Transaction>> transactionHistory(TransactionHistoryRef ref) {
  return ref.watch(getTransactionHistoryUseCaseProvider).call();
}

@riverpod
Future<List<Transaction>> activeSubscriptions(ActiveSubscriptionsRef ref) {
  return ref.watch(getActiveSubscriptionsUseCaseProvider).call();
}

@riverpod
bool isValidInvestmentAmount(IsValidInvestmentAmountRef ref, double amount) {
  final balance = ref.watch(availableBalanceProvider).valueOrNull ?? 0.0;
  return amount <= balance;
}
