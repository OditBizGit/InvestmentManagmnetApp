class SaveInvestorMOURequestModel {
  final int investorId;
  final String status;

  SaveInvestorMOURequestModel({
    required this.investorId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'investorId': investorId,
      'status': status,
    };
  }
}

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

  /// Current MOU/LLP record: furthest status, then newest by time/id.
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

  /// Best matching record for a status label (e.g. `Issued`, `Completed`).
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
      // Save endpoints may still return a single object.
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
      code: (json['code'] as num?)?.toInt() ??
          (json['Code'] as num?)?.toInt() ??
          0,
    );
  }
}

class SaveInvestorMOUDataModel {
  final int id;
  final int investorId;
  final String status;
  final DateTime? createdDateTime;
  final DateTime? modifiedDateTime;

  SaveInvestorMOUDataModel({
    required this.id,
    required this.investorId,
    required this.status,
    this.createdDateTime,
    this.modifiedDateTime,
  });

  DateTime? get effectiveUpdatedAt => modifiedDateTime ?? createdDateTime;

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
    if (thisTime != null && otherTime != null && thisTime != otherTime) {
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
      id: (json['id'] as num?)?.toInt() ??
          (json['Id'] as num?)?.toInt() ??
          0,
      investorId: (json['investorId'] as num?)?.toInt() ??
          (json['InvestorId'] as num?)?.toInt() ??
          0,
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      createdDateTime: DateTime.tryParse(
        (json['createdDateTime'] ?? json['CreatedDateTime'] ?? '')
            .toString(),
      ),
      modifiedDateTime: DateTime.tryParse(
        (json['modifiedDateTime'] ?? json['ModifiedDateTime'] ?? '')
            .toString(),
      ),
    );
  }
}
