class CreateAdminModel {
  // Request fields
  final String? username;
  final String? password;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? alternativeNumber;

  // Response fields
  final int? userId;
  final String? userRole;
  final bool? isActive;
  final String? createdDate;

  CreateAdminModel({
    this.username,
    this.password,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.alternativeNumber,
    this.userId,
    this.userRole,
    this.isActive,
    this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'alternativeNumber': alternativeNumber,
    };
  }

  factory CreateAdminModel.fromJson(Map<String, dynamic> json) {
    return CreateAdminModel(
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      alternativeNumber: json['alternativeNumber'],
      userRole: json['userRole'],
      isActive: json['isActive'],
      createdDate: json['createdDate'],
    );
  }
}