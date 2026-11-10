class ReviewPaymentVerificationRequestModel {
  ReviewPaymentVerificationRequestModel({
    required this.transactionId,
    required this.status,
    this.remarks = '',
  });

  final int transactionId;
  final String status;
  final String remarks;

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'status': status,
      'remarks': remarks,
    };
  }
}

class ReviewPaymentVerificationResponseModel {
  ReviewPaymentVerificationResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.code,
  });

  final bool status;
  final String message;
  final ReviewPaymentVerificationDataModel? data;
  final int? code;

  factory ReviewPaymentVerificationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewPaymentVerificationResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? ReviewPaymentVerificationDataModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      code: _parseInt(json['code']),
    );
  }
}

class ReviewPaymentVerificationDataModel {
  ReviewPaymentVerificationDataModel({
    required this.transactionId,
    required this.investorId,
    required this.investorName,
    required this.paidAmount,
    this.paymentDate,
    required this.entryNo,
    required this.verificationStatus,
    required this.verifiedBy,
    required this.verifiedByName,
    this.verifiedDate,
    this.remarks,
  });

  final int transactionId;
  final int investorId;
  final String investorName;
  final double paidAmount;
  final DateTime? paymentDate;
  final int entryNo;
  final String verificationStatus;
  final int verifiedBy;
  final String verifiedByName;
  final DateTime? verifiedDate;
  final String? remarks;

  factory ReviewPaymentVerificationDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewPaymentVerificationDataModel(
      transactionId: _parseInt(json['transactionId'] ?? json['TransactionId']) ?? 0,
      investorId: _parseInt(json['investorId'] ?? json['InvestorId']) ?? 0,
      investorName: json['investorName']?.toString() ??
          json['InvestorName']?.toString() ??
          '',
      paidAmount: _parseDouble(json['paidAmount'] ?? json['PaidAmount']) ?? 0,
      paymentDate: _parseDate(json['paymentDate'] ?? json['PaymentDate']),
      entryNo: _parseInt(json['entryNo'] ?? json['EntryNo']) ?? 0,
      verificationStatus: json['verificationStatus']?.toString() ??
          json['VerificationStatus']?.toString() ??
          '',
      verifiedBy: _parseInt(json['verifiedBy'] ?? json['VerifiedBy']) ?? 0,
      verifiedByName: json['verifiedByName']?.toString() ??
          json['VerifiedByName']?.toString() ??
          '',
      verifiedDate: _parseDate(json['verifiedDate'] ?? json['VerifiedDate']),
      remarks: json['remarks']?.toString() ?? json['Remarks']?.toString(),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _parseDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
