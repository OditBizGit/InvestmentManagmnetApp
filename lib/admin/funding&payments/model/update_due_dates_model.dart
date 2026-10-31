class UpdateDueDatesRequestModel {
  final int investorId;
  final int installmentNumber;
  final DateTime dueDate;

  UpdateDueDatesRequestModel({
    required this.investorId,
    required this.installmentNumber,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'investorId': investorId,
      'installmentNumber': installmentNumber,
      'dueDate': UpdateDueDatesRequestModel.toApiIsoString(dueDate),
    };
  }

  /// Calendar date at UTC midnight — avoids timezone shifting the day (e.g. IST).
  static DateTime normalizeCalendarDate(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
  }

  static String toApiIsoString(DateTime value) {
    final calendar = normalizeCalendarDate(value);
    return calendar.toIso8601String();
  }
}

class UpdateDueDatesResponseModel {
  final bool status;
  final String message;
  final dynamic data;
  final int code;

  UpdateDueDatesResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory UpdateDueDatesResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return UpdateDueDatesResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'],
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}