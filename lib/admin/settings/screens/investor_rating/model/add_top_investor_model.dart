class AddTopInvestorRequestModel {
  final List<int> investorIds;

  AddTopInvestorRequestModel({
    required this.investorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'investorIds': investorIds,
    };
  }
}

class AddTopInvestorResponseModel {
  final bool status;
  final String message;
  final dynamic data;
  final int code;

  AddTopInvestorResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory AddTopInvestorResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AddTopInvestorResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'],
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}