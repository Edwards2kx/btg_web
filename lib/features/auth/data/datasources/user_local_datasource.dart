import '../models/user_model.dart';

class UserLocalDataSource {
  Future<UserModel> getUserInfo() async {
    //mock delay and data
    await Future.delayed(const Duration(seconds: 2));
    final Map<String, dynamic> json = {
      "id": "1",
      "firstName": "John",
      "lastName": "Doe",
    };

    return UserModel.fromJson(json);
  }
}
