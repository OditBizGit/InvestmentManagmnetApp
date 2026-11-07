
class StaffReportDetailsResponseModel {
  final bool success;
  final String message;
  final List<StaffReportDetailsModel> data;

  StaffReportDetailsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StaffReportDetailsResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffReportDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => StaffReportDetailsModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList() ??
          [],
    );
  }
}

class StaffReportDetailsModel {
  final String transactionType;
  final int userId;
  final String investorCode;
  final String investorName;
  final double investmentAmount;
  final double allocationPercentage;
  final DateTime? paymentDate;
  final double paymentAmount;
  final double staffAllocatedAmount;
  final double refundAmount;
  final double netAmount;

  StaffReportDetailsModel({
    required this.transactionType,
    required this.userId,
    required this.investorCode,
    required this.investorName,
    required this.investmentAmount,
    required this.allocationPercentage,
    required this.paymentDate,
    required this.paymentAmount,
    required this.staffAllocatedAmount,
    required this.refundAmount,
    required this.netAmount,
  });

  factory StaffReportDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffReportDetailsModel(
      transactionType: json['transactionType'] ?? '',
      userId: json['userId'] ?? 0,
      investorCode: json['investorCode'] ?? '',
      investorName: json['investorName'] ?? '',
      investmentAmount: (json['investmentAmount'] ?? 0).toDouble(),
      allocationPercentage: (json['allocationPercentage'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'].toString())
          : null,
      paymentAmount: (json['paymentAmount'] ?? 0).toDouble(),
      staffAllocatedAmount: (json['staffAllocatedAmount'] ?? 0).toDouble(),
      refundAmount: (json['refundAmount'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
    );
  }
}
