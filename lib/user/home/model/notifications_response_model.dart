import 'package:maribel_wellness_centre_application/user/home/model/app_notification_model.dart';

class NotificationsResponseModel {
  const NotificationsResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final List<AppNotificationModel> data;
  final int code;

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final items = <AppNotificationModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          items.add(
            AppNotificationModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return NotificationsResponseModel(
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

class RegisterDeviceRequestModel {
  const RegisterDeviceRequestModel({
    required this.deviceToken,
    required this.platform,
  });

  final String deviceToken;
  final String platform;

  Map<String, dynamic> toJson() => {
        'deviceToken': deviceToken,
        'platform': platform,
      };
}

class RegisterDeviceResponseModel {
  const RegisterDeviceResponseModel({
    required this.status,
    required this.message,
    required this.code,
  });

  final bool status;
  final String message;
  final int code;

  factory RegisterDeviceResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterDeviceResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
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
