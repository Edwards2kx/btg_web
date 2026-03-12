class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final double balance;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      balance: json['balance'],
    );
  }
}
