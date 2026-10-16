class BlockUserRequestModel {
  final int userId;
  final bool isActive;

  const BlockUserRequestModel({
    required this.userId,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isActive': isActive,
    };
  }
}

class BlockUserResponseModel {
  final bool status;
  final String message;
  final String? data;
  final int code;

  const BlockUserResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory BlockUserResponseModel.fromJson(Map<String, dynamic> json) {
    return BlockUserResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString().trim(),
      data: (json['data'] ?? json['Data'])?.toString(),
      code: _readInt(json['code'] ?? json['Code']),
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