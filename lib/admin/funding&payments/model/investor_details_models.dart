import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

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

class InvestorNomineeModel {
  final int nomineeId;
  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String nomineeAadhaarNumber;
  final String nomineePanCardNumber;
  final String nomineePhoneNumber;
  final String nomineeProfilePhoto;
  final String nomineeAadhaarPhoto;
  final String nomineePanCardPhoto;

  InvestorNomineeModel({
    required this.nomineeId,
    required this.nomineeName,
    required this.nomineeRelationship,
    required this.nomineeAddress,
    this.nomineeDateOfBirth,
    required this.nomineeAadhaarNumber,
    required this.nomineePanCardNumber,
    required this.nomineePhoneNumber,
    required this.nomineeProfilePhoto,
    required this.nomineeAadhaarPhoto,
    required this.nomineePanCardPhoto,
  });

  String? get nomineeProfilePhotoUrl => resolveMediaUrl(nomineeProfilePhoto);
  String? get nomineeAadhaarPhotoUrl => resolveMediaUrl(nomineeAadhaarPhoto);
  String? get nomineePanCardPhotoUrl => resolveMediaUrl(nomineePanCardPhoto);

  factory InvestorNomineeModel.fromJson(Map<String, dynamic> json) {
    return InvestorNomineeModel(
      nomineeId: _readInt(json['nomineeId']),
      nomineeName: _readString(json['nomineeName']),
      nomineeRelationship: _readString(json['nomineeRelationship']),
      nomineeAddress: _readString(json['nomineeAddress']),
      nomineeDateOfBirth: _parseDate(json['nomineeDateOfBirth']),
      nomineeAadhaarNumber: _readString(json['nomineeAadhaarNumber']),
      nomineePanCardNumber: _readString(json['nomineePanCardNumber']),
      nomineePhoneNumber: _readString(json['nomineePhoneNumber']),
      nomineeProfilePhoto: _readString(json['nomineeProfilePhoto']),
      nomineeAadhaarPhoto: _readString(
        json['nomineeAadhaarPhoto'] ?? json['nomineeAadhaarCardImage'],
      ),
      nomineePanCardPhoto: _readString(
        json['nomineePanCardPhoto'] ?? json['nomineePanCardImage'],
      ),
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
  final String aadhaarPhoto;
  final String panCardPhoto;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final DateTime? dateOfBirth;
  final String description;

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

  /// Legacy flat nominee fields (first nominee / older API shape).
  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String nomineeAadhaarNumber;
  final String nomineePanCardNumber;
  final String nomineePhoneNumber;
  final String nomineeProfilePhoto;

  final List<InvestorNomineeModel> nominees;
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
    required this.aadhaarPhoto,
    required this.panCardPhoto,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.dateOfBirth,
    required this.description,
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
    required this.nominees,
    required this.dueDates,
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
  });

  String? get profileImageUrl => resolveMediaUrl(profileImage);
  String? get aadhaarPhotoUrl => resolveMediaUrl(aadhaarPhoto);
  String? get panCardPhotoUrl => resolveMediaUrl(panCardPhoto);

  factory InvestorDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final nominees = _parseNominees(json);
    final firstNominee = nominees.isNotEmpty ? nominees.first : null;

    return InvestorDetailsModel(
      userId: _readInt(json['userId']),
      username: _readString(json['username']),
      fullName: _readString(json['fullName']),
      email: _readString(json['email']),
      phoneNumber: _readString(json['phoneNumber']),
      alternativeNumber: _readString(json['alternativeNumber']),
      profileImage: _readString(json['profileImage']),
      investorCode: _readString(json['investorCode']),
      investorType: _readString(json['investorType']),
      organization: _readString(json['organization']),
      address: _readString(json['address']),
      aadhaarNumber: _readString(json['aadhaarNumber']),
      panCardNumber: _readString(json['panCardNumber']),
      aadhaarPhoto: _readString(
        json['aadhaarPhoto'] ?? json['aadhaarCardImage'],
      ),
      panCardPhoto: _readString(
        json['panCardPhoto'] ?? json['panCardImage'],
      ),
      accountNumber: _readString(json['accountNumber']),
      ifscCode: _readString(json['ifscCode']),
      bankName: _readString(json['bankName']),
      dateOfBirth: _parseDate(json['dateOfBirth']),
      description: _readString(json['description']),
      investmentAmount: _readDouble(json['investmentAmount']),
      investmentDate: _parseDate(json['investmentDate']),
      investmentAdvanceAmount: _readDouble(json['investmentAdvanceAmount']),
      investmentSplitMonths: _readInt(json['investmentSplitMonths']),
      investmentSplitGap: _readInt(json['investmentSplitGap']),
      investmentSplitType: _readString(json['investmentSplitType']),
      totalPaidAmount: _readDouble(json['totalPaidAmount']),
      totalPendingAmount: _readDouble(json['totalPendingAmount']),
      lastPaymentAmount: _readDouble(json['lastPaymentAmount']),
      lastPaymentDate: _parseDate(json['lastPaymentDate']),
      nomineeName: firstNominee?.nomineeName ??
          _readString(json['nomineeName']),
      nomineeRelationship: firstNominee?.nomineeRelationship ??
          _readString(json['nomineeRelationship']),
      nomineeAddress: firstNominee?.nomineeAddress ??
          _readString(json['nomineeAddress']),
      nomineeDateOfBirth: firstNominee?.nomineeDateOfBirth ??
          _parseDate(json['nomineeDateOfBirth']),
      nomineeAadhaarNumber: firstNominee?.nomineeAadhaarNumber ??
          _readString(json['nomineeAadhaarNumber']),
      nomineePanCardNumber: firstNominee?.nomineePanCardNumber ??
          _readString(json['nomineePanCardNumber']),
      nomineePhoneNumber: firstNominee?.nomineePhoneNumber ??
          _readString(json['nomineePhoneNumber']),
      nomineeProfilePhoto: firstNominee?.nomineeProfilePhoto ??
          _readString(json['nomineeProfilePhoto']),
      nominees: nominees,
      dueDates: (json['dueDates'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => InvestorDueDateModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      isActive: json['isActive'] == true,
      createdDate: _parseDate(json['createdDate']),
      modifiedDate: _parseDate(json['modifiedDate']),
      userRole: _readString(json['userRole']),
    );
  }

  static List<InvestorNomineeModel> _parseNominees(Map<String, dynamic> json) {
    final raw = json['nominees'] ?? json['Nominees'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => InvestorNomineeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    // Older API shape: flat nominee fields on the investor object.
    final name = _readString(json['nomineeName']);
    if (name.isEmpty) return const [];

    return [
      InvestorNomineeModel(
        nomineeId: 0,
        nomineeName: name,
        nomineeRelationship: _readString(json['nomineeRelationship']),
        nomineeAddress: _readString(json['nomineeAddress']),
        nomineeDateOfBirth: _parseDate(json['nomineeDateOfBirth']),
        nomineeAadhaarNumber: _readString(json['nomineeAadhaarNumber']),
        nomineePanCardNumber: _readString(json['nomineePanCardNumber']),
        nomineePhoneNumber: _readString(json['nomineePhoneNumber']),
        nomineeProfilePhoto: _readString(json['nomineeProfilePhoto']),
        nomineeAadhaarPhoto: _readString(
          json['nomineeAadhaarPhoto'] ?? json['nomineeAadhaarCardImage'],
        ),
        nomineePanCardPhoto: _readString(
          json['nomineePanCardPhoto'] ?? json['nomineePanCardImage'],
        ),
      ),
    ];
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
      installmentNumber: _readInt(json['installmentNumber']),
      dueDate: _parseDate(json['dueDate']),
      installmentAmount: _readDouble(json['installmentAmount']),
      paidAmount: _readDouble(json['paidAmount']),
      pendingAmount: _readDouble(json['pendingAmount']),
      status: _readString(json['status']),
      payments: (json['payments'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => InvestorPaymentHistoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
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
      amount: _readDouble(json['amount']),
      paymentMethod: _readString(json['paymentMethod']),
    );
  }
}

String _readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

int _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
