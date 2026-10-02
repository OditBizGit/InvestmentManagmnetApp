class DeleteWorkStatusModel {
  final bool status;
  final String message;
  final bool data;
  final int code;

  DeleteWorkStatusModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory DeleteWorkStatusModel.fromJson(Map<String, dynamic> json) {
    return DeleteWorkStatusModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? false,
      code: json['code'] ?? 0,
    );
  }
}
