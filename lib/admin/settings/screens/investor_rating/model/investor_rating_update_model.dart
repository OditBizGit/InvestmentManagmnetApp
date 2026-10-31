class InvestorRatingUpdateRequestModel {
  final int investorId;
  final int rating;

  InvestorRatingUpdateRequestModel({
    required this.investorId,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'investorId': investorId,
      'rating': rating,
    };
  }
}

class InvestorRatingUpdateResponseModel {
  final bool status;
  final String message;
  final InvestorRatingUpdateData? data;
  final int code;

  InvestorRatingUpdateResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory InvestorRatingUpdateResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorRatingUpdateResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map
          ? InvestorRatingUpdateData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class InvestorRatingUpdateData {
  final int investorId;
  final int rating;
  final DateTime? updatedDate;

  InvestorRatingUpdateData({
    required this.investorId,
    required this.rating,
    this.updatedDate,
  });

  factory InvestorRatingUpdateData.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorRatingUpdateData(
      investorId: (json['investorId'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'].toString())
          : null,
    );
  }
}