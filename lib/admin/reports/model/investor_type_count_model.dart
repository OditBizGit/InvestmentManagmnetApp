class InvestorTypeCountModel {
  final int totalInvestors;
  final List<InvestorTypeCountItem> investorTypes;

  InvestorTypeCountModel({
    required this.totalInvestors,
    required this.investorTypes,
  });

  factory InvestorTypeCountModel.fromJson(Map<String, dynamic> json) {
    return InvestorTypeCountModel(
      totalInvestors: json['totalInvestors'] ?? 0,
      investorTypes: (json['investorTypes'] as List<dynamic>?)
          ?.map(
            (item) => InvestorTypeCountItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }
}

class InvestorTypeCountItem {
  final String investorType;
  final int count;

  InvestorTypeCountItem({
    required this.investorType,
    required this.count,
  });

  factory InvestorTypeCountItem.fromJson(Map<String, dynamic> json) {
    return InvestorTypeCountItem(
      investorType: json['investorType'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}