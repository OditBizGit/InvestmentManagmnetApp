class MyComplaintsResponseModel {
  const MyComplaintsResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final List<MyComplaintModel> data;
  final int code;

  factory MyComplaintsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final items = <MyComplaintModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          items.add(
            MyComplaintModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return MyComplaintsResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: items,
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

class MyComplaintModel {
  const MyComplaintModel({
    required this.complaintId,
    required this.investorId,
    this.investorCode,
    this.investorName,
    this.profileImage,
    required this.complaint,
    this.complaintDate,
    required this.status,
  });

  final int complaintId;
  final int investorId;
  final String? investorCode;
  final String? investorName;
  final String? profileImage;
  final String complaint;
  final DateTime? complaintDate;
  final String status;

  factory MyComplaintModel.fromJson(Map<String, dynamic> json) {
    return MyComplaintModel(
      complaintId: _readInt(json['complaintId'] ?? json['ComplaintId']),
      investorId: _readInt(json['investorId'] ?? json['InvestorId']),
      investorCode: _readNullableString(
        json['investorCode'] ?? json['InvestorCode'],
      ),
      investorName: _readNullableString(
        json['investorName'] ?? json['InvestorName'],
      ),
      profileImage: _readNullableString(
        json['profileImage'] ?? json['ProfileImage'],
      ),
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

  static String? _readNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
