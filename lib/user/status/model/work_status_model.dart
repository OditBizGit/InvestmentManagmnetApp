import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class WorkStatusModel {
  const WorkStatusModel({
    required this.workStatusId,
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

  final int workStatusId;
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

  factory WorkStatusModel.fromJson(Map<String, dynamic> json) {
    return WorkStatusModel(
      workStatusId: _readInt(json['workStatusId'] ?? json['WorkStatusId']),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description:
          (json['description'] ?? json['Description'] ?? '').toString(),
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
