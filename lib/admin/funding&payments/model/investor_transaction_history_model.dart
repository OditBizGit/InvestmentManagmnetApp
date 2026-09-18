class InvestorTransactionHistoryResponseModel {
  final bool status;
  final String message;
  final List<InvestorTransactionHistoryModel> data;

  InvestorTransactionHistoryResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory InvestorTransactionHistoryResponseModel.fromJson(
    dynamic json,
  ) {
    if (json is! Map) {
      return InvestorTransactionHistoryResponseModel(
        status: false,
        message: 'Unexpected response format',
        data: const [],
      );
    }

    final map = Map<String, dynamic>.from(json);
    final rawData = map['data'];

    final List<InvestorTransactionHistoryModel> parsed = [];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          try {
            parsed.add(
              InvestorTransactionHistoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Skip malformed rows so one bad entry does not crash the screen.
          }
        }
      }
    }

    return InvestorTransactionHistoryResponseModel(
      status: map['status'] == true,
      message: map['message']?.toString() ?? '',
      data: parsed,
    );
  }
}

class InvestorTransactionHistoryModel {
  final int transactionId;
  final int userId;
  final String investorCode;
  final String fullName;
  final DateTime date;
  final int entryNo;
  final double investmentAmount;
  final double receivedAmount;
  final double pendingAmount;
  final String status;
  final String narration;

  InvestorTransactionHistoryModel({
    required this.transactionId,
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.date,
    required this.entryNo,
    required this.investmentAmount,
    required this.receivedAmount,
    required this.pendingAmount,
    required this.status,
    required this.narration,
  });

  factory InvestorTransactionHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestorTransactionHistoryModel(
      transactionId: _readInt(json['transactionId']),
      userId: _readInt(json['userId']),
      investorCode: json['investorCode']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      entryNo: _readInt(json['entryNo']),
      investmentAmount: _readDouble(json['investmentAmount']),
      receivedAmount: _readDouble(json['receivedAmount']),
      pendingAmount: _readDouble(json['pendingAmount']),
      status: json['status']?.toString() ?? '',
      narration: json['narration']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'investorCode': investorCode,
      'fullName': fullName,
      'date': date.toIso8601String(),
      'entryNo': entryNo,
      'investmentAmount': investmentAmount,
      'receivedAmount': receivedAmount,
      'pendingAmount': pendingAmount,
      'status': status,
      'narration': narration,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
