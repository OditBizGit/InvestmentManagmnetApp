enum PendingRequestStatus { requested, pending, completed, rejected }

enum PendingRequestsListFilter { pending, completed }

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
    required this.requestId,
    required this.applicantName,
    required this.email,
    required this.phoneNumber,
    required this.allocation,
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
  final String requestId;
  final String applicantName;
  final String email;
  final String phoneNumber;
  final String allocation;
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

  bool get isCompleted => status == PendingRequestStatus.completed;

  bool get isRejected => status == PendingRequestStatus.rejected;

  bool get isAwaitingReview =>
      status == PendingRequestStatus.requested ||
      status == PendingRequestStatus.pending;

  bool get isClosed =>
      status == PendingRequestStatus.completed ||
      status == PendingRequestStatus.rejected;

  String get statusLabel => switch (status) {
        PendingRequestStatus.requested => 'Requested',
        PendingRequestStatus.pending => 'Pending',
        PendingRequestStatus.completed => 'Completed',
        PendingRequestStatus.rejected => 'Rejected',
      };

  PendingRequestModel copyWith({PendingRequestStatus? status}) {
    return PendingRequestModel(
      id: id,
      requestId: requestId,
      applicantName: applicantName,
      email: email,
      phoneNumber: phoneNumber,
      allocation: allocation,
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

class PendingRequestsOverviewStats {
  const PendingRequestsOverviewStats({
    required this.total,
    required this.requested,
    required this.pending,
    required this.completed,
  });

  final int total;
  final int requested;
  final int pending;
  final int completed;

  int get awaitingReview => requested + pending;

  static const empty = PendingRequestsOverviewStats(
    total: 0,
    requested: 0,
    pending: 0,
    completed: 0,
  );

  static PendingRequestsOverviewStats from(
    List<PendingRequestModel> requests,
  ) {
    var requested = 0;
    var pending = 0;
    var completed = 0;

    for (final request in requests) {
      switch (request.status) {
        case PendingRequestStatus.requested:
          requested++;
        case PendingRequestStatus.pending:
          pending++;
        case PendingRequestStatus.completed:
          completed++;
        case PendingRequestStatus.rejected:
          completed++;
      }
    }

    return PendingRequestsOverviewStats(
      total: requests.length,
      requested: requested,
      pending: pending,
      completed: completed,
    );
  }
}
