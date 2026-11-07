class InvestorBlockRequestsResponse {
  const InvestorBlockRequestsResponse({
    required this.status,
    required this.message,
    required this.requests,
    required this.code,
  });

  final bool status;
  final String message;
  final List<InvestorBlockRequestModel> requests;
  final int code;

  factory InvestorBlockRequestsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final requests = <InvestorBlockRequestModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          requests.add(
            InvestorBlockRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return InvestorBlockRequestsResponse(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString().trim(),
      requests: requests,
      code: _readInt(json['code'] ?? json['Code']),
    );
  }
}

class InvestorBlockRequestModel {
  const InvestorBlockRequestModel({
    required this.requestId,
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.isActive,
    required this.status,
    required this.remarks,
    this.requestedDate,
    this.requestedBy,
    this.requestedByName,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedDate,
    this.reviewRemarks,
  });

  final int requestId;
  final int userId;
  final String investorCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isActive;
  final String status;
  final String remarks;
  final DateTime? requestedDate;
  final int? requestedBy;
  final String? requestedByName;
  final int? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedDate;
  final String? reviewRemarks;

  bool get isPendingReview => status.trim().toLowerCase() == 'pending';

  InvestorBlockRequestModel copyWith({
    bool? isActive,
    String? status,
    String? reviewRemarks,
    String? reviewedByName,
    int? reviewedBy,
    DateTime? reviewedDate,
  }) {
    return InvestorBlockRequestModel(
      requestId: requestId,
      userId: userId,
      investorCode: investorCode,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      remarks: remarks,
      requestedDate: requestedDate,
      requestedBy: requestedBy,
      requestedByName: requestedByName,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedByName: reviewedByName ?? this.reviewedByName,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      reviewRemarks: reviewRemarks ?? this.reviewRemarks,
    );
  }

  factory InvestorBlockRequestModel.fromJson(Map<String, dynamic> json) {
    return InvestorBlockRequestModel(
      requestId: _readInt(json['requestId'] ?? json['RequestId']),
      userId: _readInt(json['userId'] ?? json['UserId']),
      investorCode:
          (json['investorCode'] ?? json['InvestorCode'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phoneNumber:
          (json['phoneNumber'] ?? json['PhoneNumber'] ?? '').toString(),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      remarks: (json['remarks'] ?? json['Remarks'] ?? '').toString(),
      requestedDate: _readDate(
        json['requestedDate'] ?? json['RequestedDate'],
      ),
      requestedBy: _readNullableInt(
        json['requestedBy'] ?? json['RequestedBy'],
      ),
      requestedByName: _readString(
        json['requestedByName'] ?? json['RequestedByName'],
      ),
      reviewedBy: _readNullableInt(
        json['reviewedBy'] ?? json['ReviewedBy'],
      ),
      reviewedByName: _readString(
        json['reviewedByName'] ?? json['ReviewedByName'],
      ),
      reviewedDate: _readDate(json['reviewedDate'] ?? json['ReviewedDate']),
      reviewRemarks: _readString(
        json['reviewRemarks'] ?? json['ReviewRemarks'],
      ),
    );
  }
}

bool _readStatus(dynamic value) {
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

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

int? _readNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }
  return null;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}
