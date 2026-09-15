import 'investor_model.dart';

class InvestorResponseModel {
  final bool status;
  final String message;
  final List<InvestorModel> data;
  final int code;

  InvestorResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory InvestorResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => InvestorModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      code: json['code'] ?? 0,
    );
  }
}