class WorkUpdateModel {
  final int workUpdateId;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String googleDriveFileId;
  final String fileUrl;
  final DateTime createdDate;
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

  factory WorkUpdateModel.fromJson(Map<String, dynamic> json) {
    return WorkUpdateModel(
      workUpdateId: _readInt(
        json['workUpdateId'] ?? json['WorkUpdateId'],
      ),
      title: (
          json['title'] ??
              json['Title'] ??
              ''
      ).toString(),
      description: (
          json['description'] ??
              json['Description'] ??
              ''
      ).toString(),
      fileName: (
          json['fileName'] ??
              json['FileName'] ??
              ''
      ).toString(),
      fileType: (
          json['fileType'] ??
              json['FileType'] ??
              ''
      ).toString(),
      mimeType: (
          json['mimeType'] ??
              json['MimeType'] ??
              ''
      ).toString(),
      googleDriveFileId: (
          json['googleDriveFileId'] ??
              json['GoogleDriveFileId'] ??
              ''
      ).toString(),
      fileUrl: (
          json['fileUrl'] ??
              json['FileUrl'] ??
              ''
      ).toString(),
      createdDate: _readDate(
        json['createdDate'] ??
            json['CreatedDate'],
      ),
      createdBy: _readInt(
        json['createdBy'] ??
            json['CreatedBy'],
      ),
      status: _readBool(
        json['status'] ??
            json['Status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workUpdateId': workUpdateId,
      'title': title,
      'description': description,
      'fileName': fileName,
      'fileType': fileType,
      'mimeType': mimeType,
      'googleDriveFileId': googleDriveFileId,
      'fileUrl': fileUrl,
      'createdDate': createdDate.toIso8601String(),
      'createdBy': createdBy,
      'status': status,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  static DateTime _readDate(dynamic value) {
    if (value is DateTime) return value;

    if (value != null) {
      final parsed = DateTime.tryParse(
        value.toString(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }
}