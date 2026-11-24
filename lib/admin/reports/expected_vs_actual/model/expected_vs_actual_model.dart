double _readDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;

int _readInt(dynamic value) => (value as num?)?.toInt() ?? 0;

String _readString(dynamic value) => value?.toString().trim() ?? '';

DateTime? _readDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

double? _readRate(dynamic value) => (value as num?)?.toDouble();

List<Map<String, dynamic>> _readList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _readMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

/// One month row, or the totals row when [month] is null.
class ExpectedVsActualRow {
  const ExpectedVsActualRow({
    this.month,
    this.expectedAmount = 0,
    this.expectedInstallments = 0,
    this.actualPayments = 0,
    this.advancePayments = 0,
    this.refunds = 0,
    this.actualAmount = 0,
    this.collectionRate,
  });

  factory ExpectedVsActualRow.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualRow(
      month: _readDate(json['month']),
      expectedAmount: _readDouble(json['expectedAmount']),
      expectedInstallments: _readInt(json['expectedInstallments']),
      actualPayments: _readDouble(json['actualPayments']),
      advancePayments: _readDouble(json['advancePayments']),
      refunds: _readDouble(json['refunds']),
      actualAmount: _readDouble(json['actualAmount']),
      collectionRate: _readRate(json['collectionRate']),
    );
  }

  final DateTime? month;
  final double expectedAmount;
  final int expectedInstallments;
  final double actualPayments;
  final double advancePayments;
  final double refunds;
  final double actualAmount;

  /// Null when nothing was expected.
  final double? collectionRate;
}

class ExpectedVsActualReport {
  const ExpectedVsActualReport({
    this.fromMonth,
    this.toMonth,
    this.months = const [],
    this.totals = const ExpectedVsActualRow(),
  });

  factory ExpectedVsActualReport.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualReport(
      fromMonth: _readDate(json['fromMonth']),
      toMonth: _readDate(json['toMonth']),
      months: _readList(
        json['months'],
      ).map(ExpectedVsActualRow.fromJson).toList(growable: false),
      totals: ExpectedVsActualRow.fromJson(_readMap(json['totals'])),
    );
  }

  final DateTime? fromMonth;
  final DateTime? toMonth;
  final List<ExpectedVsActualRow> months;
  final ExpectedVsActualRow totals;
}

class ExpectedVsActualResponseModel {
  const ExpectedVsActualResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExpectedVsActualResponseModel.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualResponseModel(
      success: json['success'] == true,
      message: _readString(json['message']),
      data: ExpectedVsActualReport.fromJson(_readMap(json['data'])),
    );
  }

  final bool success;
  final String message;
  final ExpectedVsActualReport data;
}

/// One investor row of a month drill-down.
class ExpectedVsActualInvestorRow {
  const ExpectedVsActualInvestorRow({
    this.userId = 0,
    this.investorCode = '',
    this.name = '',
    this.phoneNumber = '',
    this.isActive = true,
    this.expectedAmount = 0,
    this.expectedInstallments = 0,
    this.actualPayments = 0,
    this.advancePayments = 0,
    this.refunds = 0,
    this.actualAmount = 0,
    this.collectionRate,
  });

  factory ExpectedVsActualInvestorRow.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualInvestorRow(
      userId: _readInt(json['userId']),
      investorCode: _readString(json['investorCode']),
      name: _readString(json['name']),
      phoneNumber: _readString(json['phoneNumber']),
      isActive: json['isActive'] != false,
      expectedAmount: _readDouble(json['expectedAmount']),
      expectedInstallments: _readInt(json['expectedInstallments']),
      actualPayments: _readDouble(json['actualPayments']),
      advancePayments: _readDouble(json['advancePayments']),
      refunds: _readDouble(json['refunds']),
      actualAmount: _readDouble(json['actualAmount']),
      collectionRate: _readRate(json['collectionRate']),
    );
  }

  final int userId;
  final String investorCode;
  final String name;
  final String phoneNumber;
  final bool isActive;
  final double expectedAmount;
  final int expectedInstallments;
  final double actualPayments;
  final double advancePayments;
  final double refunds;
  final double actualAmount;
  final double? collectionRate;
}

class ExpectedVsActualDetailsTotals {
  const ExpectedVsActualDetailsTotals({
    this.investorCount = 0,
    this.expectedAmount = 0,
    this.expectedInstallments = 0,
    this.actualPayments = 0,
    this.advancePayments = 0,
    this.refunds = 0,
    this.actualAmount = 0,
    this.collectionRate,
  });

  factory ExpectedVsActualDetailsTotals.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualDetailsTotals(
      investorCount: _readInt(json['investorCount']),
      expectedAmount: _readDouble(json['expectedAmount']),
      expectedInstallments: _readInt(json['expectedInstallments']),
      actualPayments: _readDouble(json['actualPayments']),
      advancePayments: _readDouble(json['advancePayments']),
      refunds: _readDouble(json['refunds']),
      actualAmount: _readDouble(json['actualAmount']),
      collectionRate: _readRate(json['collectionRate']),
    );
  }

  final int investorCount;
  final double expectedAmount;
  final int expectedInstallments;
  final double actualPayments;
  final double advancePayments;
  final double refunds;
  final double actualAmount;
  final double? collectionRate;
}

class ExpectedVsActualDetails {
  const ExpectedVsActualDetails({
    this.month,
    this.rows = const [],
    this.totals = const ExpectedVsActualDetailsTotals(),
  });

  factory ExpectedVsActualDetails.fromJson(Map<String, dynamic> json) {
    return ExpectedVsActualDetails(
      month: _readDate(json['month']),
      rows: _readList(
        json['rows'],
      ).map(ExpectedVsActualInvestorRow.fromJson).toList(growable: false),
      totals: ExpectedVsActualDetailsTotals.fromJson(_readMap(json['totals'])),
    );
  }

  final DateTime? month;
  final List<ExpectedVsActualInvestorRow> rows;
  final ExpectedVsActualDetailsTotals totals;
}

class ExpectedVsActualDetailsResponseModel {
  const ExpectedVsActualDetailsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExpectedVsActualDetailsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExpectedVsActualDetailsResponseModel(
      success: json['success'] == true,
      message: _readString(json['message']),
      data: ExpectedVsActualDetails.fromJson(_readMap(json['data'])),
    );
  }

  final bool success;
  final String message;
  final ExpectedVsActualDetails data;
}
