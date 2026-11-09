class LoginRequestModel {
  final String username;
  final String password;
  final String? userRole;

  LoginRequestModel({
    required this.username,
    required this.password,
    this.userRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (userRole != null) 'userRole': userRole,
    };
  }
}
