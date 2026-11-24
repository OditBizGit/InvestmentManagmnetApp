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

class CollectionAgingRowModel {
  const CollectionAgingRowModel({
    this.userId = 0,
    this.investorCode = '',
    this.name = '',
    this.phoneNumber = '',
    this.isActive = false,
    this.totalPayable = 0,
    this.amountPaid = 0,
    this.outstanding = 0,
    this.notYetDue = 0,
    this.days1To30 = 0,
    this.days31To60 = 0,
    this.days61To90 = 0,
    this.days90Plus = 0,
    this.totalOverdue = 0,
    this.oldestDueDate,
    this.maxDaysPastDue = 0,
  });

  factory CollectionAgingRowModel.fromJson(Map<String, dynamic> json) {
    return CollectionAgingRowModel(
      userId: _int(json['userId']),
      investorCode: json['investorCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      isActive: json['isActive'] == true,
      totalPayable: _num(json['totalPayable']),
      amountPaid: _num(json['amountPaid']),
      outstanding: _num(json['outstanding']),
      notYetDue: _num(json['notYetDue']),
      days1To30: _num(json['days1To30']),
      days31To60: _num(json['days31To60']),
      days61To90: _num(json['days61To90']),
      days90Plus: _num(json['days90Plus']),
      totalOverdue: _num(json['totalOverdue']),
      oldestDueDate: _date(json['oldestDueDate']),
      maxDaysPastDue: _int(json['maxDaysPastDue']),
    );
  }

  final int userId;
  final String investorCode;
  final String name;
  final String phoneNumber;
  final bool isActive;
  final double totalPayable;
  final double amountPaid;
  final double outstanding;
  final double notYetDue;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double days90Plus;
  final double totalOverdue;
  final DateTime? oldestDueDate;
  final int maxDaysPastDue;

  /// True when part of the outstanding amount (unpaid advance) is not in any
  /// due bucket.
  bool get hasUnbucketedOutstanding {
    final bucketSum =
        notYetDue + days1To30 + days31To60 + days61To90 + days90Plus;
    return bucketSum < outstanding - 0.005;
  }
}

class CollectionAgingTotalsModel {
  const CollectionAgingTotalsModel({
    this.investorCount = 0,
    this.notYetDue = 0,
    this.days1To30 = 0,
    this.days31To60 = 0,
    this.days61To90 = 0,
    this.days90Plus = 0,
    this.totalOverdue = 0,
    this.outstanding = 0,
  });

  factory CollectionAgingTotalsModel.fromJson(Map<String, dynamic> json) {
    return CollectionAgingTotalsModel(
      investorCount: _int(json['investorCount']),
      notYetDue: _num(json['notYetDue']),
      days1To30: _num(json['days1To30']),
      days31To60: _num(json['days31To60']),
      days61To90: _num(json['days61To90']),
      days90Plus: _num(json['days90Plus']),
      totalOverdue: _num(json['totalOverdue']),
      outstanding: _num(json['outstanding']),
    );
  }

  final int investorCount;
  final double notYetDue;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double days90Plus;
  final double totalOverdue;
  final double outstanding;
}

/// The `data` object of `GET /api/Report/CollectionAging`.
class CollectionAgingReportModel {
  const CollectionAgingReportModel({
    this.asOfDate,
    this.rows = const [],
    this.totals = const CollectionAgingTotalsModel(),
  });

  factory CollectionAgingReportModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'];
    return CollectionAgingReportModel(
      asOfDate: _date(json['asOfDate']),
      rows: _maps(json['rows']).map(CollectionAgingRowModel.fromJson).toList(),
      totals: totals is Map
          ? CollectionAgingTotalsModel.fromJson(
              Map<String, dynamic>.from(totals),
            )
          : const CollectionAgingTotalsModel(),
    );
  }

  final DateTime? asOfDate;
  final List<CollectionAgingRowModel> rows;
  final CollectionAgingTotalsModel totals;
}
