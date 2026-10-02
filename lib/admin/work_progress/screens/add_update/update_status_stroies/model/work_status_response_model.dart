import 'add_work_status_model.dart';

class GetWorkStatusResponseModel {
  final bool status;
  final String message;
  final List<WorkStatusModel> data;
  final int code;

  GetWorkStatusResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory GetWorkStatusResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetWorkStatusResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map(
                (e) => WorkStatusModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
      code: json['code'] ?? 0,
    );
  }
}
