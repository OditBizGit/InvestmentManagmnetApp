import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_record.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_submit.dart';

class RegisterInvestorRequestModel {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String alternativeNumber;
  final String investorType;
  final int staffId;
  final String organization;
  final String description;
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

  final List<InvestorNomineeSubmitData> nominees;

  final MultipartFile? profileImage;
  final MultipartFile? aadhaarCardImage;
  final MultipartFile? panCardImage;

  RegisterInvestorRequestModel({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.alternativeNumber,
    required this.investorType,
    required this.staffId,
    required this.organization,
    this.description = '',
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
    this.nominees = const [],
    this.profileImage,
    this.aadhaarCardImage,
    this.panCardImage,
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('Username', username),
      MapEntry('Password', password),
      MapEntry('FullName', fullName),
      MapEntry('StaffId', staffId.toString()),
      MapEntry('Email', email),
      MapEntry('PhoneNumber', phoneNumber),
      MapEntry('AlternativeNumber', alternativeNumber),
      MapEntry('InvestorType', investorType),
      MapEntry('Organization', organization),
      MapEntry('Description', description.trim()),
      MapEntry('Address', address),
      MapEntry(
        'InvestmentAmount',
        (investmentAmount ?? 0).toString(),
      ),
      MapEntry('InvestmentDate', investmentDate.toIso8601String()),
      MapEntry('InvestmentSplitMonths', investmentSplitMonths.toString()),
      MapEntry('InvestmentSplitType', investmentSplitType),
      MapEntry('InvestmentSplitGap', investmentSplitGap.toString()),
      MapEntry('InvestmentAdvanceAmount', investmentAdvanceAmount.toString()),
      MapEntry('PaymentMethod', paymentMethod),
      MapEntry('AadhaarNumber', aadhaarNumber),
      MapEntry('PanCardNumber', panCardNumber),
      MapEntry('AccountNumber', accountNumber),
      MapEntry('IFSCCode', ifscCode),
      MapEntry('BankName', bankName),
      MapEntry(
        'DateOfBirth',
        dateOfBirth?.toIso8601String() ?? '',
      ),
    ]);

    if (profileImage != null) {
      formData.files.add(MapEntry('ProfileImage', profileImage!));
    }
    if (aadhaarCardImage != null) {
      formData.files.add(MapEntry('AadhaarPhoto', aadhaarCardImage!));
    }
    if (panCardImage != null) {
      formData.files.add(MapEntry('PanCardPhoto', panCardImage!));
    }

    appendRegisterInvestorNomineesToFormData(formData, nominees);

    return formData;
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
      status: _readBool(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: _readDataMap(json) != null
          ? RegisterInvestorDataModel.fromJson(_readDataMap(json)!)
          : null,
      code: _readInt(json['code'] ?? json['Code']),
    );
  }

  static Map<String, dynamic>? _readDataMap(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['Data'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'success';
    }
    return false;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class RegisterInvestorDataModel {
  RegisterInvestorDataModel({
    this.nomineesJson,
    this.isValidJson,
    this.parsedNominees = const [],
  });

  final String? nomineesJson;
  final int? isValidJson;
  final List<InvestorNomineeRecord> parsedNominees;

  factory RegisterInvestorDataModel.fromJson(Map<String, dynamic> json) {
    final nomineesRaw = json['NomineesJson'] ??
        json['nomineesJson'] ??
        json['NomineesJSON'];
    final nomineesJson = nomineesRaw?.toString();

    return RegisterInvestorDataModel(
      nomineesJson: nomineesJson,
      isValidJson: _readOptionalInt(
        json['IsValidJson'] ?? json['isValidJson'],
      ),
      parsedNominees: _parseNomineesJson(nomineesJson),
    );
  }

  static int? _readOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static List<InvestorNomineeRecord> _parseNomineesJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (item) => InvestorNomineeRecord.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((record) => !record.isEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
