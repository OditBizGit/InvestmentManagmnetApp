import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class TopInvestorModel {
  const TopInvestorModel({
    required this.userId,
    required this.fullName,
    this.investorCode,
    this.profileImage,
    this.investorType,
    this.organization,
    this.investmentAmount = 0,
    this.totalPaidAmount = 0,
    this.pendingAmount = 0,
    this.rating = 0,
  });

  final int userId;
  final String fullName;
  final String? investorCode;
  final String? profileImage;
  final String? investorType;
  final String? organization;
  final double investmentAmount;
  final double totalPaidAmount;
  final double pendingAmount;
  final double rating;

  String? get profileImageUrl => resolveMediaUrl(profileImage);

  factory TopInvestorModel.fromJson(Map<String, dynamic> json) {
    return TopInvestorModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      investorType: _readString(json['investorType'] ?? json['InvestorType']),
      organization: _readString(json['organization'] ?? json['Organization']),
      investmentAmount: _readDouble(
        json['investmentAmount'] ?? json['InvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      pendingAmount: _readDouble(
        json['pendingAmount'] ?? json['PendingAmount'],
      ),
      rating: _readDouble(json['rating'] ?? json['Rating']),
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
}
