class GetInvestorsByStaffResponseModel {
  final bool success;
  final String message;
  final List<StaffInvestorModel> data;

  const GetInvestorsByStaffResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetInvestorsByStaffResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return GetInvestorsByStaffResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (item) => StaffInvestorModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList() ??
          [],
    );
  }
}

class StaffInvestorModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final DateTime? createdDate;

  const StaffInvestorModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    this.createdDate,
  });

  factory StaffInvestorModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffInvestorModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      investorCode: json['investorCode']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profileImage: json['profileImage'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(
        json['createdDate'].toString(),
      )
          : null,
    );
  }
}