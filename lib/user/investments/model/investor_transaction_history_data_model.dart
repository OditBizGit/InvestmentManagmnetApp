import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';

class InvestorTransactionHistoryDataModel {
  final int userId;
  final String investorCode;
  final String fullName;
  final String? profileImage;
  final int projectId;
  final String projectName;
  final String projectDescription;
  final String? projectImage;
  final double totalInvestmentAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final DateTime? nextDueDate;
  final double nextDueAmount;
  final List<InvestorTransactionItemModel> transactions;

  const InvestorTransactionHistoryDataModel({
    required this.userId,
    required this.investorCode,
    required this.fullName,
    this.profileImage,
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    this.projectImage,
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
    this.totalPendingAmount = 0,
    this.nextDueDate,
    this.nextDueAmount = 0,
    this.transactions = const [],
  });

  String? get profileImageUrl => resolveMediaUrl(profileImage);

  String? get projectImageUrl => resolveMediaUrl(projectImage);

  factory InvestorTransactionHistoryDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestorTransactionHistoryDataModel(
      userId: _readInt(json['userId'] ?? json['UserId']),
      investorCode:
          (json['investorCode'] ?? json['InvestorCode'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      projectId: _readInt(json['projectId'] ?? json['ProjectId']),
      projectName: (json['projectName'] ?? json['ProjectName'] ?? '').toString(),
      projectDescription:
          (json['projectDescription'] ?? json['ProjectDescription'] ?? '')
              .toString(),
      projectImage: _readString(json['projectImage'] ?? json['ProjectImage']),
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
      totalPendingAmount: _readDouble(
        json['totalPendingAmount'] ?? json['TotalPendingAmount'],
      ),
      nextDueDate: _readDate(json['nextDueDate'] ?? json['NextDueDate']),
      nextDueAmount: _readDouble(
        json['nextDueAmount'] ?? json['NextDueAmount'],
      ),
      transactions: _readTransactions(
        json['transactions'] ?? json['Transactions'],
      ),
    );
  }

  static List<InvestorTransactionItemModel> _readTransactions(dynamic value) {
    if (value is! List) return const [];
    final parsed = <InvestorTransactionItemModel>[];
    for (final item in value) {
      if (item is Map) {
        try {
          parsed.add(
            InvestorTransactionItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Skip malformed rows so one bad entry does not crash the screen.
        }
      }
    }
    return parsed;
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
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
