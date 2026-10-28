class AcceptOrRejectPaymentRequestModel {
  final int requestId;
  final String status;
  final String remarks;

  AcceptOrRejectPaymentRequestModel({
    required this.requestId,
    required this.status,
    this.remarks = '',
  });

  Map<String, dynamic> toJson() {
    return {'requestId': requestId, 'status': status, 'remarks': remarks};
  }
}

class AcceptOrRejectPaymentResponseModel {
  final bool status;
  final String message;
  final AcceptOrRejectPaymentDataModel? data;
  final int? code;

  AcceptOrRejectPaymentResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.code,
  });

  factory AcceptOrRejectPaymentResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AcceptOrRejectPaymentResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AcceptOrRejectPaymentDataModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
      code: json['code'],
    );
  }
}

class AcceptOrRejectPaymentDataModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double remainingAmount;
  final double paidAmount;
  final String paymentMethod;
  final int requestId;
  final String status;
  final int entryNo;

  AcceptOrRejectPaymentDataModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.totalInvestmentAmount,
    required this.totalPaidAmount,
    required this.remainingAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.requestId,
    required this.status,
    required this.entryNo,
  });

  factory AcceptOrRejectPaymentDataModel.fromJson(Map<String, dynamic> json) {
    return AcceptOrRejectPaymentDataModel(
      userId: json['userId'] ?? 0,
      investorCode: json['investorCode'] ?? '',
      fullName: json['fullName'] ?? '',
      totalInvestmentAmount:
          (json['totalInvestmentAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      requestId: json['requestId'] ?? 0,
      status: json['status'] ?? '',
      entryNo: json['entryNo'] ?? 0,
    );
  }
}
