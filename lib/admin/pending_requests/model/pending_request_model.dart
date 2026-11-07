import 'package:maribel_wellness_centre_application/admin/pending_requests/model/payment_request_model.dart';

enum PendingRequestStatus { pending, approved, rejected }

enum PendingRequestsListFilter {
  all,
  pending,
  approved,
  rejected,
  terminatedInvestor,
}

extension PendingRequestsListFilterX on PendingRequestsListFilter {
  String get label => switch (this) {
        PendingRequestsListFilter.all => 'All',
        PendingRequestsListFilter.pending => 'Pending',
        PendingRequestsListFilter.approved => 'Approved',
        PendingRequestsListFilter.rejected => 'Rejected',
        PendingRequestsListFilter.terminatedInvestor => 'Terminated Investor',
      };

  bool get usesPaymentRequestApi =>
      this != PendingRequestsListFilter.terminatedInvestor;

  String get apiStatus => label;
}

class PendingRequestNominee {
  const PendingRequestNominee({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.aadhaarNumber,
    this.panNumber,
    this.aadhaarPhotoUrl,
    this.panPhotoUrl,
  });

  final String name;
  final String relationship;
  final String phoneNumber;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? aadhaarPhotoUrl;
  final String? panPhotoUrl;
}

class PendingRequestModel {
  const PendingRequestModel({
    required this.id,
    required this.userId,
    required this.requestId,
    required this.applicantName,
    required this.email,
    required this.phoneNumber,
    required this.allocation,
    required this.paymentMethod,
    required this.amount,
    required this.amountPayingNow,
    required this.submittedAt,
    required this.status,
    this.dateOfBirth,
    this.address,
    this.organization,
    this.alternatePhone,
    this.aadhaarNumber,
    this.aadhaarPhotoUrl,
    this.panNumber,
    this.panPhotoUrl,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.nominees = const [],
  });

  final String id;
  final int userId;
  final String requestId;
  final String applicantName;
  final String email;
  final String phoneNumber;
  final String allocation;
  final String paymentMethod;
  final double amount;
  final double amountPayingNow;
  final DateTime submittedAt;
  final PendingRequestStatus status;
  final DateTime? dateOfBirth;
  final String? address;
  final String? organization;
  final String? alternatePhone;
  final String? aadhaarNumber;
  final String? aadhaarPhotoUrl;
  final String? panNumber;
  final String? panPhotoUrl;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final List<PendingRequestNominee> nominees;

  factory PendingRequestModel.fromPaymentRequest(
    PaymentRequestDataModel data,
  ) {
    final paymentMethod = data.paymentMethod.trim();
    final allocation = data.narration.trim().isNotEmpty
        ? data.narration.trim()
        : paymentMethod.isNotEmpty
            ? paymentMethod
            : 'Payment request';

    return PendingRequestModel(
      id: data.requestId.toString(),
      userId: data.userId,
      requestId: data.investorCode.trim().isNotEmpty
          ? data.investorCode.trim()
          : 'REQ-${data.requestId}',
      applicantName: data.fullName.trim().isNotEmpty
          ? data.fullName.trim()
          : 'Unknown',
      email: data.email,
      phoneNumber: data.phoneNumber,
      allocation: allocation,
      paymentMethod: paymentMethod,
      amount: data.paidAmount,
      amountPayingNow: data.paidAmount,
      submittedAt: data.requestedDate ?? DateTime.now(),
      status: PendingRequestStatusX.fromApi(data.status),
    );
  }

  double get pendingAmount {
    final remaining = amount - amountPayingNow;
    return remaining < 0 ? 0 : remaining;
  }

  String get initials {
    final parts = applicantName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isApproved => status == PendingRequestStatus.approved;

  bool get isRejected => status == PendingRequestStatus.rejected;

  bool get isAwaitingReview => status == PendingRequestStatus.pending;

  bool get isClosed =>
      status == PendingRequestStatus.approved ||
      status == PendingRequestStatus.rejected;

  String get statusLabel => switch (status) {
        PendingRequestStatus.pending => 'Pending',
        PendingRequestStatus.approved => 'Approved',
        PendingRequestStatus.rejected => 'Rejected',
      };

  PendingRequestModel copyWith({PendingRequestStatus? status}) {
    return PendingRequestModel(
      id: id,
      userId: userId,
      requestId: requestId,
      applicantName: applicantName,
      email: email,
      phoneNumber: phoneNumber,
      allocation: allocation,
      paymentMethod: paymentMethod,
      amount: amount,
      amountPayingNow: amountPayingNow,
      submittedAt: submittedAt,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth,
      address: address,
      organization: organization,
      alternatePhone: alternatePhone,
      aadhaarNumber: aadhaarNumber,
      aadhaarPhotoUrl: aadhaarPhotoUrl,
      panNumber: panNumber,
      panPhotoUrl: panPhotoUrl,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      nominees: nominees,
    );
  }
}

extension PendingRequestStatusX on PendingRequestStatus {
  static PendingRequestStatus fromApi(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'approved':
        return PendingRequestStatus.approved;
      case 'rejected':
        return PendingRequestStatus.rejected;
      case 'pending':
      default:
        return PendingRequestStatus.pending;
    }
  }
}

class PendingRequestsOverviewStats {
  const PendingRequestsOverviewStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int approved;
  final int rejected;

  int get awaitingReview => pending;

  static const empty = PendingRequestsOverviewStats(
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
  );

  static PendingRequestsOverviewStats from(
    List<PendingRequestModel> requests,
  ) {
    var pending = 0;
    var approved = 0;
    var rejected = 0;

    for (final request in requests) {
      switch (request.status) {
        case PendingRequestStatus.pending:
          pending++;
        case PendingRequestStatus.approved:
          approved++;
        case PendingRequestStatus.rejected:
          rejected++;
      }
    }

    return PendingRequestsOverviewStats(
      total: requests.length,
      pending: pending,
      approved: approved,
      rejected: rejected,
    );
  }
}
