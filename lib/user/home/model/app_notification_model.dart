class AppNotificationModel {
  const AppNotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedId,
    required this.isRead,
    this.createdDate,
    this.readDate,
  });

  final int notificationId;
  final String title;
  final String message;
  final String type;
  final int relatedId;
  final bool isRead;
  final DateTime? createdDate;
  final DateTime? readDate;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      notificationId: _readInt(
        json['notificationId'] ?? json['NotificationId'],
      ),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      type: (json['type'] ?? json['Type'] ?? '').toString(),
      relatedId: _readInt(json['relatedId'] ?? json['RelatedId']),
      isRead: _readBool(json['isRead'] ?? json['IsRead']),
      createdDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      readDate: _readDate(json['readDate'] ?? json['ReadDate']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
