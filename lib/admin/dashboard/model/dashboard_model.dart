class DashboardModel {
  final double projectFund;
  final double totalInvestmentAmount;
  final double totalReceivedAmount;
  final double totalPendingAmount;
  final int totalInvestors;
  final double fundingProgress;

  DashboardModel({
    required this.projectFund,
    required this.totalInvestmentAmount,
    required this.totalReceivedAmount,
    required this.totalPendingAmount,
    required this.totalInvestors,
    required this.fundingProgress,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      projectFund: _readDouble(
        json['projectFund'] ?? json['ProjectFund'],
      ),
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ??
            json['TotalInvestmentAmount'],
      ),
      totalReceivedAmount: _readDouble(
        json['totalReceivedAmount'] ??
            json['TotalReceivedAmount'],
      ),
      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ??
            json['TotalPendingAmount'],
      ),
      totalInvestors: _readInt(
        json['totalInvestors'] ??
            json['TotalInvestors'],
      ),
      fundingProgress: _readDouble(
        json['fundingProgress'] ??
            json['FundingProgress'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectFund': projectFund,
      'totalInvestmentAmount': totalInvestmentAmount,
      'totalReceivedAmount': totalReceivedAmount,
      'totalPendingAmount': totalPendingAmount,
      'totalInvestors': totalInvestors,
      'fundingProgress': fundingProgress,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}