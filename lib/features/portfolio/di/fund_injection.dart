import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/funds_local_datasource.dart';
import '../data/repositories/fund_repository_impl.dart';
import '../domain/repositories/fund_repository.dart';
import '../domain/usecases/get_available_funds.dart';

part 'fund_injection.g.dart';

@riverpod
FundsLocalDataSource fundsLocalDataSource(Ref ref) {
  return FundsLocalDataSource();
}

@riverpod
FundRepository fundRepository(Ref ref) {
  return FundRepositoryImpl(
    localDataSource: ref.watch(fundsLocalDataSourceProvider),
  );
}

@riverpod
GetAvailableFundsUseCase getAvailableFundsUseCase(Ref ref) {
  return GetAvailableFundsUseCase(
    repository: ref.watch(fundRepositoryProvider),
  );
}
