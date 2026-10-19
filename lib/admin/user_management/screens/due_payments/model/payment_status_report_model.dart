class PaymentStatusReportResponseModel {
  final bool status;
  final String message;
  final List<PaymentStatusReportModel> data;
  final int code;

  const PaymentStatusReportResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory PaymentStatusReportResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentStatusReportResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PaymentStatusReportModel.fromJson)
          .toList(),
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class PaymentStatusReportModel {
  final int userId;
  final String investorCode;
  final String name;
  final String email;
  final String phoneNumber;
  final double totalPayable;
  final double amountPaid;
  final double outstanding;
  final String paymentStatus;
  final double? latestPaymentAmount;
  final String? paymentMethod;
  final String? narration;
  final DateTime? paymentDate;

  const PaymentStatusReportModel({
    required this.userId,
    required this.investorCode,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.totalPayable,
    required this.amountPaid,
    required this.outstanding,
    required this.paymentStatus,
    this.latestPaymentAmount,
    this.paymentMethod,
    this.narration,
    this.paymentDate,
  });

  factory PaymentStatusReportModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentStatusReportModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      investorCode: json['investorCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      totalPayable: _toDouble(json['totalPayable']),
      amountPaid: _toDouble(json['amountPaid']),
      outstanding: _toDouble(json['outstanding']),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      latestPaymentAmount: json['latestPaymentAmount'] == null
          ? null
          : _toDouble(json['latestPaymentAmount']),
      paymentMethod: json['paymentMethod']?.toString(),
      narration: json['narration']?.toString(),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.tryParse(json['paymentDate'].toString()),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}