class ViewComplaintModel {
  final bool? apiStatus;
  final String? message;
  final int complaintId;
  final String status;

  ViewComplaintModel({
    required this.complaintId,
    required this.status,
    this.apiStatus,
    this.message,
  });

  factory ViewComplaintModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return ViewComplaintModel(
        apiStatus: json['status'] is bool ? json['status'] as bool : null,
        message: json['message']?.toString(),
        complaintId: _readInt(
          map['complaintId'] ?? map['ComplaintId'] ?? json['complaintId'],
        ),
        status: _readString(
          map['status'] ?? map['Status'] ?? 'Read',
        ),
      );
    }

    return ViewComplaintModel(
      apiStatus: json['status'] is bool ? json['status'] as bool : null,
      message: json['message']?.toString(),
      complaintId: _readInt(json['complaintId'] ?? json['ComplaintId']),
      status: _readString(
        data ?? json['Status'] ?? json['status'] ?? 'Read',
      ),
    );
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Read' : '';
    return value.toString().trim();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
