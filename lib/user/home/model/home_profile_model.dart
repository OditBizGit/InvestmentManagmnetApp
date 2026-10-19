class HomeProfileModel {
  const HomeProfileModel({
    required this.displayName,
    this.investorCode,
    this.profileImageUrl,
    this.totalCollection = 0,
    this.totalCommitment = 0,
    this.discountAmount = 0,
  });

  final String displayName;
  final String? investorCode;
  final String? profileImageUrl;

  /// Maps to API `totalPaidAmount`.
  final double totalCollection;

  /// Maps to API `investmentAmount`.
  final double totalCommitment;

  /// Maps to API `discountAmount`.
  final double discountAmount;
}
