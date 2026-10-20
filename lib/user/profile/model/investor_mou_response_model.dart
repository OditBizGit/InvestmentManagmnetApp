class InvestorMouResponseModel {
  const InvestorMouResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final List<InvestorMouModel> data;
  final int code;

  factory InvestorMouResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final items = <InvestorMouModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          items.add(
            InvestorMouModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return InvestorMouResponseModel(
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

class InvestorMouModel {
  const InvestorMouModel({
    required this.id,
    required this.investorId,
    required this.status,
    this.createdDateTime,
    this.modifiedDateTime,
  });

  final int id;
  final int investorId;
  final String status;
  final DateTime? createdDateTime;
  final DateTime? modifiedDateTime;

  factory InvestorMouModel.fromJson(Map<String, dynamic> json) {
    return InvestorMouModel(
      id: _readInt(json['id'] ?? json['Id']),
      investorId: _readInt(json['investorId'] ?? json['InvestorId']),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      createdDateTime: _readDateTime(
        json['createdDateTime'] ?? json['CreatedDateTime'],
      ),
      modifiedDateTime: _readDateTime(
        json['modifiedDateTime'] ?? json['ModifiedDateTime'],
      ),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
