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

  /// Existing primary nominee id, or 0 when creating a new nominee.
  final int nomineeId;
  final List<InvestorNomineeSubmitData> nominees;

  // Images — API field names: ProfileImage, AadhaarPhoto, PanCardPhoto
  final MultipartFile? profileImage;
  final MultipartFile? aadhaarPhoto;
  final MultipartFile? panCardPhoto;

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
    this.nomineeId = 0,
    this.nominees = const [],
    this.profileImage,
    this.aadhaarPhoto,
    this.panCardPhoto,
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('UserId', userId.toString()),
      MapEntry('FullName', _text(fullName)),
      MapEntry('Email', _text(email)),
      MapEntry('PhoneNumber', _text(phoneNumber)),
      MapEntry('AlternativeNumber', _text(alternativeNumber)),
      MapEntry('InvestorType', _text(investorType)),
      MapEntry('Organization', _text(organization)),
      MapEntry('Address', _text(address)),
      MapEntry('AadhaarNumber', _text(aadhaarNumber)),
      MapEntry('PanCardNumber', _text(panCardNumber)),
      MapEntry('AccountNumber', _text(accountNumber)),
      MapEntry('IFSCCode', _text(ifscCode)),
      MapEntry('BankName', _text(bankName)),
      MapEntry('DateOfBirth', _date(dateOfBirth)),
      MapEntry(
        'StaffId',
        staffId != null && staffId! > 0 ? staffId.toString() : '',
      ),
      MapEntry('Description', _text(description)),
      MapEntry('InvestmentAmount', investmentAmount.toString()),
      MapEntry('InvestmentDate', _date(investmentDate)),
      MapEntry('InvestmentSplitMonths', investmentSplitMonths.toString()),
      MapEntry('InvestmentSplitType', _text(investmentSplitType)),
      MapEntry('InvestmentSplitGap', investmentSplitGap.toString()),
      MapEntry(
        'InvestmentAdvanceAmount',
        investmentAdvanceAmount.toString(),
      ),
      MapEntry('PaymentMethod', _text(paymentMethod)),
    ]);

    if (profileImage != null) {
      formData.files.add(MapEntry('ProfileImage', profileImage!.clone()));
    }
    if (aadhaarPhoto != null) {
      formData.files.add(MapEntry('AadhaarPhoto', aadhaarPhoto!.clone()));
    }
    if (panCardPhoto != null) {
      formData.files.add(MapEntry('PanCardPhoto', panCardPhoto!.clone()));
    }

    appendUpdateInvestorNomineesToFormData(formData, nominees);

    return formData;
  }

  static String _text(String? value) => value?.trim() ?? '';

  static String _date(DateTime? value) =>
      value?.toIso8601String() ?? '';
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