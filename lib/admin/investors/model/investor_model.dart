import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class InvestorModel {
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
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final DateTime? nextDueDate;
  final double nextDueAmount;

  InvestorModel({
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
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
    this.nextDueDate,
    this.nextDueAmount = 0,
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    return InvestorModel(
      userId: _readInt(json['UserId'] ?? json['userId']),
      username: (json['Username'] ?? json['username'] ?? '').toString(),
      fullName: (json['FullName'] ?? json['fullName'] ?? '').toString(),
      email: (json['Email'] ?? json['email'] ?? '').toString(),
      phoneNumber: _readString(json['PhoneNumber'] ?? json['phoneNumber']),
      profileImage: _readProfileImage(json),
      investorCode: _readString(json['InvestorCode'] ?? json['investorCode']),
      investorType: _readString(json['InvestorType'] ?? json['investorType']),
      organization: _readString(json['Organization'] ?? json['organization']),
      address: _readString(json['Address'] ?? json['address']),
      isActive: _readBool(json['IsActive'] ?? json['isActive']),
      createdDate: _readDate(json['CreatedDate'] ?? json['createdDate']),
      modifiedDate: _readDate(json['ModifiedDate'] ?? json['modifiedDate']),
      userRole: (json['UserRole'] ?? json['userRole'] ?? '').toString(),
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      nextDueDate: _readDate(json['nextDueDate'] ?? json['NextDueDate']),
      nextDueAmount: _readDouble(
        json['nextDueAmount'] ?? json['NextDueAmount'],
      ),
    );
  }

  static String? _readProfileImage(Map<String, dynamic> json) {
    final value = json['profileImage'] ??
        json['ProfileImage'] ??
        json['profile_image'] ??
        json['imageUrl'] ??
        json['image'];
    return _readString(value);
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
