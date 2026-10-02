import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

class AddWorkStatusResponseModel {
  final bool status;
  final String message;
  final WorkStatusModel? data;
  final int code;

  AddWorkStatusResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory AddWorkStatusResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddWorkStatusResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WorkStatusModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
      code: json['code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'code': code,
    };
  }
}

class WorkStatusModel {
  final int workStatusId;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String googleDriveFileId;
  final String? fileUrl;
  final String createdDate;
  final int createdBy;
  final bool status;

  WorkStatusModel({
    required this.workStatusId,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.googleDriveFileId,
    this.fileUrl,
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

  factory WorkStatusModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkStatusModel(
      workStatusId: json['workStatusId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'] ?? '',
      googleDriveFileId: json['googleDriveFileId'] ?? '',
      fileUrl: json['fileUrl'],
      createdDate: json['createdDate'] ?? '',
      createdBy: json['createdBy'] ?? 0,
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workStatusId': workStatusId,
      'title': title,
      'description': description,
      'fileName': fileName,
      'fileType': fileType,
      'mimeType': mimeType,
      'googleDriveFileId': googleDriveFileId,
      'fileUrl': fileUrl,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'status': status,
    };
  }
}
