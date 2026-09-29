class FundingPaymentOverviewModel {
  final List<FundingPaymentMonthModel> data;
  final List<FundingPaymentSummaryModel> summary;

  FundingPaymentOverviewModel({
    required this.data,
    required this.summary,
  });

  factory FundingPaymentOverviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] ?? json['Data'];
    final rawSummary = json['summary'] ?? json['Summary'];

    return FundingPaymentOverviewModel(
      data: _parseMonthList(rawData),
      summary: _parseSummaryList(rawSummary),
    );
  }

  FundingPaymentSummaryModel? get firstSummary =>
      summary.isEmpty ? null : summary.first;

  static List<FundingPaymentMonthModel> _parseMonthList(dynamic raw) {
    if (raw is! List) return const [];
    final items = <FundingPaymentMonthModel>[];
    for (final item in raw) {
      if (item is Map) {
        items.add(
          FundingPaymentMonthModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }
    return items;
  }

  static List<FundingPaymentSummaryModel> _parseSummaryList(dynamic raw) {
    if (raw is! List) return const [];
    final items = <FundingPaymentSummaryModel>[];
    for (final item in raw) {
      if (item is Map) {
        items.add(
          FundingPaymentSummaryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }
    return items;
  }
}

class FundingPaymentMonthModel {
  final String month;
  final String monthDate;
  final double dueAmount;
  final double fundingReceived;
  final double pendingAmount;

  FundingPaymentMonthModel({
    required this.month,
    required this.monthDate,
    required this.dueAmount,
    required this.fundingReceived,
    required this.pendingAmount,
  });

  factory FundingPaymentMonthModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FundingPaymentMonthModel(
      month: (json['month'] ?? '').toString(),
      monthDate: (json['monthDate'] ?? '').toString(),
      dueAmount: _readDouble(json['dueAmount']),
      fundingReceived: _readDouble(json['fundingReceived']),
      pendingAmount: _readDouble(json['pendingAmount']),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class FundingPaymentSummaryModel {
  final double projectAmount;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;

  FundingPaymentSummaryModel({
    required this.projectAmount,
    required this.totalInvestmentAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
  });

  factory FundingPaymentSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FundingPaymentSummaryModel(
      projectAmount: _readDouble(json['projectAmount']),
      totalInvestmentAmount: _readDouble(json['totalInvestmentAmount']),
      totalPaidAmount: _readDouble(json['totalPaidAmount']),
      totalPendingAmount: _readDouble(json['totalPendingAmount']),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
