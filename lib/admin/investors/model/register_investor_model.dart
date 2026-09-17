import 'package:dio/dio.dart';

class RegisterInvestorRequestModel {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String investorType;
  final String organization;
  final String address;
  final double? investmentAmount;
  final DateTime investmentDate;
  final MultipartFile? profileImage;

  RegisterInvestorRequestModel({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.investorType,
    required this.organization,
    required this.address,
    this.investmentAmount,
    required this.investmentDate,
    this.profileImage,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'Username': username,
      'Password': password,
      'FullName': fullName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'InvestorType': investorType,
      'Organization': organization,
      'Address': address,
      'InvestmentAmount': investmentAmount,
      'InvestmentDate': investmentDate.toIso8601String(),
      if (profileImage != null) 'ProfileImage': profileImage,
    });
  }
}

class RegisterInvestorResponseModel {
  final bool status;
  final String message;
  final RegisterInvestorDataModel? data;
  final int code;

  RegisterInvestorResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory RegisterInvestorResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RegisterInvestorResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RegisterInvestorDataModel.fromJson(json['data'])
          : null,
      code: json['code'] ?? 0,
    );
  }
}

class RegisterInvestorDataModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? investorCode;
  final String? investorType;
  final String? organization;
  final String? address;
  final String userRole;
  final bool isActive;
  final DateTime? createdDate;

  RegisterInvestorDataModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.investorCode,
    this.investorType,
    this.organization,
    this.address,
    required this.userRole,
    required this.isActive,
    this.createdDate,
  });

  factory RegisterInvestorDataModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RegisterInvestorDataModel(
      userId: json['UserId'] ?? json['userId'] ?? 0,
      username: json['Username'] ?? json['username'] ?? '',
      fullName: json['FullName'] ?? json['fullName'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'],
      profileImage: json['ProfileImage'] ?? json['profileImage'],
      investorCode: json['InvestorCode'] ?? json['investorCode'],
      investorType: json['InvestorType'] ?? json['investorType'],
      organization: json['Organization'] ?? json['organization'],
      address: json['Address'] ?? json['address'],
      userRole: json['UserRole'] ?? json['userRole'] ?? '',
      isActive: json['IsActive'] ?? json['isActive'] ?? false,
      createdDate: (json['CreatedDate'] ?? json['createdDate']) != null
          ? DateTime.tryParse(
        json['CreatedDate'] ?? json['createdDate'],
      )
          : null,
    );
  }
}