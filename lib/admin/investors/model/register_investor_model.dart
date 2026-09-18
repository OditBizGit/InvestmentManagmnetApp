import 'package:dio/dio.dart';

class RegisterInvestorRequestModel {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String alternativeNumber;
  final String investorType;
  final String organization;
  final String address;

  final double? investmentAmount;
  final DateTime investmentDate;

  final int investmentSplitMonths;
  final String investmentSplitType;
  final int investmentSplitGap;
  final double investmentAdvanceAmount;
  final String paymentMethod;

  final String aadhaarNumber;
  final String panCardNumber;
  final String accountNumber;
  final String ifscCode;
  final String bankName;

  final DateTime? dateOfBirth;

  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String nomineeAadhaarNumber;
  final String nomineePanCardNumber;
  final String nomineePhoneNumber;

  final MultipartFile? profileImage;
  final MultipartFile? nomineeProfilePhoto;

  RegisterInvestorRequestModel({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.alternativeNumber,
    required this.investorType,
    required this.organization,
    required this.address,
    this.investmentAmount,
    required this.investmentDate,
    required this.investmentSplitMonths,
    required this.investmentSplitType,
    required this.investmentSplitGap,
    required this.investmentAdvanceAmount,
    required this.paymentMethod,
    required this.aadhaarNumber,
    required this.panCardNumber,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.dateOfBirth,
    required this.nomineeName,
    required this.nomineeRelationship,
    required this.nomineeAddress,
    this.nomineeDateOfBirth,
    required this.nomineeAadhaarNumber,
    required this.nomineePanCardNumber,
    required this.nomineePhoneNumber,
    this.profileImage,
    this.nomineeProfilePhoto,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'Username': username,
      'Password': password,
      'FullName': fullName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'AlternativeNumber': alternativeNumber,
      'InvestorType': investorType,
      'Organization': organization,
      'Address': address,

      'InvestmentAmount': investmentAmount,
      'InvestmentDate': investmentDate.toIso8601String(),

      'InvestmentSplitMonths': investmentSplitMonths,
      'InvestmentSplitType': investmentSplitType,
      'InvestmentSplitGap': investmentSplitGap,
      'InvestmentAdvanceAmount': investmentAdvanceAmount,
      'PaymentMethod': paymentMethod,

      'AadhaarNumber': aadhaarNumber,
      'PanCardNumber': panCardNumber,
      'AccountNumber': accountNumber,
      'IFSCCode': ifscCode,
      'BankName': bankName,

      if (dateOfBirth != null) 'DateOfBirth': dateOfBirth!.toIso8601String(),

      'NomineeName': nomineeName,
      'NomineeRelationship': nomineeRelationship,
      'NomineeAddress': nomineeAddress,
      if (nomineeDateOfBirth != null)
        'NomineeDateOfBirth': nomineeDateOfBirth!.toIso8601String(),
      'NomineeAadhaarNumber': nomineeAadhaarNumber,
      'NomineePanCardNumber': nomineePanCardNumber,
      'NomineePhoneNumber': nomineePhoneNumber,

      if (profileImage != null)
        'ProfileImage': profileImage,

      if (nomineeProfilePhoto != null)
        'NomineeProfilePhoto': nomineeProfilePhoto,
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

  final int investmentSplitMonths;
  final double monthlyInvestmentAmount;
  final DateTime? investmentStartDate;

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
    required this.investmentSplitMonths,
    required this.monthlyInvestmentAmount,
    this.investmentStartDate,
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

      phoneNumber:
      json['PhoneNumber'] ?? json['phoneNumber'],

      profileImage:
      json['ProfileImage'] ?? json['profileImage'],

      investorCode:
      json['InvestorCode'] ?? json['investorCode'],

      investorType:
      json['InvestorType'] ?? json['investorType'],

      organization:
      json['Organization'] ?? json['organization'],

      address:
      json['Address'] ?? json['address'],

      investmentSplitMonths:
      json['InvestmentSplitMonths'] ??
          json['investmentSplitMonths'] ??
          0,

      monthlyInvestmentAmount:
      (json['MonthlyInvestmentAmount'] ??
          json['monthlyInvestmentAmount'] ??
          0)
          .toDouble(),

      investmentStartDate:
      (json['InvestmentStartDate'] ??
          json['investmentStartDate']) !=
          null
          ? DateTime.tryParse(
        json['InvestmentStartDate'] ??
            json['investmentStartDate'],
      )
          : null,

      userRole:
      json['UserRole'] ?? json['userRole'] ?? '',

      isActive:
      json['IsActive'] ?? json['isActive'] ?? false,

      createdDate:
      (json['CreatedDate'] ?? json['createdDate']) !=
          null
          ? DateTime.tryParse(
        json['CreatedDate'] ??
            json['createdDate'],
      )
          : null,
    );
  }
}