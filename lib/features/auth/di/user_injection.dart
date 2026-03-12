import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/user_local_datasource.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/get_user_info.dart';

part 'user_injection.g.dart';

@riverpod
UserLocalDataSource userLocalDataSource(Ref ref) {
  return UserLocalDataSource();
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(
    localDataSource: ref.watch(userLocalDataSourceProvider),
  );
}

@riverpod
GetUserInfoUseCase getUserInfoUseCase(Ref ref) {
  return GetUserInfoUseCase(
    repository: ref.watch(userRepositoryProvider),
  );
}
