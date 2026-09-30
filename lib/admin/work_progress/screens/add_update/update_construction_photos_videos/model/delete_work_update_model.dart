class DeleteWorkUpdateModel {
  final bool status;
  final String message;
  final bool data;
  final int code;

  DeleteWorkUpdateModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory DeleteWorkUpdateModel.fromJson(Map<String, dynamic> json) {
    return DeleteWorkUpdateModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? false,
      code: json['code'] ?? 0,
    );
  }
}