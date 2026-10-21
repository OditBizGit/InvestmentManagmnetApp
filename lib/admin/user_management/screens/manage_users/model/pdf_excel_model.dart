class PdfExcelRequestModel {
  final DateTime fromDate;
  final DateTime toDate;
  final String section;

  PdfExcelRequestModel({
    required this.fromDate,
    required this.toDate,
    required this.section,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate.toUtc().toIso8601String(),
      'toDate': toDate.toUtc().toIso8601String(),
      'section': section,
    };
  }
}

class PdfExcelResponseModel {
  final bool status;
  final String message;
  final List<PdfExcelInvestorModel> data;
  final int code;

  PdfExcelResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory PdfExcelResponseModel.fromJson(Map<String, dynamic> json) {
    return PdfExcelResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => PdfExcelInvestorModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      code: json['code'] ?? 0,
    );
  }

  List<PdfExcelInvestorModel> rowsForSection(String section) {
    if (section.toLowerCase() == 'due') {
      return data;
    }
    return data.expand((investor) => investor.exportRows).toList();
  }
}

class PdfExcelPaymentDetailModel {
  const PdfExcelPaymentDetailModel({
    required this.transactionId,
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.investmentAmount,
    required this.paidAmount,
    required this.receivedAmount,
    required this.pendingAmount,
  });

  final int transactionId;
  final int userId;
  final String investorCode;
  final String fullName;
  final double investmentAmount;
  final double paidAmount;
  final double receivedAmount;
  final double pendingAmount;

  factory PdfExcelPaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PdfExcelPaymentDetailModel(
      transactionId: PdfExcelInvestorModel.readInt(
        json['transactionId'] ?? json['TransactionId'],
      ),
      userId: PdfExcelInvestorModel.readInt(
        json['userId'] ?? json['UserId'],
      ),
      investorCode: PdfExcelInvestorModel.readString(
        json['investorCode'] ?? json['InvestorCode'],
      ),
      fullName: PdfExcelInvestorModel.readString(
        json['fullName'] ?? json['FullName'],
      ),
      investmentAmount: PdfExcelInvestorModel.readDouble(
        json['investmentAmount'] ?? json['InvestmentAmount'],
      ),
      paidAmount: PdfExcelInvestorModel.readDouble(
        json['paidAmount'] ?? json['PaidAmount'],
      ),
      receivedAmount: PdfExcelInvestorModel.readDouble(
        json['receivedAmount'] ?? json['ReceivedAmount'],
      ),
      pendingAmount: PdfExcelInvestorModel.readDouble(
        json['pendingAmount'] ?? json['PendingAmount'],
      ),
    );
  }

  PdfExcelInvestorModel toExportRow(PdfExcelInvestorModel parent) {
    final paid = paidAmount > 0 ? paidAmount : receivedAmount;
    return PdfExcelInvestorModel(
      userId: userId != 0 ? userId : parent.userId,
      investorCode:
          investorCode.isNotEmpty ? investorCode : parent.investorCode,
      fullName: fullName.isNotEmpty ? fullName : parent.fullName,
      dueAmount: investmentAmount > 0 ? investmentAmount : parent.dueAmount,
      paidAmount: paid,
      pendingAmount: pendingAmount > 0 ? pendingAmount : parent.pendingAmount,
    );
  }
}

class PdfExcelInvestorModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final double dueAmount;
  final double paidAmount;
  final double pendingAmount;
  final List<PdfExcelPaymentDetailModel> paymentDetails;

  PdfExcelInvestorModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    required this.dueAmount,
    required this.paidAmount,
    required this.pendingAmount,
    this.paymentDetails = const [],
  });

  List<PdfExcelInvestorModel> get exportRows {
    if (paymentDetails.isEmpty) {
      return [this];
    }
    return paymentDetails
        .map((detail) => detail.toExportRow(this))
        .toList();
  }

  factory PdfExcelInvestorModel.fromJson(Map<String, dynamic> json) {
    final paymentDetails = _parsePaymentDetails(json['paymentDetails']);

    final dueAmount = _readDueAmount(json);
    final paidAmount = _readPaidAmount(json);
    var pendingAmount = _readPendingAmount(json);

    if (pendingAmount <= 0 &&
        (dueAmount > 0 || paidAmount > 0) &&
        dueAmount >= paidAmount) {
      final computed = dueAmount - paidAmount;
      if (computed > 0.01) {
        pendingAmount = computed;
      }
    }

    return PdfExcelInvestorModel(
      userId: readInt(json['userId'] ?? json['UserId']),
      investorCode: readString(
        json['investorCode'] ?? json['InvestorCode'],
      ),
      fullName: readString(
        json['fullName'] ??
            json['FullName'] ??
            json['name'] ??
            json['Name'],
      ),
      dueAmount: dueAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      paymentDetails: paymentDetails,
    );
  }

  static List<PdfExcelPaymentDetailModel> _parsePaymentDetails(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map(
          (item) => PdfExcelPaymentDetailModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static double _readDueAmount(Map<String, dynamic> json) {
    return readFirstExisting(json, const [
      'totalInvestmentAmount',
      'TotalInvestmentAmount',
      'dueAmount',
      'DueAmount',
      'totalPayable',
      'TotalPayable',
      'investmentAmount',
      'InvestmentAmount',
      'committedAmount',
      'CommittedAmount',
      'installmentAmount',
      'InstallmentAmount',
    ]);
  }

  static double _readPaidAmount(Map<String, dynamic> json) {
    return readFirstExisting(json, const [
      'totalPaidTillDate',
      'TotalPaidTillDate',
      'amountPaidDuringPeriod',
      'AmountPaidDuringPeriod',
      'paidAmount',
      'PaidAmount',
      'amountPaid',
      'AmountPaid',
      'totalPaidAmount',
      'TotalPaidAmount',
      'receivedAmount',
      'ReceivedAmount',
    ]);
  }

  static double _readPendingAmount(Map<String, dynamic> json) {
    return readFirstExisting(json, const [
      'pendingAmountAsOfToDate',
      'PendingAmountAsOfToDate',
      'pendingAmount',
      'PendingAmount',
      'outstanding',
      'Outstanding',
      'totalPendingAmount',
      'TotalPendingAmount',
    ]);
  }

  static double readFirstExisting(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return readDouble(json[key]);
      }
    }
    return 0;
  }

  static int readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double readDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value
          .trim()
          .replaceAll('₹', '')
          .replaceAll('Rs.', '')
          .replaceAll('Rs', '')
          .replaceAll(',', '')
          .trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static String readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
