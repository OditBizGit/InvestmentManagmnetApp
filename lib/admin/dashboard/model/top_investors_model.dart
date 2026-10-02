class TopInvestorsModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final String profileImage;
  final String investorType;
  final String organization;
  final double investmentAmount;
  final double totalPaidAmount;
  final double pendingAmount;
  final int rating;

  TopInvestorsModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.profileImage,
    required this.investorType,
    required this.organization,
    required this.investmentAmount,
    required this.totalPaidAmount,
    required this.pendingAmount,
    required this.rating,
  });

  factory TopInvestorsModel.fromJson(Map<String, dynamic> json) {
    return TopInvestorsModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      investorCode:
      (json['investorCode'] ?? json['InvestorCode'] ?? '').toString(),
      fullName:
      (json['fullName'] ?? json['FullName'] ?? '').toString(),
      profileImage:
      (json['profileImage'] ?? json['ProfileImage'] ?? '').toString(),
      investorType:
      (json['investorType'] ?? json['InvestorType'] ?? '').toString(),
      organization:
      (json['organization'] ?? json['Organization'] ?? '').toString(),
      investmentAmount:
      _readDouble(json['investmentAmount'] ?? json['InvestmentAmount']),
      totalPaidAmount:
      _readDouble(json['totalPaidAmount'] ?? json['TotalPaidAmount']),
      pendingAmount:
      _readDouble(json['pendingAmount'] ?? json['PendingAmount']),
      rating: _readInt(json['rating'] ?? json['Rating']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'investorCode': investorCode,
      'fullName': fullName,
      'profileImage': profileImage,
      'investorType': investorType,
      'organization': organization,
      'investmentAmount': investmentAmount,
      'totalPaidAmount': totalPaidAmount,
      'pendingAmount': pendingAmount,
      'rating': rating,
    };
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
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}