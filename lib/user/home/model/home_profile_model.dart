class HomeProfileModel {
  const HomeProfileModel({
    required this.displayName,
    this.investorCode,
    this.profileImageUrl,
  });

  final String displayName;
  final String? investorCode;
  final String? profileImageUrl;
}
