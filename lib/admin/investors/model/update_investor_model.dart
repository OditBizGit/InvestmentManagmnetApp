import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_submit.dart';

class UpdateInvestorRequestModel {
  final int userId;
  final int? staffId;
  final String? staffName;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? alternativeNumber;
  final String? investorType;
  final String? organization;
  final String? description;
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

  final List<InvestorNomineeSubmitData> nominees;

  // Images
  final MultipartFile? profileImage;
  final MultipartFile? aadhaarCardImage;
  final MultipartFile? panCardImage;

  UpdateInvestorRequestModel({
    required this.userId,
    this.staffId,
    this.staffName,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.alternativeNumber,
    this.investorType,
    this.organization,
    this.description,
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
    this.nominees = const [],
    this.profileImage,
    this.aadhaarCardImage,
    this.panCardImage,
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('UserId', userId.toString()),
      MapEntry('FullName', fullName),

      if (staffId != null && staffId! > 0)
        MapEntry('StaffId', staffId.toString()),

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

      if (_hasValue(description))
        MapEntry('Description', description!),

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
    ]);

    if (profileImage != null) {
      formData.files.add(
        MapEntry('ProfileImage', profileImage!),
      );
    }

    if (aadhaarCardImage != null) {
      formData.files.add(
        MapEntry('AadhaarCardImage', aadhaarCardImage!),
      );
    }

    if (panCardImage != null) {
      formData.files.add(
        MapEntry('PanCardImage', panCardImage!),
      );
    }

    if (nominees.isNotEmpty) {
      appendNomineesToFormData(formData, nominees);
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