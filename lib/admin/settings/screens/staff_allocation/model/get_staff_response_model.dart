class GetStaffResponseModel {
  final bool success;
  final String message;
  final List<StaffModel> data;

  const GetStaffResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetStaffResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return GetStaffResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (item) => StaffModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList() ??
          [],
    );
  }
}

class StaffModel {
  final int staffId;
  final String fullName;
  final String designation;
  final String email;
  final String phoneNumber;
  final bool isActive;
  final DateTime? createdDate;

  const StaffModel({
    required this.staffId,
    required this.fullName,
    required this.designation,
    required this.email,
    required this.phoneNumber,
    required this.isActive,
    this.createdDate,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      staffId: (json['staffId'] as num?)?.toInt() ?? 0,
      fullName: json['fullName'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(
              json['createdDate'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'fullName': fullName,
      'designation': designation,
      'email': email,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}