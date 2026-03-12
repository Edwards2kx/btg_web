import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../mappers/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.localDataSource});

  final UserLocalDataSource localDataSource;

  @override
  Future<User> getUserInfo() async {
    final model = await localDataSource.getUserInfo();
    final entity = UserMapper.toEntity(model);
    return entity;
  }
}
