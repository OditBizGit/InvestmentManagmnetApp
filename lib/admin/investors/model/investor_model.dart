import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class InvestorModel {
  final int userId;
  final String username;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? alternativeNumber;
  final String? profileImage;
  final String? investorCode;
  final String? investorType;
  final String? organization;
  final String? address;

  // Personal / KYC
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final DateTime? dateOfBirth;

  // Investment
  final double investmentAmount;
  final DateTime? investmentDate;
  final int investmentSplitMonths;
  final String? investmentSplitType;
  final int investmentSplitGap;
  final double investmentAdvanceAmount;
  final String? paymentMethod;

  // Status
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;

  // Payment summary
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final double latestPaymentAmount;
  final DateTime? nextDueDate;
  final double nextDueAmount;
  final String? status;

  // Nominee
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String? nomineeAadhaarNumber;
  final String? nomineePanCardNumber;
  final String? nomineePhoneNumber;
  final String? nomineeProfilePhoto;

  InvestorModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.alternativeNumber,
    this.profileImage,
    this.investorCode,
    this.investorType,
    this.organization,
    this.address,

    // Personal / KYC
    this.aadhaarNumber,
    this.panCardNumber,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.dateOfBirth,

    // Investment
    this.investmentAmount = 0,
    this.investmentDate,
    this.investmentSplitMonths = 0,
    this.investmentSplitType,
    this.investmentSplitGap = 0,
    this.investmentAdvanceAmount = 0,
    this.paymentMethod,

    // Status
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,

    // Payment summary
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
    this.totalPendingAmount = 0,
    this.latestPaymentAmount = 0,
    this.nextDueDate,
    this.nextDueAmount = 0,
    this.status,

    // Nominee
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineeAddress,
    this.nomineeDateOfBirth,
    this.nomineeAadhaarNumber,
    this.nomineePanCardNumber,
    this.nomineePhoneNumber,
    this.nomineeProfilePhoto,
  });

  /// Absolute URL for [profileImage].
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  /// Absolute URL for [nomineeProfilePhoto].
  String? get nomineeProfilePhotoUrl =>
      resolveMediaUrl(nomineeProfilePhoto);

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    return InvestorModel(
      userId: _readInt(
        json['userId'] ?? json['UserId'],
      ),

      username: (
          json['userName'] ??
              json['username'] ??
              json['UserName'] ??
              json['Username'] ??
              ''
      ).toString(),

      fullName: (
          json['fullName'] ??
              json['FullName'] ??
              ''
      ).toString(),

      email: _readString(
        json['email'] ?? json['Email'],
      ),

      phoneNumber: _readString(
        json['phoneNumber'] ?? json['PhoneNumber'],
      ),

      alternativeNumber: _readString(
        json['alternativeNumber'] ?? json['AlternativeNumber'],
      ),

      profileImage: _readProfileImage(json),

      investorCode: _readString(
        json['investorCode'] ?? json['InvestorCode'],
      ),

      investorType: _readString(
        json['investorType'] ?? json['InvestorType'],
      ),

      organization: _readString(
        json['organization'] ?? json['Organization'],
      ),

      address: _readString(
        json['address'] ?? json['Address'],
      ),

      // Personal / KYC
      aadhaarNumber: _readString(
        json['aadhaarNumber'] ?? json['AadhaarNumber'],
      ),

      panCardNumber: _readString(
        json['panCardNumber'] ?? json['PanCardNumber'],
      ),

      accountNumber: _readString(
        json['accountNumber'] ?? json['AccountNumber'],
      ),

      ifscCode: _readString(
        json['ifscCode'] ?? json['IfscCode'],
      ),

      bankName: _readString(
        json['bankName'] ?? json['BankName'],
      ),

      dateOfBirth: _readDate(
        json['dateOfBirth'] ?? json['DateOfBirth'],
      ),

      // Investment
      investmentAmount: _readDouble(
        json['investmentAmount'] ?? json['InvestmentAmount'],
      ),

      investmentDate: _readDate(
        json['investmentDate'] ?? json['InvestmentDate'],
      ),

      investmentSplitMonths: _readInt(
        json['investmentSplitMonths'] ??
            json['InvestmentSplitMonths'],
      ),

      investmentSplitType: _readString(
        json['investmentSplitType'] ??
            json['InvestmentSplitType'],
      ),

      investmentSplitGap: _readInt(
        json['investmentSplitGap'] ??
            json['InvestmentSplitGap'],
      ),

      investmentAdvanceAmount: _readDouble(
        json['investmentAdvanceAmount'] ??
            json['InvestmentAdvanceAmount'],
      ),

      paymentMethod: _readString(
        json['paymentMethod'] ?? json['PaymentMethod'],
      ),

      // Status
      isActive: _readBool(
        json['isActive'] ?? json['IsActive'],
      ),

      createdDate: _readDate(
        json['createdDate'] ?? json['CreatedDate'],
      ),

      modifiedDate: _readDate(
        json['modifiedDate'] ?? json['ModifiedDate'],
      ),

      userRole: (
          json['userRole'] ??
              json['UserRole'] ??
              ''
      ).toString(),

      // Payment summary
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ??
            json['TotalInvestmentAmount'],
      ),

      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ??
            json['TotalPaidAmount'],
      ),

      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ??
            json['TotalPendingAmount'],
      ),

      latestPaymentAmount: _readDouble(
        json['latestPaymentAmount'] ??
            json['LatestPaymentAmount'],
      ),

      nextDueDate: _readDate(
        json['nextDueDate'] ?? json['NextDueDate'],
      ),

      nextDueAmount: _readDouble(
        json['nextDueAmount'] ?? json['NextDueAmount'],
      ),

      status: _readString(
        json['status'] ?? json['Status'],
      ),

      // Nominee
      nomineeName: _readString(
        json['nomineeName'] ?? json['NomineeName'],
      ),

      nomineeRelationship: _readString(
        json['nomineeRelationship'] ??
            json['NomineeRelationship'],
      ),

      nomineeAddress: _readString(
        json['nomineeAddress'] ?? json['NomineeAddress'],
      ),

      nomineeDateOfBirth: _readDate(
        json['nomineeDateOfBirth'] ??
            json['NomineeDateOfBirth'],
      ),

      nomineeAadhaarNumber: _readString(
        json['nomineeAadhaarNumber'] ??
            json['NomineeAadhaarNumber'],
      ),

      nomineePanCardNumber: _readString(
        json['nomineePanCardNumber'] ??
            json['NomineePanCardNumber'],
      ),

      nomineePhoneNumber: _readString(
        json['nomineePhoneNumber'] ??
            json['NomineePhoneNumber'],
      ),

      nomineeProfilePhoto: _readString(
        json['nomineeProfilePhoto'] ??
            json['NomineeProfilePhoto'],
      ),
    );
  }

  static String? _readProfileImage(
      Map<String, dynamic> json,
      ) {
    final value =
        json['profileImage'] ??
            json['ProfileImage'] ??
            json['profile_image'] ??
            json['imageUrl'] ??
            json['ImageUrl'] ??
            json['image'];

    return _readString(value);
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();

      return normalized == 'true' ||
          normalized == '1';
    }

    return false;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }
}