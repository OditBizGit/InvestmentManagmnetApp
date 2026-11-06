class InvestorStaffAllocationModel {
  const InvestorStaffAllocationModel({
    required this.staffId,
    this.staffName,
    this.allocationPercentage = 0,
    this.allocatedAmount = 0,
  });

  final int staffId;
  final String? staffName;
  final double allocationPercentage;
  final double allocatedAmount;

  factory InvestorStaffAllocationModel.fromJson(Map<String, dynamic> json) {
    return InvestorStaffAllocationModel(
      staffId: _readInt(json['staffId'] ?? json['StaffId']),
      staffName: _readString(json['staffName'] ?? json['StaffName']),
      allocationPercentage: _readDouble(
        json['allocationPercentage'] ?? json['AllocationPercentage'],
      ),
      allocatedAmount: _readDouble(
        json['allocatedAmount'] ?? json['AllocatedAmount'],
      ),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }
}

List<InvestorStaffAllocationModel> parseInvestorStaffAllocations(
  Map<String, dynamic> json,
) {
  final raw = json['staffAllocations'] ?? json['StaffAllocations'];
  if (raw is! List) return const [];

  return raw
      .whereType<Map>()
      .map(
        (item) => InvestorStaffAllocationModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((allocation) => allocation.staffId > 0)
      .toList();
}
