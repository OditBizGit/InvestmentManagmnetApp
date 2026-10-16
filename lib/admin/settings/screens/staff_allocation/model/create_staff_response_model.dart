import 'get_staff_response_model.dart';

class CreateStaffResponseModel {
  final bool success;
  final String message;
  final StaffModel? data;

  const CreateStaffResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateStaffResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateStaffResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? StaffModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}
