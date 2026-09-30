import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

class GetWorkUpdatesModel {
  final bool status;
  final String message;
  final List<WorkUpdateModel> data;

  GetWorkUpdatesModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetWorkUpdatesModel.fromJson(Map<String, dynamic> json) {
    return GetWorkUpdatesModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map(
                (item) => WorkUpdateModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}

class WorkUpdateModel {
  final int workUpdateId;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String googleDriveFileId;
  final String fileUrl;
  final String createdDate;
  final int createdBy;
  final bool status;

  WorkUpdateModel({
    required this.workUpdateId,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.googleDriveFileId,
    required this.fileUrl,
    required this.createdDate,
    required this.createdBy,
    required this.status,
  });

  /// Full URL for media preview from the API `fileUrl` path.
  String? get mediaPreviewUrl => resolveMediaUrl(fileUrl);

  bool get isVideo {
    final type = fileType.toLowerCase();
    final mime = mimeType.toLowerCase();
    return type.contains('video') || mime.startsWith('video/');
  }

  bool get isImage {
    final type = fileType.toLowerCase();
    final mime = mimeType.toLowerCase();
    return type.contains('image') || mime.startsWith('image/');
  }

  factory WorkUpdateModel.fromJson(Map<String, dynamic> json) {
    return WorkUpdateModel(
      workUpdateId: json['workUpdateId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'] ?? '',
      googleDriveFileId: json['googleDriveFileId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      createdDate: json['createdDate'] ?? '',
      createdBy: json['createdBy'] ?? 0,
      status: json['status'] ?? false,
    );
  }
}
