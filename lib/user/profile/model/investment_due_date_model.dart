class InvestmentPaymentModel {
  final double amount;
  final String? paymentMethod;

  const InvestmentPaymentModel({
    this.amount = 0,
    this.paymentMethod,
  });

  factory InvestmentPaymentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentPaymentModel(
      amount: _readDouble(json['amount'] ?? json['Amount']),
      paymentMethod: _readString(
        json['paymentMethod'] ?? json['PaymentMethod'],
      ),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class InvestmentDueDateModel {
  final int installmentNumber;
  final DateTime? dueDate;
  final double installmentAmount;
  final double paidAmount;
  final double pendingAmount;
  final String? status;
  final List<InvestmentPaymentModel> payments;

  const InvestmentDueDateModel({
    required this.installmentNumber,
    this.dueDate,
    this.installmentAmount = 0,
    this.paidAmount = 0,
    this.pendingAmount = 0,
    this.status,
    this.payments = const [],
  });

  bool get isFullyPaid {
    final normalized = (status ?? '').trim().toLowerCase();
    if (normalized == 'completed' || normalized == 'paid') return true;
    return pendingAmount <= 0 && paidAmount > 0;
  }

  bool get isPartiallyPaid {
    final normalized = (status ?? '').trim().toLowerCase();
    return normalized.contains('partial');
  }

  factory InvestmentDueDateModel.fromJson(Map<String, dynamic> json) {
    return InvestmentDueDateModel(
      installmentNumber: _readInt(
        json['installmentNumber'] ?? json['InstallmentNumber'],
      ),
      dueDate: _readDate(json['dueDate'] ?? json['DueDate']),
      installmentAmount: _readDouble(
        json['installmentAmount'] ?? json['InstallmentAmount'],
      ),
      paidAmount: _readDouble(json['paidAmount'] ?? json['PaidAmount']),
      pendingAmount: _readDouble(
        json['pendingAmount'] ?? json['PendingAmount'],
      ),
      status: _readString(json['status'] ?? json['Status']),
      payments: _readPayments(json['payments'] ?? json['Payments']),
    );
  }

  static List<InvestmentPaymentModel> _readPayments(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => InvestmentPaymentModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
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

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
