double _readDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;

int _readInt(dynamic value) => (value as num?)?.toInt() ?? 0;

String _readString(dynamic value) => value?.toString().trim() ?? '';

DateTime? _readDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

List<Map<String, dynamic>> _readList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _readMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

class InvestorStatementHeader {
  const InvestorStatementHeader({
    this.userId = 0,
    this.investorCode = '',
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.isActive = true,
    this.investmentStartDate,
    this.commitmentAmount = 0,
    this.grossPaid = 0,
    this.refunds = 0,
    this.netPaid = 0,
    this.discount = 0,
    this.pending = 0,
    this.isSettled = false,
    this.settlementAmount = 0,
    this.settlementDate,
    this.openingBalance = 0,
    this.closingBalance = 0,
    this.fromDate,
    this.toDate,
  });

  factory InvestorStatementHeader.fromJson(Map<String, dynamic> json) {
    return InvestorStatementHeader(
      userId: _readInt(json['userId']),
      investorCode: _readString(json['investorCode']),
      name: _readString(json['name']),
      phoneNumber: _readString(json['phoneNumber']),
      email: _readString(json['email']),
      isActive: json['isActive'] != false,
      investmentStartDate: _readDate(json['investmentStartDate']),
      commitmentAmount: _readDouble(json['commitmentAmount']),
      grossPaid: _readDouble(json['grossPaid']),
      refunds: _readDouble(json['refunds']),
      netPaid: _readDouble(json['netPaid']),
      discount: _readDouble(json['discount']),
      pending: _readDouble(json['pending']),
      isSettled: json['isSettled'] == true,
      settlementAmount: _readDouble(json['settlementAmount']),
      settlementDate: _readDate(json['settlementDate']),
      openingBalance: _readDouble(json['openingBalance']),
      closingBalance: _readDouble(json['closingBalance']),
      fromDate: _readDate(json['fromDate']),
      toDate: _readDate(json['toDate']),
    );
  }

  final int userId;
  final String investorCode;
  final String name;
  final String phoneNumber;
  final String email;
  final bool isActive;
  final DateTime? investmentStartDate;
  final double commitmentAmount;
  final double grossPaid;
  final double refunds;
  final double netPaid;
  final double discount;

  /// Follows the schedule rules; can differ from [closingBalance].
  final double pending;
  final bool isSettled;
  final double settlementAmount;
  final DateTime? settlementDate;
  final double openingBalance;
  final double closingBalance;
  final DateTime? fromDate;
  final DateTime? toDate;
}

class InvestorStatementLedgerEntry {
  const InvestorStatementLedgerEntry({
    this.lineNo = 0,
    this.entryDate,
    this.entryType = '',
    this.reference = '',
    this.description = '',
    this.paymentMethod = '',
    this.verificationStatus = '',
    this.chargeAmount = 0,
    this.paymentAmount = 0,
    this.runningBalance = 0,
  });

  factory InvestorStatementLedgerEntry.fromJson(Map<String, dynamic> json) {
    return InvestorStatementLedgerEntry(
      lineNo: _readInt(json['lineNo']),
      entryDate: _readDate(json['entryDate']),
      entryType: _readString(json['entryType']),
      reference: _readString(json['reference']),
      description: _readString(json['description']),
      paymentMethod: _readString(json['paymentMethod']),
      verificationStatus: _readString(json['verificationStatus']),
      chargeAmount: _readDouble(json['chargeAmount']),
      paymentAmount: _readDouble(json['paymentAmount']),
      runningBalance: _readDouble(json['runningBalance']),
    );
  }

  final int lineNo;
  final DateTime? entryDate;

  /// Investment, Payment, Discount or Refund.
  final String entryType;
  final String reference;
  final String description;
  final String paymentMethod;

  /// Approved or Pending.
  final String verificationStatus;
  final double chargeAmount;
  final double paymentAmount;
  final double runningBalance;
}

class InvestorStatementScheduleItem {
  const InvestorStatementScheduleItem({
    this.installmentNo = 0,
    this.dueDate,
    this.amount = 0,
    this.paidAmount = 0,
    this.pendingAmount = 0,
    this.status = '',
    this.daysOverdue = 0,
  });

  factory InvestorStatementScheduleItem.fromJson(Map<String, dynamic> json) {
    return InvestorStatementScheduleItem(
      installmentNo: _readInt(json['installmentNo']),
      dueDate: _readDate(json['dueDate']),
      amount: _readDouble(json['amount']),
      paidAmount: _readDouble(json['paidAmount']),
      pendingAmount: _readDouble(json['pendingAmount']),
      status: _readString(json['status']),
      daysOverdue: _readInt(json['daysOverdue']),
    );
  }

  final int installmentNo;
  final DateTime? dueDate;
  final double amount;
  final double paidAmount;
  final double pendingAmount;

  /// Completed, Partially Completed or Pending.
  final String status;
  final int daysOverdue;
}

class InvestorStatement {
  const InvestorStatement({
    this.header = const InvestorStatementHeader(),
    this.ledger = const [],
    this.schedule = const [],
  });

  factory InvestorStatement.fromJson(Map<String, dynamic> json) {
    return InvestorStatement(
      header: InvestorStatementHeader.fromJson(_readMap(json['header'])),
      ledger: _readList(
        json['ledger'],
      ).map(InvestorStatementLedgerEntry.fromJson).toList(growable: false),
      schedule: _readList(
        json['schedule'],
      ).map(InvestorStatementScheduleItem.fromJson).toList(growable: false),
    );
  }

  final InvestorStatementHeader header;
  final List<InvestorStatementLedgerEntry> ledger;
  final List<InvestorStatementScheduleItem> schedule;
}

class InvestorStatementResponseModel {
  const InvestorStatementResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InvestorStatementResponseModel.fromJson(Map<String, dynamic> json) {
    return InvestorStatementResponseModel(
      success: json['success'] == true,
      message: _readString(json['message']),
      data: InvestorStatement.fromJson(_readMap(json['data'])),
    );
  }

  final bool success;
  final String message;
  final InvestorStatement data;
}
