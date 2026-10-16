class StaffListResponseModel {
  StaffListResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  final bool status;
  final String message;
  final List<InvestorStaffModel> data;
  final int code;

  factory StaffListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final list = rawData is List ? rawData : const <dynamic>[];

    return StaffListResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: list
          .whereType<Map>()
          .map(
            (item) => InvestorStaffModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((staff) => staff.staffId > 0 && staff.fullName.isNotEmpty)
          .toList(),
      code: _readInt(json['code'] ?? json['Code']),
    );
  }

  static bool _readStatus(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'success' ||
          normalized == '1';
    }
    return false;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class InvestorStaffModel {
  InvestorStaffModel({
    required this.staffId,
    required this.fullName,
    this.designation,
    this.phoneNumber,
  });

  final int staffId;
  final String fullName;
  final String? designation;
  final String? phoneNumber;

  String get dropdownLabel {
    final role = designation?.trim();
    if (role != null && role.isNotEmpty) {
      return '$fullName · $role';
    }
    return fullName;
  }

  factory InvestorStaffModel.fromJson(Map<String, dynamic> json) {
    return InvestorStaffModel(
      staffId: _readInt(
        json['staffId'] ??
            json['StaffId'] ??
            json['userId'] ??
            json['UserId'] ??
            json['id'] ??
            json['Id'],
      ),
      fullName: (
        json['fullName'] ??
            json['FullName'] ??
            json['staffName'] ??
            json['StaffName'] ??
            json['name'] ??
            json['Name'] ??
            ''
      ).toString().trim(),
      designation: _readOptionalString(
        json['designation'] ?? json['Designation'],
      ),
      phoneNumber: _readOptionalString(
        json['phoneNumber'] ?? json['PhoneNumber'],
      ),
    );
  }

  static String? _readOptionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
