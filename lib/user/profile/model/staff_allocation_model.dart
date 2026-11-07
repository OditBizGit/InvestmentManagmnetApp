import 'package:maribel_wellness_centre_application/core/utils/string_extensions.dart';

class StaffAllocationModel {
  const StaffAllocationModel({
    this.staffId,
    this.staffName,
    this.staffPhoneNumber,
    this.allocationPercentage = 0,
    this.allocatedAmount = 0,
  });

  final int? staffId;
  final String? staffName;
  final String? staffPhoneNumber;
  final double allocationPercentage;
  final double allocatedAmount;

  factory StaffAllocationModel.fromJson(Map<String, dynamic> json) {
    return StaffAllocationModel(
      staffId: _readNullableInt(json['staffId'] ?? json['StaffId']),
      staffName: _readName(json['staffName'] ?? json['StaffName']),
      staffPhoneNumber: _readString(
        json['staffPhoneNumber'] ?? json['StaffPhoneNumber'],
      ),
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

  static String? _readName(dynamic value) {
    final text = _readString(value);
    return text?.toTitleCase;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }
    return null;
  }

  static double _readDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return 0;
      return double.tryParse(text) ?? 0;
    }
    return 0;
  }
}
