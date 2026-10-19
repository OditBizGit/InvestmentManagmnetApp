class RefundInvestorRequestModel {
  const RefundInvestorRequestModel({
    required this.userId,
    required this.refundAmount,
    required this.paymentMethod,
    required this.remarks,
  });

  final int userId;
  final double refundAmount;
  final String paymentMethod;
  final String remarks;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'refundAmount': refundAmount,
      'paymentMethod': paymentMethod,
      'remarks': remarks,
    };
  }
}

class RefundInvestorDataModel {
  const RefundInvestorDataModel({
    required this.refundId,
    required this.userId,
    required this.refundAmount,
    required this.totalReceivedAmount,
    required this.totalRefundedAmount,
    required this.remainingRefundableAmount,
    required this.paymentMethod,
    this.refundDate,
    this.status,
  });

  final int refundId;
  final int userId;
  final double refundAmount;
  final double totalReceivedAmount;
  final double totalRefundedAmount;
  final double remainingRefundableAmount;
  final String paymentMethod;
  final DateTime? refundDate;
  final String? status;

  factory RefundInvestorDataModel.fromJson(Map<String, dynamic> json) {
    return RefundInvestorDataModel(
      refundId: _readInt(json['RefundId'] ?? json['refundId']),
      userId: _readInt(json['UserId'] ?? json['userId']),
      refundAmount: _readDouble(json['RefundAmount'] ?? json['refundAmount']),
      totalReceivedAmount: _readDouble(
        json['TotalReceivedAmount'] ?? json['totalReceivedAmount'],
      ),
      totalRefundedAmount: _readDouble(
        json['TotalRefundedAmount'] ?? json['totalRefundedAmount'],
      ),
      remainingRefundableAmount: _readDouble(
        json['RemainingRefundableAmount'] ??
            json['remainingRefundableAmount'],
      ),
      paymentMethod:
          (json['PaymentMethod'] ?? json['paymentMethod'] ?? '').toString(),
      refundDate: _readDate(json['RefundDate'] ?? json['refundDate']),
      status: (json['Status'] ?? json['status'])?.toString(),
    );
  }
}

class RefundInvestorResponseModel {
  const RefundInvestorResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final RefundInvestorDataModel? data;
  final int code;

  factory RefundInvestorResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    RefundInvestorDataModel? data;
    if (rawData is Map) {
      data = RefundInvestorDataModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    }

    return RefundInvestorResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString().trim(),
      data: data,
      code: _readInt(json['code'] ?? json['Code']),
    );
  }
}

bool _readStatus(dynamic value) {
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

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}
