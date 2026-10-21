class InvestorRatingRecord {
  const InvestorRatingRecord({
    required this.fullName,
    required this.investorCode,
    required this.committedAmount,
    required this.paidOnTime,
    required this.paidLate,
    required this.overdue,
    required this.upcoming,
    this.adminRating,
  }) : assert(paidOnTime >= 0),
       assert(paidLate >= 0),
       assert(overdue >= 0),
       assert(upcoming >= 0),
       assert(committedAmount >= 0),
       assert(adminRating == null || (adminRating >= 1 && adminRating <= 5));

  final String fullName;
  final String investorCode;
  final double committedAmount;

  /// Instalments paid by the due date.
  final int paidOnTime;

  /// Instalments paid after the due date.
  final int paidLate;

  /// Instalments past due and still unpaid.
  final int overdue;

  /// Instalments not yet due.
  final int upcoming;

  /// Admin rating from 1 to 5. Null when not rated yet.
  final int? adminRating;

  /// Instalments that have reached their due date.
  int get totalInstalmentsDue => paidOnTime + paidLate + overdue;

  int get delayedPayments => paidLate;

  int get currentlyOverdue => overdue;

  int get totalPlanInstalments => totalInstalmentsDue + upcoming;

  /// On-time share of due instalments. Null when nothing is due yet.
  double? get onTimePercentage {
    if (totalInstalmentsDue == 0) return null;
    return (paidOnTime / totalInstalmentsDue) * 100;
  }

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get ratingLabel {
    return switch (adminRating) {
      5 => 'Excellent',
      4 => 'Good',
      3 => 'Fair',
      2 => 'Weak',
      1 => 'Poor',
      _ => 'Not rated',
    };
  }

  InvestorRatingRecord copyWith({
    String? fullName,
    String? investorCode,
    double? committedAmount,
    int? paidOnTime,
    int? paidLate,
    int? overdue,
    int? upcoming,
    int? adminRating,
    bool clearAdminRating = false,
  }) {
    return InvestorRatingRecord(
      fullName: fullName ?? this.fullName,
      investorCode: investorCode ?? this.investorCode,
      committedAmount: committedAmount ?? this.committedAmount,
      paidOnTime: paidOnTime ?? this.paidOnTime,
      paidLate: paidLate ?? this.paidLate,
      overdue: overdue ?? this.overdue,
      upcoming: upcoming ?? this.upcoming,
      adminRating:
          clearAdminRating ? null : (adminRating ?? this.adminRating),
    );
  }
}
