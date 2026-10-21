
class AdminsResponseModel {
  final bool status;
  final String message;
  final List<AdminModel> data;
  final int code;

  AdminsResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory AdminsResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => AdminModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String alternativeNumber;
  final String investorCode;
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;

  AdminModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.alternativeNumber,
    required this.investorCode,
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      alternativeNumber:
      json['alternativeNumber']?.toString() ?? '',
      investorCode: json['investorCode']?.toString() ?? '',
      isActive: json['isActive'] == true,
      createdDate: DateTime.tryParse(
        json['createdDate']?.toString() ?? '',
      ),
      modifiedDate: json['modifiedDate'] == null
          ? null
          : DateTime.tryParse(
        json['modifiedDate'].toString(),
      ),
      userRole: json['userRole']?.toString() ?? '',
    );
  }
}
