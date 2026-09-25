import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

class UserComplaintModel {
  final int complaintId;
  final int investorId;
  final String investorCode;
  final String investorName;
  final String profileImage;
  final String complaint;
  final String complaintDate;
  final String status;

  UserComplaintModel({
    required this.complaintId,
    required this.investorId,
    required this.investorCode,
    required this.investorName,
    required this.profileImage,
    required this.complaint,
    required this.complaintDate,
    required this.status,
  });

  String get id => 'CMP-$complaintId';

  String get username =>
      investorName.trim().isEmpty ? 'Unknown investor' : investorName.trim();

  String get userId =>
      investorCode.trim().isEmpty ? 'ID: $investorId' : investorCode.trim();

  String get message => complaint;

  /// API: `"Viewed"` = already read, `"Pending"` = show Mark as Read.
  bool get isRead {
    final normalized = status.trim().toLowerCase();
    return normalized == 'viewed' || normalized == 'read';
  }

  bool get isPending {
    final normalized = status.trim().toLowerCase();
    return normalized == 'pending' || normalized.isEmpty;
  }

  String? get profileImageUrl => resolveMediaUrl(profileImage);

  DateTime get createdAt {
    final raw = complaintDate.trim();
    if (raw.isEmpty) return DateTime.now();

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;

    // Fallback for formats like dd-MM-yyyy / dd/MM/yyyy
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.now();
  }

  UserComplaintModel copyWith({
    int? complaintId,
    int? investorId,
    String? investorCode,
    String? investorName,
    String? profileImage,
    String? complaint,
    String? complaintDate,
    String? status,
  }) {
    return UserComplaintModel(
      complaintId: complaintId ?? this.complaintId,
      investorId: investorId ?? this.investorId,
      investorCode: investorCode ?? this.investorCode,
      investorName: investorName ?? this.investorName,
      profileImage: profileImage ?? this.profileImage,
      complaint: complaint ?? this.complaint,
      complaintDate: complaintDate ?? this.complaintDate,
      status: status ?? this.status,
    );
  }

  factory UserComplaintModel.fromJson(Map<String, dynamic> json) {
    return UserComplaintModel(
      complaintId: _readInt(json['complaintId'] ?? json['ComplaintId']),
      investorId: _readInt(json['investorId'] ?? json['InvestorId']),
      investorCode: _readString(json['investorCode'] ?? json['InvestorCode']),
      investorName: _readString(json['investorName'] ?? json['InvestorName']),
      profileImage: _readString(json['profileImage'] ?? json['ProfileImage']),
      complaint: _readString(json['complaint'] ?? json['Complaint']),
      complaintDate: _readString(json['complaintDate'] ?? json['ComplaintDate']),
      status: _readString(json['status'] ?? json['Status']),
    );
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
