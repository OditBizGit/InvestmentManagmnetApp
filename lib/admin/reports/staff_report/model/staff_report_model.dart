class StaffReportResponseModel {
  final bool success;
  final String message;
  final List<StaffReportModel> data;

  StaffReportResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StaffReportResponseModel.fromJson(Map<String, dynamic> json) {
    return StaffReportResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StaffReportModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class StaffReportModel {
  final int staffId;
  final String staffCode;
  final String staffName;
  final String mobileNumber;
  final double totalAmount;

  StaffReportModel({
    required this.staffId,
    required this.staffCode,
    required this.staffName,
    required this.mobileNumber,
    required this.totalAmount,
  });

  factory StaffReportModel.fromJson(Map<String, dynamic> json) {
    return StaffReportModel(
      staffId: json['staffId'] ?? 0,
      staffCode: json['staffCode'] ?? '',
      staffName: json['staffName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}