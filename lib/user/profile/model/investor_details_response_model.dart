import 'investor_details_model.dart';

class InvestorDetailsResponseModel {
  final bool status;
  final String message;
  final InvestorDetailsModel? data;
  final int code;

  const InvestorDetailsResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory InvestorDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];

    return InvestorDetailsResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: rawData is Map
          ? InvestorDetailsModel.fromJson(
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
