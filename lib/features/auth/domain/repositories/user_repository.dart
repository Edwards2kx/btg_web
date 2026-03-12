import 'package:btg_web/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUserInfo();
}
