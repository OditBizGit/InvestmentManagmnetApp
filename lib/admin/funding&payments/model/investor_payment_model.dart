class AddInvestorPaymentRequestModel {
  final int userId;
  final double paidAmount;
  final String narration;
  final String paymentMethod;
  final bool isFullSettlement;
  final double discountAmount;
  final String remarks;

  /// Medical allowance amount (also mirrored to [extraAmount]).
  /// API `medicalAllowance` is System.String.
  final double medicalAllowance;
  final double extraAmount;
  final int days;

  AddInvestorPaymentRequestModel({
    required this.userId,
    required this.paidAmount,
    required this.narration,
    required this.paymentMethod,
    this.isFullSettlement = false,
    this.discountAmount = 0,
    this.remarks = '',
    this.medicalAllowance = 0,
    this.extraAmount = 0,
    this.days = 0,
  });

  Map<String, dynamic> toJson() {
    final amount = extraAmount > 0 ? extraAmount : medicalAllowance;
    final amountString = amount <= 0
        ? ''
        : (amount == amount.roundToDouble()
            ? amount.toInt().toString()
            : amount.toString());

    return {
      'userId': userId,
      'paidAmount': paidAmount,
      'narration': narration,
      'paymentMethod': paymentMethod,
      'isFullSettlement': isFullSettlement,
      'discountAmount': discountAmount,
      'remarks': remarks,
      // String for legacy combined display ("1500 for 25 days").
      'medicalAllowance': amountString,
      // Numeric medical-allowance amount.
      'extraAmount': amount <= 0 ? 0 : amount,
      'days': days,
    };
  }
}

class AddInvestorPaymentResponseModel {
  final bool status;
  final String message;
  final InvestorPaymentDataModel? data;
  final int code;

  AddInvestorPaymentResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory AddInvestorPaymentResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AddInvestorPaymentResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? InvestorPaymentDataModel.fromJson(json['data'])
          : null,
      code: json['code'] ?? 0,
    );
  }
}

class InvestorPaymentDataModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double remainingAmount;
  final double paidAmount;
  final int entryNo;

  InvestorPaymentDataModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.totalInvestmentAmount,
    required this.totalPaidAmount,
    required this.remainingAmount,
    required this.paidAmount,
    required this.entryNo,
  });

  factory InvestorPaymentDataModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorPaymentDataModel(
      userId: json['userId'] ?? 0,
      investorCode: json['investorCode'] ?? '',
      fullName: json['fullName'] ?? '',
      totalInvestmentAmount:
      (json['totalInvestmentAmount'] ?? 0).toDouble(),
      totalPaidAmount:
      (json['totalPaidAmount'] ?? 0).toDouble(),
      remainingAmount:
      (json['remainingAmount'] ?? 0).toDouble(),
      paidAmount:
      (json['paidAmount'] ?? 0).toDouble(),
      entryNo: json['entryNo'] ?? 0,
    );
  }
}