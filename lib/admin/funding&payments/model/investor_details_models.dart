class InvestorDetailsResponseModel {
  final bool status;
  final String message;
  final InvestorDetailsModel? data;
  final int code;

  InvestorDetailsResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory InvestorDetailsResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawData = json['data'] ?? json['Data'];
    return InvestorDetailsResponseModel(
      status: json['status'] == true || json['Status'] == true,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: rawData is Map
          ? InvestorDetailsModel.fromJson(
              Map<String, dynamic>.from(rawData),
            )
          : null,
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code'] ?? json['Code'] ?? 0}') ?? 0,
    );
  }
}

class InvestorDetailsModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String alternativeNumber;
  final String profileImage;
  final String investorCode;
  final String investorType;
  final String organization;
  final String address;
  final String aadhaarNumber;
  final String panCardNumber;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final DateTime? dateOfBirth;

  final double investmentAmount;
  final DateTime? investmentDate;
  final double investmentAdvanceAmount;
  final int investmentSplitMonths;
  final int investmentSplitGap;
  final String investmentSplitType;

  final double totalPaidAmount;
  final double totalPendingAmount;
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;

  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String nomineeAadhaarNumber;
  final String nomineePanCardNumber;
  final String nomineePhoneNumber;
  final String nomineeProfilePhoto;

  final List<InvestorDueDateModel> dueDates;

  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;

  InvestorDetailsModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.alternativeNumber,
    required this.profileImage,
    required this.investorCode,
    required this.investorType,
    required this.organization,
    required this.address,
    required this.aadhaarNumber,
    required this.panCardNumber,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.dateOfBirth,
    required this.investmentAmount,
    this.investmentDate,
    required this.investmentAdvanceAmount,
    required this.investmentSplitMonths,
    required this.investmentSplitGap,
    required this.investmentSplitType,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.lastPaymentAmount,
    this.lastPaymentDate,
    required this.nomineeName,
    required this.nomineeRelationship,
    required this.nomineeAddress,
    this.nomineeDateOfBirth,
    required this.nomineeAadhaarNumber,
    required this.nomineePanCardNumber,
    required this.nomineePhoneNumber,
    required this.nomineeProfilePhoto,
    required this.dueDates,
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  factory InvestorDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorDetailsModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      alternativeNumber: json['alternativeNumber'] ?? '',
      profileImage: json['profileImage'] ?? '',
      investorCode: json['investorCode'] ?? '',
      investorType: json['investorType'] ?? '',
      organization: json['organization'] ?? '',
      address: json['address'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      panCardNumber: json['panCardNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',

      dateOfBirth: _parseDate(json['dateOfBirth']),

      investmentAmount:
      (json['investmentAmount'] ?? 0).toDouble(),

      investmentDate:
      _parseDate(json['investmentDate']),

      investmentAdvanceAmount:
      (json['investmentAdvanceAmount'] ?? 0).toDouble(),

      investmentSplitMonths:
      json['investmentSplitMonths'] ?? 0,

      investmentSplitGap:
      json['investmentSplitGap'] ?? 0,

      investmentSplitType:
      json['investmentSplitType'] ?? '',

      totalPaidAmount:
      (json['totalPaidAmount'] ?? 0).toDouble(),

      totalPendingAmount:
      (json['totalPendingAmount'] ?? 0).toDouble(),

      lastPaymentAmount:
      (json['lastPaymentAmount'] ?? 0).toDouble(),

      lastPaymentDate:
      _parseDate(json['lastPaymentDate']),

      nomineeName:
      json['nomineeName'] ?? '',

      nomineeRelationship:
      json['nomineeRelationship'] ?? '',

      nomineeAddress:
      json['nomineeAddress'] ?? '',

      nomineeDateOfBirth:
      _parseDate(json['nomineeDateOfBirth']),

      nomineeAadhaarNumber:
      json['nomineeAadhaarNumber'] ?? '',

      nomineePanCardNumber:
      json['nomineePanCardNumber'] ?? '',

      nomineePhoneNumber:
      json['nomineePhoneNumber'] ?? '',

      nomineeProfilePhoto:
      json['nomineeProfilePhoto'] ?? '',

      dueDates: (json['dueDates'] as List<dynamic>? ?? [])
          .map(
            (item) => InvestorDueDateModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),

      isActive:
      json['isActive'] ?? false,

      createdDate:
      _parseDate(json['createdDate']),

      modifiedDate:
      _parseDate(json['modifiedDate']),

      userRole:
      json['userRole'] ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class InvestorDueDateModel {
  final int installmentNumber;
  final DateTime? dueDate;
  final double installmentAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;
  final List<InvestorPaymentHistoryModel> payments;

  InvestorDueDateModel({
    required this.installmentNumber,
    this.dueDate,
    required this.installmentAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
    required this.payments,
  });

  factory InvestorDueDateModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorDueDateModel(
      installmentNumber:
      json['installmentNumber'] ?? 0,

      dueDate: _parseDate(json['dueDate']),

      installmentAmount:
      (json['installmentAmount'] ?? 0).toDouble(),

      paidAmount:
      (json['paidAmount'] ?? 0).toDouble(),

      pendingAmount:
      (json['pendingAmount'] ?? 0).toDouble(),

      status:
      json['status'] ?? '',

      payments: (json['payments'] as List<dynamic>? ?? [])
          .map(
            (item) => InvestorPaymentHistoryModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class InvestorPaymentHistoryModel {
  final double amount;
  final String paymentMethod;

  InvestorPaymentHistoryModel({
    required this.amount,
    required this.paymentMethod,
  });

  factory InvestorPaymentHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return InvestorPaymentHistoryModel(
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
    );
  }
}