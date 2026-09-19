import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investment_due_date_model.dart';

class InvestorDetailsModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? alternativeNumber;
  final String? profileImage;
  final String? investorCode;
  final String? investorType;
  final String? organization;
  final String? address;
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final DateTime? dateOfBirth;
  final double investmentAmount;
  final DateTime? investmentDate;
  final double investmentAdvanceAmount;
  final int investmentSplitMonths;
  final int investmentSplitGap;
  final String? investmentSplitType;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String? nomineeAadhaarNumber;
  final String? nomineePanCardNumber;
  final String? nomineePhoneNumber;
  final String? nomineeProfilePhoto;
  final List<InvestmentDueDateModel> dueDates;
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;

  const InvestorDetailsModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.alternativeNumber,
    this.profileImage,
    this.investorCode,
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
    this.investmentAdvanceAmount = 0,
    this.investmentSplitMonths = 0,
    this.investmentSplitGap = 1,
    this.investmentSplitType,
    this.totalPaidAmount = 0,
    this.totalPendingAmount = 0,
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineeAddress,
    this.nomineeDateOfBirth,
    this.nomineeAadhaarNumber,
    this.nomineePanCardNumber,
    this.nomineePhoneNumber,
    this.nomineeProfilePhoto,
    this.dueDates = const [],
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  /// Absolute URL for [nomineeProfilePhoto] (handles relative API paths).
  String? get nomineeProfilePhotoUrl => resolveMediaUrl(nomineeProfilePhoto);

  factory InvestorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InvestorDetailsModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phoneNumber: _readString(json['phoneNumber'] ?? json['PhoneNumber']),
      alternativeNumber: _readString(
        json['alternativeNumber'] ?? json['AlternativeNumber'],
      ),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      investorType: _readString(json['investorType'] ?? json['InvestorType']),
      organization: _readString(json['organization'] ?? json['Organization']),
      address: _readString(json['address'] ?? json['Address']),
      aadhaarNumber: _readString(json['aadhaarNumber'] ?? json['AadhaarNumber']),
      panCardNumber: _readString(json['panCardNumber'] ?? json['PanCardNumber']),
      accountNumber: _readString(json['accountNumber'] ?? json['AccountNumber']),
      ifscCode: _readString(json['ifscCode'] ?? json['IfscCode']),
      bankName: _readString(json['bankName'] ?? json['BankName']),
      dateOfBirth: _readDate(json['dateOfBirth'] ?? json['DateOfBirth']),
      investmentAmount: _readDouble(
        json['investmentAmount'] ??
            json['InvestmentAmount'] ??
            json['totalInvestmentAmount'] ??
            json['TotalInvestmentAmount'],
      ),
      investmentDate: _readDate(
        json['investmentDate'] ?? json['InvestmentDate'],
      ),
      investmentAdvanceAmount: _readDouble(
        json['investmentAdvanceAmount'] ?? json['InvestmentAdvanceAmount'],
      ),
      investmentSplitMonths: _readInt(
        json['investmentSplitMonths'] ?? json['InvestmentSplitMonths'],
      ),
      investmentSplitGap: _readInt(
        json['investmentSplitGap'] ?? json['InvestmentSplitGap'],
      ),
      investmentSplitType: _readString(
        json['investmentSplitType'] ?? json['InvestmentSplitType'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ?? json['TotalPendingAmount'],
      ),
      nomineeName: _readString(json['nomineeName'] ?? json['NomineeName']),
      nomineeRelationship: _readString(
        json['nomineeRelationship'] ?? json['NomineeRelationship'],
      ),
      nomineeAddress: _readString(
        json['nomineeAddress'] ?? json['NomineeAddress'],
      ),
      nomineeDateOfBirth: _readDate(
        json['nomineeDateOfBirth'] ?? json['NomineeDateOfBirth'],
      ),
      nomineeAadhaarNumber: _readString(
        json['nomineeAadhaarNumber'] ?? json['NomineeAadhaarNumber'],
      ),
      nomineePanCardNumber: _readString(
        json['nomineePanCardNumber'] ?? json['NomineePanCardNumber'],
      ),
      nomineePhoneNumber: _readString(
        json['nomineePhoneNumber'] ?? json['NomineePhoneNumber'],
      ),
      nomineeProfilePhoto: _readString(
        json['nomineeProfilePhoto'] ?? json['NomineeProfilePhoto'],
      ),
      dueDates: _readDueDates(json['dueDates'] ?? json['DueDates']),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      createdDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      modifiedDate: _readDate(json['modifiedDate'] ?? json['ModifiedDate']),
      userRole: (json['userRole'] ?? json['UserRole'] ?? '').toString(),
    );
  }

  static List<InvestmentDueDateModel> _readDueDates(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => InvestmentDueDateModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
