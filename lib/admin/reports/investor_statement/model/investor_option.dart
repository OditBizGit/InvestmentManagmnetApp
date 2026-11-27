import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';

/// Investor entry of the statement picker.
class InvestorOption {
  const InvestorOption({
    required this.userId,
    required this.investorCode,
    required this.name,
  });

  factory InvestorOption.fromInvestor(InvestorModel investor) {
    return InvestorOption(
      userId: investor.userId,
      investorCode: investor.investorCode?.trim() ?? '',
      name: investor.fullName.trim(),
    );
  }

  final int userId;
  final String investorCode;
  final String name;

  String get label => investorCode.isEmpty ? name : '$investorCode - $name';

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return investorCode.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      other is InvestorOption && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}
