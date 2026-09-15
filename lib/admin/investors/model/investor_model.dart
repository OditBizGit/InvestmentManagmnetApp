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
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    return InvestorModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImage: _readProfileImage(json),
      investorCode: json['investorCode'],
      investorType: json['investorType'],
      organization: json['organization'],
      address: json['address'],
      isActive: json['isActive'] ?? false,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'].toString())
          : null,
      userRole: json['userRole'] ?? '',
    );
  }

  static String? _readProfileImage(Map<String, dynamic> json) {
    final value = json['profileImage'] ??
        json['ProfileImage'] ??
        json['profile_image'] ??
        json['imageUrl'] ??
        json['image'];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
