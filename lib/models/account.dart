class AccountModel {
  String username;
  String password;

  AccountModel({this.username, this.password});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      username: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password
    };
  }
}