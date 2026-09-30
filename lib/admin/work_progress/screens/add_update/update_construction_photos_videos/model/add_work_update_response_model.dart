class AddWorkUpdateModel {
  final bool status;
  final String message;
  final WorkUpdateData? data;
  final int code;

  AddWorkUpdateModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory AddWorkUpdateModel.fromJson(Map<String, dynamic> json) {
    return AddWorkUpdateModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WorkUpdateData.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
      code: json['code'] ?? 0,
    );
  }
}

class WorkUpdateData {
  final int workUpdateId;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String googleDriveFileId;
  final String createdDate;
  final int createdBy;
  final bool status;

  WorkUpdateData({
    required this.workUpdateId,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.googleDriveFileId,
    required this.createdDate,
    required this.createdBy,
    required this.status,
  });

  factory WorkUpdateData.fromJson(Map<String, dynamic> json) {
    return WorkUpdateData(
      workUpdateId: json['workUpdateId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'] ?? '',
      googleDriveFileId: json['googleDriveFileId'] ?? '',
      createdDate: json['createdDate'] ?? '',
      createdBy: json['createdBy'] ?? 0,
      status: json['status'] ?? false,
    );
  }
}