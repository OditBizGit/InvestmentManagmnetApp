class RegisterComplaintRequestModel {
  const RegisterComplaintRequestModel({required this.complaint});

  final String complaint;

  Map<String, dynamic> toJson() => {'complaint': complaint};
}

class RegisterComplaintResponseModel {
  const RegisterComplaintResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final RegisterComplaintDataModel? data;
  final int code;

  factory RegisterComplaintResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];

    return RegisterComplaintResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: rawData is Map
          ? RegisterComplaintDataModel.fromJson(
              Map<String, dynamic>.from(rawData),
            )
          : null,
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

class RegisterComplaintDataModel {
  const RegisterComplaintDataModel({
    required this.complaintId,
    required this.investorId,
    required this.complaint,
    this.complaintDate,
    required this.status,
  });

  final int complaintId;
  final int investorId;
  final String complaint;
  final DateTime? complaintDate;
  final String status;

  factory RegisterComplaintDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterComplaintDataModel(
      complaintId: _readInt(json['complaintId'] ?? json['ComplaintId']),
      investorId: _readInt(json['investorId'] ?? json['InvestorId']),
      complaint: (json['complaint'] ?? json['Complaint'] ?? '').toString(),
      complaintDate: _readDate(json['complaintDate'] ?? json['ComplaintDate']),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
