class ReviewBlockRequestModel {
  const ReviewBlockRequestModel({
    required this.requestId,
    required this.status,
    this.remarks = '',
  });

  final int requestId;
  final String status;
  final String remarks;

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status,
      'remarks': remarks.trim(),
    };
  }
}

class ReviewBlockRequestResponse {
  const ReviewBlockRequestResponse({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final ReviewBlockRequestResult? data;
  final int code;

  factory ReviewBlockRequestResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    ReviewBlockRequestResult? data;
    if (rawData is Map) {
      data = ReviewBlockRequestResult.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    }

    return ReviewBlockRequestResponse(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString().trim(),
      data: data,
      code: _readInt(json['code'] ?? json['Code']),
    );
  }
}

class ReviewBlockRequestResult {
  const ReviewBlockRequestResult({
    required this.requestId,
    required this.userId,
    required this.fullName,
    required this.isActive,
    required this.status,
    this.reviewedBy,
    this.reviewedDate,
    this.reviewRemarks,
  });

  final int requestId;
  final int userId;
  final String fullName;
  final bool isActive;
  final String status;
  final int? reviewedBy;
  final DateTime? reviewedDate;
  final String? reviewRemarks;

  factory ReviewBlockRequestResult.fromJson(Map<String, dynamic> json) {
    return ReviewBlockRequestResult(
      requestId: _readInt(json['requestId'] ?? json['RequestId']),
      userId: _readInt(json['userId'] ?? json['UserId']),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      reviewedBy: _readNullableInt(json['reviewedBy'] ?? json['ReviewedBy']),
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
