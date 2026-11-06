/// Investor–staff allocation split for register/update investor APIs.
class InvestorStaffAssignmentSlot {
  const InvestorStaffAssignmentSlot({
    required this.staffId,
    this.staffName,
    required this.percentage,
  });

  final int staffId;
  final String? staffName;
  final double percentage;

  Map<String, String> toJson() => {
        'staffId': staffId.toString(),
        if (staffName != null && staffName!.trim().isNotEmpty)
          'staffName': staffName!.trim(),
        'percentage': percentage.toString(),
      };
}

class InvestorStaffAssignmentPayload {
  const InvestorStaffAssignmentPayload({required this.slots});

  final List<InvestorStaffAssignmentSlot> slots;

  int get staffId => slots.isEmpty ? 0 : slots.first.staffId;

  int get staffId2 => slots.length > 1 ? slots[1].staffId : 0;

  double get staffAllocationPercentage =>
      slots.isEmpty ? 0 : slots.first.percentage;

  double get staff2AllocationPercentage =>
      slots.length > 1 ? slots[1].percentage : 0;

  /// Builds the allocation from form selections.
  factory InvestorStaffAssignmentPayload.fromSelections({
    required int primaryStaffId,
    String? primaryStaffName,
    required double primaryPercentage,
    int? secondaryStaffId,
    String? secondaryStaffName,
    double? secondaryPercentage,
  }) {
    final slots = <InvestorStaffAssignmentSlot>[
      InvestorStaffAssignmentSlot(
        staffId: primaryStaffId,
        staffName: primaryStaffName,
        percentage: primaryPercentage,
      ),
    ];

    if (secondaryStaffId != null &&
        secondaryStaffId > 0 &&
        secondaryPercentage != null &&
        secondaryPercentage > 0) {
      slots.add(
        InvestorStaffAssignmentSlot(
          staffId: secondaryStaffId,
          staffName: secondaryStaffName,
          percentage: secondaryPercentage,
        ),
      );
    }

    return InvestorStaffAssignmentPayload(slots: slots);
  }

  List<MapEntry<String, String>> toFormFields() {
    if (slots.isEmpty) return const [];

    final hasSecondStaff = slots.length > 1;
    return [
      MapEntry('StaffId', staffId.toString()),
      MapEntry('StaffId2', hasSecondStaff ? staffId2.toString() : ''),
      MapEntry('StaffAllocationPercentage', staffAllocationPercentage.toString()),
      MapEntry(
        'Staff2AllocationPercentage',
        hasSecondStaff ? staff2AllocationPercentage.toString() : '',
      ),
    ];
  }

  List<Map<String, dynamic>> toJsonList() =>
      slots.map((slot) => slot.toJson()).toList();
}
