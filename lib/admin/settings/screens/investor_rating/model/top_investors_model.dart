class TopInvestorsResponse {
  final bool status;
  final String message;
  final List<TopInvestorModel> data;
  final int code;

  TopInvestorsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory TopInvestorsResponse.fromJson(Map<String, dynamic> json) {
    return TopInvestorsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => TopInvestorModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopInvestorModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final String? profileImage;
  final String investorType;
  final String? organization;
  final double investmentAmount;
  final double totalPaidAmount;
  final double pendingAmount;
  final double rating;

  TopInvestorModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    this.profileImage,
    required this.investorType,
    this.organization,
    required this.investmentAmount,
    required this.totalPaidAmount,
    required this.pendingAmount,
    required this.rating,
  });

  factory TopInvestorModel.fromJson(Map<String, dynamic> json) {
    return TopInvestorModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      investorCode: json['investorCode']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      investorType: json['investorType'] as String? ?? '',
      organization: json['organization'] as String?,
      investmentAmount:
          (json['investmentAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      rating: _readRating(json),
    );
  }

  TopInvestorModel copyWith({double? rating}) {
    return TopInvestorModel(
      userId: userId,
      investorCode: investorCode,
      fullName: fullName,
      profileImage: profileImage,
      investorType: investorType,
      organization: organization,
      investmentAmount: investmentAmount,
      totalPaidAmount: totalPaidAmount,
      pendingAmount: pendingAmount,
      rating: rating ?? this.rating,
    );
  }

  /// Saved/default star rating (0.5–5), or null when missing/invalid.
  double? get savedStarRating =>
      rating >= 0.5 && rating <= 5 ? rating : null;

  static double _readRating(Map<String, dynamic> json) {
    final raw = json['rating'] ??
        json['Rating'] ??
        json['starRating'] ??
        json['StarRating'] ??
        json['investorRating'] ??
        json['InvestorRating'];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
