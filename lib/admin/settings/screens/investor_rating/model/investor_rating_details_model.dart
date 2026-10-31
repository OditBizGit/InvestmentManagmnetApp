class InvestorRatingDetailsResponse {
  final bool status;
  final String message;
  final List<InvestorRatingDetailsModel> data;
  final int code;

  InvestorRatingDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory InvestorRatingDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestorRatingDetailsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => InvestorRatingDetailsModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class InvestorRatingDetailsModel {
  final String investorName;
  final String investorCode;
  final double totalInvestmentAmount;
  final int totalDueCount;
  final int onTimePaymentCount;
  final int delayedPaymentCount;
  final double onTimePaymentPercentage;
  final int rating;
  final int userId;

  InvestorRatingDetailsModel({
    required this.investorName,
    required this.investorCode,
    required this.totalInvestmentAmount,
    required this.totalDueCount,
    required this.onTimePaymentCount,
    required this.delayedPaymentCount,
    required this.onTimePaymentPercentage,
    required this.rating,
    required this.userId,
  });

  factory InvestorRatingDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestorRatingDetailsModel(
      investorName: json['investorName'] as String? ?? '',
      investorCode: json['investorCode']?.toString() ?? '',
      totalInvestmentAmount:
          (json['totalInvestmentAmount'] as num?)?.toDouble() ?? 0.0,
      totalDueCount: (json['totalDueCount'] as num?)?.toInt() ?? 0,
      onTimePaymentCount:
          (json['onTimePaymentCount'] as num?)?.toInt() ?? 0,
      delayedPaymentCount:
          (json['delayedPaymentCount'] as num?)?.toInt() ?? 0,
      onTimePaymentPercentage:
          (json['onTimePaymentPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investorName': investorName,
      'investorCode': investorCode,
      'totalInvestmentAmount': totalInvestmentAmount,
      'totalDueCount': totalDueCount,
      'onTimePaymentCount': onTimePaymentCount,
      'delayedPaymentCount': delayedPaymentCount,
      'onTimePaymentPercentage': onTimePaymentPercentage,
      'rating': rating,
      'userId': userId,
    };
  }

  /// Saved star rating from the API (1–5), or null when not rated.
  int? get savedStarRating =>
      rating >= 1 && rating <= 5 ? rating : null;

  String get initials {
    final parts = investorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get ratingLabel {
    return switch (savedStarRating) {
      5 => 'Excellent',
      4 => 'Good',
      3 => 'Fair',
      2 => 'Weak',
      1 => 'Poor',
      _ => 'Not rated',
    };
  }

  InvestorRatingDetailsModel copyWith({
    String? investorName,
    String? investorCode,
    double? totalInvestmentAmount,
    int? totalDueCount,
    int? onTimePaymentCount,
    int? delayedPaymentCount,
    double? onTimePaymentPercentage,
    int? rating,
    int? userId,
  }) {
    return InvestorRatingDetailsModel(
      investorName: investorName ?? this.investorName,
      investorCode: investorCode ?? this.investorCode,
      totalInvestmentAmount:
          totalInvestmentAmount ?? this.totalInvestmentAmount,
      totalDueCount: totalDueCount ?? this.totalDueCount,
      onTimePaymentCount: onTimePaymentCount ?? this.onTimePaymentCount,
      delayedPaymentCount: delayedPaymentCount ?? this.delayedPaymentCount,
      onTimePaymentPercentage:
          onTimePaymentPercentage ?? this.onTimePaymentPercentage,
      rating: rating ?? this.rating,
      userId: userId ?? this.userId,
    );
  }
}
