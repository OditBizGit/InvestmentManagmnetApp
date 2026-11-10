class PaymentVerificationHistoryResponseModel {
  PaymentVerificationHistoryResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  final bool status;
  final String message;
  final PaymentVerificationHistoryDataModel? data;

  factory PaymentVerificationHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentVerificationHistoryResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? PaymentVerificationHistoryDataModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}

class PaymentVerificationHistoryDataModel {
  PaymentVerificationHistoryDataModel({
    required this.totalPayments,
    required this.totalAmount,
    required this.transactions,
  });

  final int totalPayments;
  final double totalAmount;
  final List<PaymentVerificationHistoryTransactionModel> transactions;

  factory PaymentVerificationHistoryDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentVerificationHistoryDataModel(
      totalPayments: _parseInt(json['totalPayments']) ?? 0,
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      transactions: json['transactions'] is List
          ? (json['transactions'] as List)
              .whereType<Map>()
              .map(
                (item) => PaymentVerificationHistoryTransactionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}

class PaymentVerificationHistoryTransactionModel {
  PaymentVerificationHistoryTransactionModel({
    required this.transactionId,
    required this.investorId,
    required this.userId,
    required this.investorName,
    required this.investorCode,
    required this.mobileNumber,
    required this.staffName,
    required this.paymentMethod,
    required this.paidAmount,
    this.paymentDate,
    required this.entryNo,
    required this.receiptNumber,
    required this.paymentStatus,
    required this.verificationStatus,
    this.verifiedBy,
    this.verifiedByName,
    this.verifiedDate,
    this.remarks,
  });

  final int transactionId;
  final int investorId;
  final int userId;
  final String investorName;
  final String investorCode;
  final String mobileNumber;
  final String staffName;
  final String paymentMethod;
  final double paidAmount;
  final DateTime? paymentDate;
  final int entryNo;
  final int receiptNumber;
  final String paymentStatus;
  final String verificationStatus;
  final int? verifiedBy;
  final String? verifiedByName;
  final DateTime? verifiedDate;
  final String? remarks;

  factory PaymentVerificationHistoryTransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentVerificationHistoryTransactionModel(
      transactionId: _parseInt(json['transactionId']) ?? 0,
      investorId: _parseInt(json['investorId']) ?? 0,
      userId: _parseInt(json['userId']) ?? 0,
      investorName: json['investorName']?.toString() ?? '',
      investorCode: json['investorCode']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      staffName: json['staffName']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paidAmount: _parseDouble(json['paidAmount']) ?? 0.0,
      paymentDate: _parseDate(json['paymentDate']),
      entryNo: _parseInt(json['entryNo']) ?? 0,
      receiptNumber: _parseInt(json['receiptNumber']) ?? 0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      verificationStatus: json['verificationStatus']?.toString() ?? '',
      verifiedBy: _parseInt(json['verifiedBy']),
      verifiedByName: _parseOptionalString(json['verifiedByName']),
      verifiedDate: _parseDate(json['verifiedDate']),
      remarks: _parseOptionalString(json['remarks']),
    );
  }
}

String? _parseOptionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
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
