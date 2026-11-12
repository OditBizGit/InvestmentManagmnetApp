class StaffInvestorAmountModel {
  const StaffInvestorAmountModel({
    required this.investorCode,
    required this.investorName,
    required this.amountReceived,
    required this.refundAmount,
    this.amountReceivedDate,
  });

  final String investorCode;
  final String investorName;
  final double amountReceived;
  final double refundAmount;
  final DateTime? amountReceivedDate;
}
