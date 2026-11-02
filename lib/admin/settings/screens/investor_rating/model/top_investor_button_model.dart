class TopInvestorButtonRequestModel {
  final bool isEnabled;

  TopInvestorButtonRequestModel({
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
    };
  }
}

class TopInvestorButtonResponseModel {
  final bool status;
  final String message;
  final TopInvestorButtonData? data;
  final int code;

  TopInvestorButtonResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory TopInvestorButtonResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TopInvestorButtonResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map
          ? TopInvestorButtonData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopInvestorButtonData {
  final int id;
  final String name;
  final bool status;

  TopInvestorButtonData({
    required this.id,
    required this.name,
    required this.status,
  });

  factory TopInvestorButtonData.fromJson(
      Map<String, dynamic> json,
      ) {
    return TopInvestorButtonData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as bool? ?? false,
    );
  }
}