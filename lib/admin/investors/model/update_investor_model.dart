import 'package:dio/dio.dart';

class UpdateInvestorRequestModel {
  final int userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? alternativeNumber;
  final String? investorType;
  final String? organization;
  final String? address;

  // KYC / Bank
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final DateTime? dateOfBirth;

  // Investment
  final double investmentAmount;
  final DateTime? investmentDate;
  final int investmentSplitMonths;
  final String? investmentSplitType;
  final int investmentSplitGap;
  final double investmentAdvanceAmount;
  final String? paymentMethod;

  // Nominee
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String? nomineeAadhaarNumber;
  final String? nomineePanCardNumber;
  final String? nomineePhoneNumber;

  // Images
  final MultipartFile? profileImage;
  final MultipartFile? nomineeProfilePhoto;

  UpdateInvestorRequestModel({
    required this.userId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.alternativeNumber,
    this.investorType,
    this.organization,
    this.address,
    this.aadhaarNumber,
    this.panCardNumber,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.dateOfBirth,
    this.investmentAmount = 0,
    this.investmentDate,
    this.investmentSplitMonths = 0,
    this.investmentSplitType,
    this.investmentSplitGap = 0,
    this.investmentAdvanceAmount = 0,
    this.paymentMethod,
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineeAddress,
    this.nomineeDateOfBirth,
    this.nomineeAadhaarNumber,
    this.nomineePanCardNumber,
    this.nomineePhoneNumber,
    this.profileImage,
    this.nomineeProfilePhoto,
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('UserId', userId.toString()),
      MapEntry('FullName', fullName),

      if (_hasValue(email))
        MapEntry('Email', email!),

      if (_hasValue(phoneNumber))
        MapEntry('PhoneNumber', phoneNumber!),

      if (_hasValue(alternativeNumber))
        MapEntry('AlternativeNumber', alternativeNumber!),

      if (_hasValue(investorType))
        MapEntry('InvestorType', investorType!),

      if (_hasValue(organization))
        MapEntry('Organization', organization!),

      if (_hasValue(address))
        MapEntry('Address', address!),

      // KYC / Bank
      if (_hasValue(aadhaarNumber))
        MapEntry('AadhaarNumber', aadhaarNumber!),

      if (_hasValue(panCardNumber))
        MapEntry('PanCardNumber', panCardNumber!),

      if (_hasValue(accountNumber))
        MapEntry('AccountNumber', accountNumber!),

      if (_hasValue(ifscCode))
        MapEntry('IFSCCode', ifscCode!),

      if (_hasValue(bankName))
        MapEntry('BankName', bankName!),

      if (dateOfBirth != null)
        MapEntry(
          'DateOfBirth',
          dateOfBirth!.toIso8601String(),
        ),

      // Investment
      MapEntry(
        'InvestmentAmount',
        investmentAmount.toString(),
      ),

      if (investmentDate != null)
        MapEntry(
          'InvestmentDate',
          investmentDate!.toIso8601String(),
        ),

      MapEntry(
        'InvestmentSplitMonths',
        investmentSplitMonths.toString(),
      ),

      if (_hasValue(investmentSplitType))
        MapEntry(
          'InvestmentSplitType',
          investmentSplitType!,
        ),

      MapEntry(
        'InvestmentSplitGap',
        investmentSplitGap.toString(),
      ),

      MapEntry(
        'InvestmentAdvanceAmount',
        investmentAdvanceAmount.toString(),
      ),

      if (_hasValue(paymentMethod))
        MapEntry(
          'PaymentMethod',
          paymentMethod!,
        ),

      // Nominee
      if (_hasValue(nomineeName))
        MapEntry('NomineeName', nomineeName!),

      if (_hasValue(nomineeRelationship))
        MapEntry(
          'NomineeRelationship',
          nomineeRelationship!,
        ),

      if (_hasValue(nomineeAddress))
        MapEntry(
          'NomineeAddress',
          nomineeAddress!,
        ),

      if (nomineeDateOfBirth != null)
        MapEntry(
          'NomineeDateOfBirth',
          nomineeDateOfBirth!.toIso8601String(),
        ),

      if (_hasValue(nomineeAadhaarNumber))
        MapEntry(
          'NomineeAadhaarNumber',
          nomineeAadhaarNumber!,
        ),

      if (_hasValue(nomineePanCardNumber))
        MapEntry(
          'NomineePanCardNumber',
          nomineePanCardNumber!,
        ),

      if (_hasValue(nomineePhoneNumber))
        MapEntry(
          'NomineePhoneNumber',
          nomineePhoneNumber!,
        ),
    ]);

    if (profileImage != null) {
      formData.files.add(
        MapEntry('ProfileImage', profileImage!),
      );
    }

    if (nomineeProfilePhoto != null) {
      formData.files.add(
        MapEntry('NomineeProfilePhoto', nomineeProfilePhoto!),
      );
    }

    return formData;
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}


/// Response model for UpdateInvestor API
class UpdateInvestorResponseModel {
  final bool status;
  final String message;
  final String? data;
  final int code;

  UpdateInvestorResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory UpdateInvestorResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return UpdateInvestorResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data']?.toString(),
      code: _readInt(json['code']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}