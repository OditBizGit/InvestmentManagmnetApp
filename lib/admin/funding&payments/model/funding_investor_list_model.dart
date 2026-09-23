import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class FundingInvestorsResponseModel {
  final bool status;
  final String message;
  final List<FundingInvestorModel> investors;
  final int code;

  const FundingInvestorsResponseModel({
    required this.status,
    required this.message,
    required this.investors,
    this.code = 0,
  });

  factory FundingInvestorsResponseModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const FundingInvestorsResponseModel(
        status: false,
        message: 'Unexpected response format',
        investors: [],
      );
    }

    final map = Map<String, dynamic>.from(json);
    final rawData = map['data'] ?? map['Data'];

    List<dynamic> list = const [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final dataMap = Map<String, dynamic>.from(rawData);
      final nestedList = dataMap['investors'] ??
          dataMap['Investors'] ??
          dataMap['items'] ??
          dataMap['Items'] ??
          dataMap['list'] ??
          dataMap['List'];
      if (nestedList is List) {
        list = nestedList;
      }
    }

    final parsed = <FundingInvestorModel>[];
    for (final item in list) {
      if (item is Map) {
        try {
          parsed.add(
            FundingInvestorModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Skip malformed rows so one bad entry does not crash the screen.
        }
      }
    }

    return FundingInvestorsResponseModel(
      status: _readStatus(map['status'] ?? map['Status']),
      message: (map['message'] ?? map['Message'] ?? '').toString(),
      investors: parsed,
      code: _readInt(map['code'] ?? map['Code']),
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

class FundingInvestorModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? investorCode;
  final String? investorType;
  final String? organization;
  final String? address;
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String userRole;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final double latestPaymentAmount;
  final String status;

  const FundingInvestorModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.investorCode,
    this.investorType,
    this.organization,
    this.address,
    required this.isActive,
    this.createdDate,
    this.modifiedDate,
    required this.userRole,
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
    this.totalPendingAmount = 0,
    this.latestPaymentAmount = 0,
    this.status = '',
  });

  /// Absolute URL for [profileImage] (handles relative API paths).
  String? get profileImageUrl => resolveMediaUrl(profileImage);

  FundingInvestorModel copyWith({
    int? userId,
    String? username,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? investorCode,
    String? investorType,
    String? organization,
    String? address,
    bool? isActive,
    DateTime? createdDate,
    DateTime? modifiedDate,
    String? userRole,
    double? totalInvestmentAmount,
    double? totalPaidAmount,
    double? totalPendingAmount,
    double? latestPaymentAmount,
    String? status,
  }) {
    return FundingInvestorModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      investorCode: investorCode ?? this.investorCode,
      investorType: investorType ?? this.investorType,
      organization: organization ?? this.organization,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      userRole: userRole ?? this.userRole,
      totalInvestmentAmount:
          totalInvestmentAmount ?? this.totalInvestmentAmount,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      totalPendingAmount: totalPendingAmount ?? this.totalPendingAmount,
      latestPaymentAmount: latestPaymentAmount ?? this.latestPaymentAmount,
      status: status ?? this.status,
    );
  }

  factory FundingInvestorModel.fromJson(Map<String, dynamic> json) {
    return FundingInvestorModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phoneNumber: _readString(json['phoneNumber'] ?? json['PhoneNumber']),
      profileImage: _readProfileImage(json),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      investorType: _readString(json['investorType'] ?? json['InvestorType']),
      organization: _readString(json['organization'] ?? json['Organization']),
      address: _readString(json['address'] ?? json['Address']),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      createdDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      modifiedDate: _readDate(json['modifiedDate'] ?? json['ModifiedDate']),
      userRole: (json['userRole'] ?? json['UserRole'] ?? '').toString(),
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ?? json['TotalPendingAmount'],
      ),
      latestPaymentAmount: _readDouble(
        json['latestPaymentAmount'] ?? json['LatestPaymentAmount'],
      ),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'investorCode': investorCode,
      'investorType': investorType,
      'organization': organization,
      'address': address,
      'isActive': isActive,
      'createdDate': createdDate?.toIso8601String(),
      'modifiedDate': modifiedDate?.toIso8601String(),
      'userRole': userRole,
      'totalInvestmentAmount': totalInvestmentAmount,
      'totalPaidAmount': totalPaidAmount,
      'totalPendingAmount': totalPendingAmount,
      'latestPaymentAmount': latestPaymentAmount,
      'status': status,
    };
  }

  static String? _readProfileImage(Map<String, dynamic> json) {
    final value = json['profileImage'] ??
        json['ProfileImage'] ??
        json['profile_image'] ??
        json['imageUrl'] ??
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
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
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
