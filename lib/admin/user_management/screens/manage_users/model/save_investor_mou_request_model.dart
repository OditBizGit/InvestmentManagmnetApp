import 'dart:typed_data';
import 'package:dio/dio.dart';

/// ===============================
/// SAVE INVESTOR MOU REQUEST MODEL
/// ===============================
class SaveInvestorMOURequestModel {
  final int investorId;
  final String status;
  final Uint8List? documentBytes;
  final String? documentFileName;

  SaveInvestorMOURequestModel({
    required this.investorId,
    required this.status,
    this.documentBytes,
    this.documentFileName,
  });

  FormData toFormData() {
    final Map<String, dynamic> fields = {
      'investorId': investorId,
      'status': status,
    };

    if (documentBytes != null && documentFileName != null) {
      fields['Document'] = MultipartFile.fromBytes(
        documentBytes!,
        filename: documentFileName!,
      );
    }

    return FormData.fromMap(fields);
  }
}

/// ===============================
/// SAVE INVESTOR MOU RESPONSE MODEL
/// ===============================
class SaveInvestorMOUResponseModel {
  final bool status;
  final String message;
  final List<SaveInvestorMOUDataModel> data;
  final int code;

  SaveInvestorMOUResponseModel({
    required this.status,
    required this.message,
    this.data = const [],
    required this.code,
  });

  /// Current MOU/LLP record:
  /// Furthest status, then newest by time/id.
  SaveInvestorMOUDataModel? get latestRecord {
    if (data.isEmpty) return null;

    SaveInvestorMOUDataModel? best;

    for (final item in data) {
      if (best == null || item._isNewerThan(best)) {
        best = item;
      }
    }

    return best;
  }

  /// Best matching record for a status label.
  SaveInvestorMOUDataModel? recordForStatus(String statusLabel) {
    final target = statusLabel.trim().toLowerCase();

    if (target.isEmpty) return null;

    SaveInvestorMOUDataModel? best;

    for (final item in data) {
      if (item.status.trim().toLowerCase() != target) continue;

      if (best == null || item._isNewerThan(best)) {
        best = item;
      }
    }

    return best;
  }

  DateTime? timestampForStatus(String statusLabel) =>
      recordForStatus(statusLabel)?.effectiveUpdatedAt;

  /// Record whose document should be shown in UI.
  ///
  /// Prefer the furthest/newest status that has a non-empty [documentPath].
  /// Example: Completed with null path falls back to Issued/Pending that still
  /// have an uploaded file.
  SaveInvestorMOUDataModel? get latestDocumentRecord {
    SaveInvestorMOUDataModel? best;

    for (final item in data) {
      final path = item.documentPath?.trim();
      if (path == null || path.isEmpty) continue;

      if (best == null || item._isNewerThan(best)) {
        best = item;
      }
    }

    return best;
  }

  String? get effectiveDocumentPath {
    final path = latestDocumentRecord?.documentPath?.trim();
    if (path == null || path.isEmpty) return null;
    return path;
  }

  DateTime? get effectiveDocumentUpdatedAt =>
      latestDocumentRecord?.effectiveUpdatedAt;

  factory SaveInvestorMOUResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawData = json['data'] ?? json['Data'];
    final records = <SaveInvestorMOUDataModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          records.add(
            SaveInvestorMOUDataModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    } else if (rawData is Map) {
      records.add(
        SaveInvestorMOUDataModel.fromJson(
          Map<String, dynamic>.from(rawData),
        ),
      );
    }

    return SaveInvestorMOUResponseModel(
      status: json['status'] == true || json['Status'] == true,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: records,
      code: ((json['code'] ?? json['Code']) as num?)?.toInt() ?? 0,
    );
  }
}

/// ===============================
/// SAVE INVESTOR MOU DATA MODEL
/// ===============================
class SaveInvestorMOUDataModel {
  final int id;
  final int investorId;
  final String status;
  final String? documentPath;
  final DateTime? createdDateTime;
  final DateTime? modifiedDateTime;

  SaveInvestorMOUDataModel({
    required this.id,
    required this.investorId,
    required this.status,
    this.documentPath,
    this.createdDateTime,
    this.modifiedDateTime,
  });

  DateTime? get effectiveUpdatedAt =>
      modifiedDateTime ?? createdDateTime;

  int get _statusRank {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return 3;
      case 'issued':
        return 2;
      case 'pending':
        return 1;
      default:
        return 0;
    }
  }

  bool _isNewerThan(SaveInvestorMOUDataModel other) {
    if (_statusRank != other._statusRank) {
      return _statusRank > other._statusRank;
    }

    final thisTime = effectiveUpdatedAt;
    final otherTime = other.effectiveUpdatedAt;

    if (thisTime != null &&
        otherTime != null &&
        thisTime != otherTime) {
      return thisTime.isAfter(otherTime);
    }

    if (thisTime != null && otherTime == null) return true;
    if (thisTime == null && otherTime != null) return false;

    return id > other.id;
  }

  factory SaveInvestorMOUDataModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SaveInvestorMOUDataModel(
      id: ((json['id'] ?? json['Id']) as num?)?.toInt() ?? 0,

      investorId:
      ((json['investorId'] ?? json['InvestorId']) as num?)
          ?.toInt() ??
          0,

      status: (json['status'] ?? json['Status'] ?? '').toString(),

      documentPath:
      (json['documentPath'] ?? json['DocumentPath'])?.toString(),

      createdDateTime: DateTime.tryParse(
        (json['createdDateTime'] ??
            json['CreatedDateTime'] ??
            '')
            .toString(),
      ),

      modifiedDateTime: DateTime.tryParse(
        (json['modifiedDateTime'] ??
            json['ModifiedDateTime'] ??
            '')
            .toString(),
      ),
    );
  }
}