class StaffReportRowModel {
  const StaffReportRowModel({
    required this.staffId,
    required this.code,
    required this.name,
    required this.mobileNumber,
    required this.totalAmount,
  });

  final int staffId;
  final String code;
  final String name;
  final String mobileNumber;
  final double totalAmount;
}
