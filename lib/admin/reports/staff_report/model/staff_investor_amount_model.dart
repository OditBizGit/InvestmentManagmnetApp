class StaffInvestorAmountModel {
  const StaffInvestorAmountModel({
    required this.investorCode,
    required this.investorName,
    required this.amountReceived,
    this.amountReceivedDate,
  });

  final String investorCode;
  final String investorName;
  final double amountReceived;
  final DateTime? amountReceivedDate;
}
