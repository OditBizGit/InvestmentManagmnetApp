class ManageUsersTotals {
  const ManageUsersTotals({
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
  });

  final double totalInvestmentAmount;
  final double totalPaidAmount;

  factory ManageUsersTotals.fromJson(Map<String, dynamic> json) {
    return ManageUsersTotals(
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
    );
  }
}

class ManageUsersResponse {
  const ManageUsersResponse({
    required this.status,
    required this.message,
    required this.users,
    required this.total,
    required this.code,
    required this.skippedCount,
  });

  final bool status;
  final String message;
  final List<ManageUsersInvestor> users;
  final ManageUsersTotals total;
  final int code;
  final int skippedCount;

  factory ManageUsersResponse.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('Manage users response was not an object');
    }

    final map = Map<String, dynamic>.from(json);
    final rawData = map['data'] ?? map['Data'];
    final rootTotal = map['total'] ?? map['Total'];

    var list = const <dynamic>[];
    Map<String, dynamic>? nestedTotal;

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final dataMap = Map<String, dynamic>.from(rawData);
      final nestedList = dataMap['investors'] ??
          dataMap['Investors'] ??
          dataMap['items'] ??
          dataMap['Items'] ??
          dataMap['list'] ??
          dataMap['List'] ??
          dataMap['data'] ??
          dataMap['Data'];
      if (nestedList is List) {
        list = nestedList;
      }
      final totalInData = dataMap['total'] ?? dataMap['Total'];
      if (totalInData is Map) {
        nestedTotal = Map<String, dynamic>.from(totalInData);
      }
    }

    final users = <ManageUsersInvestor>[];
    var skippedCount = 0;
    for (final item in list) {
      if (item is Map) {
        users.add(
          ManageUsersInvestor.fromJson(Map<String, dynamic>.from(item)),
        );
      } else {
        skippedCount++;
      }
    }

    if (list.isNotEmpty && users.isEmpty) {
      throw const FormatException('Manage users response list was invalid');
    }

    final totalJson = rootTotal is Map
        ? Map<String, dynamic>.from(rootTotal)
        : nestedTotal;

    return ManageUsersResponse(
      status: _readStatus(map['status'] ?? map['Status']),
      message: (map['message'] ?? map['Message'] ?? '').toString().trim(),
      users: users,
      total: totalJson == null
          ? const ManageUsersTotals()
          : ManageUsersTotals.fromJson(totalJson),
      code: _readInt(map['code'] ?? map['Code']),
      skippedCount: skippedCount,
    );
  }
}

class ManageUsersInvestor {
  const ManageUsersInvestor({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.totalPayable,
    required this.amountPaid,
    required this.totalPendingAmount,
    required this.isActive,
    this.joinedDate,
    this.depositDiscountAmount = 0,
    this.medicalAllowanceDescription = '',
  });

  final int id;
  final String username;
  final String name;
  final String email;
  final String phoneNumber;
  final double totalPayable;
  final double amountPaid;
  final double totalPendingAmount;
  final bool isActive;
  final DateTime? joinedDate;
  final double depositDiscountAmount;
  final String medicalAllowanceDescription;

  String get userId => id > 0 ? '$id' : '';

  bool get isBlocked => !isActive;

  String get accountStatusLabel => isBlocked ? 'Blocked' : 'Active';

  double get outstandingBalance {
    final computed = totalPayable - amountPaid;
    final remaining =
        computed > totalPendingAmount ? computed : totalPendingAmount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get hasPendingDues => outstandingBalance > 0.01;

  ManageUsersInvestor copyWith({
    bool? isActive,
    double? amountPaid,
    double? totalPendingAmount,
  }) {
    return ManageUsersInvestor(
      id: id,
      username: username,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      totalPayable: totalPayable,
      amountPaid: amountPaid ?? this.amountPaid,
      totalPendingAmount: totalPendingAmount ?? this.totalPendingAmount,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate,
      depositDiscountAmount: depositDiscountAmount,
      medicalAllowanceDescription: medicalAllowanceDescription,
    );
  }

  factory ManageUsersInvestor.fromJson(Map<String, dynamic> json) {
    final username = _readString(
          json['userName'] ??
              json['username'] ??
              json['UserName'] ??
              json['Username'],
        ) ??
        '';
    final fullName = _readString(json['fullName'] ?? json['FullName']);
    final totalInvestment = _readDouble(
      json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
    );
    final investmentAmount = _readDouble(
      json['investmentAmount'] ?? json['InvestmentAmount'],
    );

    return ManageUsersInvestor(
      id: _readInt(json['userId'] ?? json['UserId']),
      username: username,
      name: (fullName == null || fullName.isEmpty) ? username : fullName,
      email: _readString(json['email'] ?? json['Email']) ?? '',
      phoneNumber:
          _readString(json['phoneNumber'] ?? json['PhoneNumber']) ?? '',
      totalPayable: totalInvestment > 0 ? totalInvestment : investmentAmount,
      amountPaid: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ?? json['TotalPendingAmount'],
      ),
      isActive: _readBool(json['isActive'] ?? json['IsActive']),
      joinedDate: _readDate(json['createdDate'] ?? json['CreatedDate']),
      depositDiscountAmount: _readDouble(
        json['discountAmount'] ??
            json['DiscountAmount'] ??
            json['depositDiscountAmount'] ??
            json['DepositDiscountAmount'] ??
            json['totalDiscountAmount'] ??
            json['TotalDiscountAmount'],
      ),
      medicalAllowanceDescription: _readString(
            json['medicalAllowanceDescription'] ??
                json['MedicalAllowanceDescription'] ??
                json['medicalAllowanceNote'] ??
                json['MedicalAllowanceNote'] ??
                json['medicalAllowance'] ??
                json['MedicalAllowance'],
          ) ??
          '',
    );
  }
}

bool _readStatus(dynamic value) {
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

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}
