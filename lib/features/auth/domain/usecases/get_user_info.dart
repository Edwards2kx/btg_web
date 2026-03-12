import 'package:btg_web/features/auth/domain/entities/user.dart';
import 'package:btg_web/features/auth/domain/repositories/user_repository.dart';

class GetUserInfoUseCase {
  GetUserInfoUseCase({required this.repository});

  final UserRepository repository;

  Future<User> call() async {
    return repository.getUserInfo();
  }
}
