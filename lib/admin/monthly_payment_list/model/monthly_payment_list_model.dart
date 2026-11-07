
class MonthlyPaymentListResponseModel {
  final bool status;
  final String message;
  final MonthlyPaymentListDataModel? data;

  MonthlyPaymentListResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory MonthlyPaymentListResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MonthlyPaymentListResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? MonthlyPaymentListDataModel.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }
}

class MonthlyPaymentListDataModel {
  final int totalPayments;
  final double totalAmount;
  final List<MonthlyPaymentTransactionModel> transactions;

  MonthlyPaymentListDataModel({
    required this.totalPayments,
    required this.totalAmount,
    required this.transactions,
  });

  factory MonthlyPaymentListDataModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MonthlyPaymentListDataModel(
      totalPayments: _parseInt(json['totalPayments']) ?? 0,
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      transactions: json['transactions'] is List
          ? (json['transactions'] as List)
          .whereType<Map>()
          .map(
            (item) => MonthlyPaymentTransactionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }
}

class MonthlyPaymentTransactionModel {
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

  MonthlyPaymentTransactionModel({
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
  });

  factory MonthlyPaymentTransactionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MonthlyPaymentTransactionModel(
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
