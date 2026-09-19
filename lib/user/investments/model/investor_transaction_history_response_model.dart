import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_data_model.dart';

class InvestorTransactionHistoryResponseModel {
  final bool status;
  final String message;
  final InvestorTransactionHistoryDataModel? data;
  final int code;

  const InvestorTransactionHistoryResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory InvestorTransactionHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] ?? json['Data'];

    return InvestorTransactionHistoryResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: rawData is Map
          ? InvestorTransactionHistoryDataModel.fromJson(
              Map<String, dynamic>.from(rawData),
            )
          : null,
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
