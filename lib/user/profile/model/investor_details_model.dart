import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class InvestorDetailsModel {
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
  final double investmentAmount;
  final DateTime? investmentDate;
  final double totalPaidAmount;
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
    this.profileImage,
    this.investorCode,
    this.investorType,
    this.organization,
    this.address,
    this.investmentAmount = 0,
    this.investmentDate,
    this.totalPaidAmount = 0,
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  factory InvestorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InvestorDetailsModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phoneNumber: _readString(json['phoneNumber'] ?? json['PhoneNumber']),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      investorType: _readString(json['investorType'] ?? json['InvestorType']),
      organization: _readString(json['organization'] ?? json['Organization']),
      address: _readString(json['address'] ?? json['Address']),
      investmentAmount: _readDouble(
        json['investmentAmount'] ??
            json['InvestmentAmount'] ??
            json['totalInvestmentAmount'] ??
            json['TotalInvestmentAmount'],
      ),
      investmentDate: _readDate(
        json['investmentDate'] ?? json['InvestmentDate'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      createdDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      modifiedDate: _readDate(json['modifiedDate'] ?? json['ModifiedDate']),
      userRole: (json['userRole'] ?? json['UserRole'] ?? '').toString(),
    );
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
