class InvestorTransactionItemModel {
  final int transactionId;
  final int userId;
  final String investorCode;
  final String fullName;
  final DateTime? date;
  final int entryNo;
  final double investmentAmount;
  final double paidAmount;
  final double receivedAmount;
  final double pendingAmount;
  final String status;
  final String narration;
  final String paymentMethod;

  const InvestorTransactionItemModel({
    required this.transactionId,
    required this.userId,
    required this.investorCode,
    required this.fullName,
    this.date,
    required this.entryNo,
    this.investmentAmount = 0,
    this.paidAmount = 0,
    this.receivedAmount = 0,
    this.pendingAmount = 0,
    this.status = '',
    this.narration = '',
    this.paymentMethod = '',
  });

  factory InvestorTransactionItemModel.fromJson(Map<String, dynamic> json) {
    return InvestorTransactionItemModel(
      transactionId: _readInt(json['transactionId'] ?? json['TransactionId']),
      userId: _readInt(json['userId'] ?? json['UserId']),
      investorCode:
          (json['investorCode'] ?? json['InvestorCode'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      date: _readDate(json['date'] ?? json['Date']),
      entryNo: _readInt(json['entryNo'] ?? json['EntryNo']),
      investmentAmount: _readDouble(
        json['investmentAmount'] ?? json['InvestmentAmount'],
      ),
      paidAmount: _readDouble(json['paidAmount'] ?? json['PaidAmount']),
      receivedAmount: _readDouble(
        json['receivedAmount'] ?? json['ReceivedAmount'],
      ),
      pendingAmount: _readDouble(
        json['pendingAmount'] ?? json['PendingAmount'],
      ),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      narration: (json['narration'] ?? json['Narration'] ?? '').toString(),
      paymentMethod:
          (json['paymentMethod'] ?? json['PaymentMethod'] ?? '').toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
