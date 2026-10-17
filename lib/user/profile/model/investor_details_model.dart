import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/core/utils/string_extensions.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investment_due_date_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_nominee_model.dart';

class InvestorDetailsModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? alternativeNumber;
  final int? staffId;
  final String? staffName;
  final String? staffPhoneNumber;
  final String? profileImage;
  final String? investorCode;
  final String? investorType;
  final String? organization;
  final String? address;
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? aadhaarPhoto;
  final String? panCardPhoto;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final DateTime? dateOfBirth;
  final String? description;
  final double? medicalAllowance;
  final double investmentAmount;
  final DateTime? investmentDate;
  final double investmentAdvanceAmount;
  final int investmentSplitMonths;
  final int investmentSplitGap;
  final String? investmentSplitType;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final double discountAmount;
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;
  final List<InvestorNomineeModel> nominees;
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
    this.staffId,
    this.staffName,
    this.staffPhoneNumber,
    this.profileImage,
    this.investorCode,
    this.investorType,
    this.organization,
    this.address,
    this.aadhaarNumber,
    this.panCardNumber,
    this.aadhaarPhoto,
    this.panCardPhoto,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.dateOfBirth,
    this.description,
    this.medicalAllowance,
    this.investmentAmount = 0,
    this.investmentDate,
    this.investmentAdvanceAmount = 0,
    this.investmentSplitMonths = 0,
    this.investmentSplitGap = 1,
    this.investmentSplitType,
    this.totalPaidAmount = 0,
    this.totalPendingAmount = 0,
    this.discountAmount = 0,
    this.lastPaymentAmount = 0,
    this.lastPaymentDate,
    this.nominees = const [],
    this.dueDates = const [],
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  String? get aadhaarPhotoUrl => resolveMediaUrl(aadhaarPhoto);

  String? get panCardPhotoUrl => resolveMediaUrl(panCardPhoto);

  factory InvestorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InvestorDetailsModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      username: (json['username'] ?? json['Username'] ?? '')
          .toString()
          .toTitleCase,
      fullName: (json['fullName'] ?? json['FullName'] ?? '')
          .toString()
          .toTitleCase,
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phoneNumber: _readString(json['phoneNumber'] ?? json['PhoneNumber']),
      alternativeNumber: _readString(
        json['alternativeNumber'] ?? json['AlternativeNumber'],
      ),
      staffId: _readNullableInt(json['staffId'] ?? json['StaffId']),
      staffName: _readName(json['staffName'] ?? json['StaffName']),
      staffPhoneNumber: _readString(
        json['staffPhoneNumber'] ?? json['StaffPhoneNumber'],
      ),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      investorType: _readString(json['investorType'] ?? json['InvestorType']),
      organization: _readString(json['organization'] ?? json['Organization']),
      address: _readString(json['address'] ?? json['Address']),
      aadhaarNumber: _readString(json['aadhaarNumber'] ?? json['AadhaarNumber']),
      panCardNumber: _readString(json['panCardNumber'] ?? json['PanCardNumber']),
      aadhaarPhoto: _readString(
        json['aadhaarPhoto'] ??
            json['AadhaarPhoto'] ??
            json['aadhaarCardImage'] ??
            json['AadhaarCardImage'],
      ),
      panCardPhoto: _readString(
        json['panCardPhoto'] ??
            json['PanCardPhoto'] ??
            json['panCardImage'] ??
            json['PanCardImage'],
      ),
      accountNumber: _readString(json['accountNumber'] ?? json['AccountNumber']),
      ifscCode: _readString(json['ifscCode'] ?? json['IfscCode']),
      bankName: _readString(json['bankName'] ?? json['BankName']),
      dateOfBirth: _readDate(json['dateOfBirth'] ?? json['DateOfBirth']),
      description: _readString(json['description'] ?? json['Description']),
      medicalAllowance: _readNullableDouble(
        json['medicalAllowance'] ?? json['MedicalAllowance'],
      ),
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
      discountAmount: _readDouble(
        json['discountAmount'] ?? json['DiscountAmount'],
      ),
      lastPaymentAmount: _readDouble(
        json['lastPaymentAmount'] ?? json['LastPaymentAmount'],
      ),
      lastPaymentDate: _readDate(
        json['lastPaymentDate'] ?? json['LastPaymentDate'],
      ),
      nominees: _readNominees(json),
      dueDates: _readDueDates(json['dueDates'] ?? json['DueDates']),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      createdDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      modifiedDate: _readDate(json['modifiedDate'] ?? json['ModifiedDate']),
      userRole: (json['userRole'] ?? json['UserRole'] ?? '').toString(),
    );
  }

  static List<InvestorNomineeModel> _readNominees(Map<String, dynamic> json) {
    final raw = json['nominees'] ?? json['Nominees'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => InvestorNomineeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((nominee) => !nominee.isEmpty)
          .toList();
    }

    final flat = InvestorNomineeModel.fromFlatInvestor(json);
    return flat.isEmpty ? const [] : [flat];
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

  static String? _readName(dynamic value) {
    final text = _readString(value);
    return text?.toTitleCase;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }
    return null;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    return _readNullableDouble(value) ?? 0;
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }
    return null;
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
