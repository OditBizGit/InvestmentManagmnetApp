import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class WorkUpdateModel {
  const WorkUpdateModel({
    required this.workUpdateId,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    this.googleDriveFileId,
    this.fileUrl,
    this.createdDate,
    this.createdBy,
    required this.status,
  });

  final int workUpdateId;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String? googleDriveFileId;
  final String? fileUrl;
  final DateTime? createdDate;
  final int? createdBy;
  final bool status;

  String? get resolvedFileUrl => resolveMediaUrl(fileUrl);

  bool get isVideo =>
      fileType.toLowerCase() == 'video' ||
      mimeType.toLowerCase().startsWith('video/');

  bool get isImage =>
      fileType.toLowerCase() == 'image' ||
      mimeType.toLowerCase().startsWith('image/');

  String get uploadedLabel {
    final date = createdDate;
    if (date == null) return 'Uploaded recently';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final uploadedDay = DateTime(date.year, date.month, date.day);

    if (uploadedDay.isBefore(today)) {
      return 'Uploaded on ${_formatDate(date)} ${_formatTime(date)}';
    }

    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Uploaded just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Uploaded $m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    final h = diff.inHours.clamp(1, 23);
    return 'Uploaded $h ${h == 1 ? 'hour' : 'hours'} ago';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day-${months[date.month - 1]}-${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  factory WorkUpdateModel.fromJson(Map<String, dynamic> json) {
    return WorkUpdateModel(
      workUpdateId: _readInt(json['workUpdateId'] ?? json['WorkUpdateId']),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      fileName: (json['fileName'] ?? json['FileName'] ?? '').toString(),
      fileType: (json['fileType'] ?? json['FileType'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? json['MimeType'] ?? '').toString(),
      googleDriveFileId: _readString(
        json['googleDriveFileId'] ?? json['GoogleDriveFileId'],
      ),
      fileUrl: _readString(json['fileUrl'] ?? json['FileUrl']),
      createdDate: _readDateTime(json['createdDate'] ?? json['CreatedDate']),
      createdBy: _readNullableInt(json['createdBy'] ?? json['CreatedBy']),
      status: _readStatus(json['status'] ?? json['Status']),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
