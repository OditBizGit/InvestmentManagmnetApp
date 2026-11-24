num? _parse(dynamic value) {
  if (value is num) return value;
  if (value == null) return null;
  return num.tryParse(value.toString());
}

double _num(dynamic value) => _parse(value)?.toDouble() ?? 0;

int _int(dynamic value) => _parse(value)?.toInt() ?? 0;

DateTime? _date(dynamic value) =>
    value is String ? DateTime.tryParse(value) : null;

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

class RefundRowModel {
  const RefundRowModel({
    this.refundId = 0,
    this.requestId = 0,
    this.userId = 0,
    this.investorCode = '',
    this.name = '',
    this.refundDate,
    this.refundAmount = 0,
    this.paymentMethod = '',
    this.remarks = '',
  });

  factory RefundRowModel.fromJson(Map<String, dynamic> json) {
    return RefundRowModel(
      refundId: _int(json['refundId']),
      requestId: _int(json['requestId']),
      userId: _int(json['userId']),
      investorCode: json['investorCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      refundDate: _date(json['refundDate']),
      refundAmount: _num(json['refundAmount']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  final int refundId;
  final int requestId;
  final int userId;
  final String investorCode;
  final String name;
  final DateTime? refundDate;
  final double refundAmount;
  final String paymentMethod;
  final String remarks;
}

class TerminatedInvestorModel {
  const TerminatedInvestorModel({
    this.userId = 0,
    this.investorCode = '',
    this.name = '',
    this.terminatedDate,
    this.dateSource = '',
    this.totalPayable = 0,
    this.totalPaid = 0,
    this.totalRefunded = 0,
    this.pendingRefundRequests = 0,
    this.remainingRefundable = 0,
  });

  factory TerminatedInvestorModel.fromJson(Map<String, dynamic> json) {
    return TerminatedInvestorModel(
      userId: _int(json['userId']),
      investorCode: json['investorCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      terminatedDate: _date(json['terminatedDate']),
      dateSource: json['dateSource']?.toString() ?? '',
      totalPayable: _num(json['totalPayable']),
      totalPaid: _num(json['totalPaid']),
      totalRefunded: _num(json['totalRefunded']),
      pendingRefundRequests: _num(json['pendingRefundRequests']),
      remainingRefundable: _num(json['remainingRefundable']),
    );
  }

  final int userId;
  final String investorCode;
  final String name;
  final DateTime? terminatedDate;

  /// "BlockRequest" or "ModifiedDate" (approximate).
  final String dateSource;
  final double totalPayable;
  final double totalPaid;
  final double totalRefunded;

  /// An amount (sum of pending refund requests), not a count.
  final double pendingRefundRequests;
  final double remainingRefundable;

  bool get isApproximateDate => dateSource == 'ModifiedDate';
}

class RefundTerminationTotalsModel {
  const RefundTerminationTotalsModel({
    this.refundCount = 0,
    this.refundAmount = 0,
    this.terminatedCount = 0,
    this.totalPaid = 0,
    this.totalRefunded = 0,
    this.remainingRefundable = 0,
  });

  factory RefundTerminationTotalsModel.fromJson(Map<String, dynamic> json) {
    return RefundTerminationTotalsModel(
      refundCount: _int(json['refundCount']),
      refundAmount: _num(json['refundAmount']),
      terminatedCount: _int(json['terminatedCount']),
      totalPaid: _num(json['totalPaid']),
      totalRefunded: _num(json['totalRefunded']),
      remainingRefundable: _num(json['remainingRefundable']),
    );
  }

  final int refundCount;
  final double refundAmount;
  final int terminatedCount;
  final double totalPaid;
  final double totalRefunded;
  final double remainingRefundable;
}

/// The `data` object of `GET /api/Report/RefundTermination`.
class RefundTerminationReportModel {
  const RefundTerminationReportModel({
    this.refunds = const [],
    this.terminated = const [],
    this.totals = const RefundTerminationTotalsModel(),
  });

  factory RefundTerminationReportModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'];
    return RefundTerminationReportModel(
      refunds: _maps(json['refunds']).map(RefundRowModel.fromJson).toList(),
      terminated: _maps(
        json['terminated'],
      ).map(TerminatedInvestorModel.fromJson).toList(),
      totals: totals is Map
          ? RefundTerminationTotalsModel.fromJson(
              Map<String, dynamic>.from(totals),
            )
          : const RefundTerminationTotalsModel(),
    );
  }

  final List<RefundRowModel> refunds;
  final List<TerminatedInvestorModel> terminated;
  final RefundTerminationTotalsModel totals;
}
