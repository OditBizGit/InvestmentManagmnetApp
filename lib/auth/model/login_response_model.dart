class LoginResponseModel {
  final bool status;
  final String message;
  final LoginDataModel? data;
  final int code;

  LoginResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? LoginDataModel.fromJson(json['data'])
          : null,
      code: json['code'] ?? 0,
    );
  }
}

class LoginDataModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? investorCode;
  final String? profileImage;
  final String userRole;
  final String token;

  LoginDataModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.investorCode,
    this.profileImage,
    required this.userRole,
    required this.token,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      investorCode: json['investorCode'],
      profileImage: json['profileImage'],
      userRole: json['userRole'] ?? '',
      token: json['token'] ?? '',
    );
  }
}