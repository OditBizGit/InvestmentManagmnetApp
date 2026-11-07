class PaymentRequestModel {
  // Request parameter
  final String status;

  PaymentRequestModel({this.status = 'All'});

  // Request query parameters
  Map<String, dynamic> toQueryParameters() {
    return {'status': status};
  }
}

class PaymentRequestResponseModel {
  final bool status;
  final String message;
  final List<PaymentRequestDataModel> data;
  final int? code;

  PaymentRequestResponseModel({
    required this.status,
    required this.message,
    required this.data,
    this.code,
  });

  factory PaymentRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is List
          ? (json['data'] as List)
                .map(
                  (item) => PaymentRequestDataModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],
      code: json['code'],
    );
  }
}

class PaymentRequestDataModel {
  final int requestId;
  final int userId;
  final String investorCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final double paidAmount;
  final String narration;
  final String paymentMethod;
  final bool isFullSettlement;
  final double discountAmount;
  final String remarks;
  final double? medicalAllowance;
  final String status;
  final DateTime? requestedDate;
  final int requestedBy;
  final String requestedByName;
  final int? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedDate;
  final String? reviewRemarks;
  final int? paymentEntryNo;

  PaymentRequestDataModel({
    required this.requestId,
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.paidAmount,
    required this.narration,
    required this.paymentMethod,
    required this.isFullSettlement,
    required this.discountAmount,
    required this.remarks,
    this.medicalAllowance,
    required this.status,
    this.requestedDate,
    required this.requestedBy,
    required this.requestedByName,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedDate,
    this.reviewRemarks,
    this.paymentEntryNo,
  });

  factory PaymentRequestDataModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestDataModel(
      requestId: json['requestId'] ?? 0,
      userId: json['userId'] ?? 0,
      investorCode: json['investorCode'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      narration: json['narration'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      isFullSettlement: json['isFullSettlement'] ?? false,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      remarks: json['remarks'] ?? '',

      medicalAllowance: double.tryParse(
        json['medicalAllowance']?.toString() ?? '0',
      ) ?? 0.0,

      status: json['status'] ?? '',
      requestedDate: json['requestedDate'] != null
          ? DateTime.tryParse(json['requestedDate'].toString())
          : null,
      requestedBy: json['requestedBy'] ?? 0,
      requestedByName: json['requestedByName'] ?? '',
      reviewedBy: json['reviewedBy'],
      reviewedByName: json['reviewedByName'],
      reviewedDate: json['reviewedDate'] != null
          ? DateTime.tryParse(json['reviewedDate'].toString())
          : null,
      reviewRemarks: json['reviewRemarks'],
      paymentEntryNo: json['paymentEntryNo'],
    );
  }
}
