import 'work_status_model.dart';

class WorkStatusResponseModel {
  const WorkStatusResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final List<WorkStatusModel> data;
  final int code;

  factory WorkStatusResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final list = rawData is List ? rawData : const [];

    return WorkStatusResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: list
          .whereType<Map>()
          .map(
            (item) => WorkStatusModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      code: _readInt(json['code'] ?? json['Code']),
    );
  }

  static bool _readStatus(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'success' ||
          normalized == '1';
    }
    return false;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
