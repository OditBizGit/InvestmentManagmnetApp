class RemoveTopInvestorRequestModel {
  final List<int> investorIds;

  RemoveTopInvestorRequestModel({
    required this.investorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'investorIds': investorIds,
    };
  }
}

class RemoveTopInvestorResponseModel {
  final bool status;
  final String message;
  final RemoveTopInvestorData? data;
  final int code;

  RemoveTopInvestorResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory RemoveTopInvestorResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RemoveTopInvestorResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map
          ? RemoveTopInvestorData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class RemoveTopInvestorData {
  final List<int> removedInvestorIds;
  final List<int> notFoundInvestorIds;

  RemoveTopInvestorData({
    required this.removedInvestorIds,
    required this.notFoundInvestorIds,
  });

  factory RemoveTopInvestorData.fromJson(
      Map<String, dynamic> json,
      ) {
    return RemoveTopInvestorData(
      removedInvestorIds:
      (json['removedInvestorIds'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
      notFoundInvestorIds:
      (json['notFoundInvestorIds'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
    );
  }
}