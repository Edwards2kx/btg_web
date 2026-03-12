import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class UserMapper {
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
    );
  }
}
