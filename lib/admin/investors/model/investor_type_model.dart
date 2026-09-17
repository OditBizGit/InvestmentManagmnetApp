class InvestorTypeResponseModel {
  final bool status;
  final String message;
  final List<InvestorTypeModel> data;
  final int code;

  InvestorTypeResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory InvestorTypeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] ?? json['Data'];
    final list = rawData is List ? rawData : const <dynamic>[];

    return InvestorTypeResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: list
          .whereType<Map>()
          .map(
            (item) => InvestorTypeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
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

class InvestorTypeModel {
  final int investorTypeId;
  final String investorTypeName;

  InvestorTypeModel({
    required this.investorTypeId,
    required this.investorTypeName,
  });

  factory InvestorTypeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestorTypeModel(
      investorTypeId: _readInt(
        json['InvestorTypeId'] ?? json['investorTypeId'],
      ),
      investorTypeName: (json['InvestorTypeName'] ??
              json['investorTypeName'] ??
              '')
          .toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
