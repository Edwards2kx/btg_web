import '../models/user_model.dart';

const double kUserInitialBalance = 500000.0;

class UserLocalDataSource {
  Future<UserModel> getUserInfo() async {
    //mock delay and data
    await Future.delayed(const Duration(seconds: 2));
    final Map<String, dynamic> json = {
      "id": "1",
      "firstName": "John",
      "lastName": "Doe",
      "balance": kUserInitialBalance,
    };

    return UserModel.fromJson(json);
  }
}
