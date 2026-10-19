enum UserPaymentStatus { pending, partiallyPaid, fullyPaid }

enum ManageUsersStatusFilter { all, active, blocked }

enum DuePaymentsStatusFilter { all, pending, partiallyPaid, fullyPaid }

enum DocumentProcessStatus { pending, inProgress, completed }

extension DocumentProcessStatusX on DocumentProcessStatus {
  String get label {
    switch (this) {
      case DocumentProcessStatus.pending:
        return 'Pending';
      case DocumentProcessStatus.inProgress:
        return 'In Progress';
      case DocumentProcessStatus.completed:
        return 'Completed';
    }
  }
}

class ManagedUserModel {
  const ManagedUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.totalPayable,
    required this.amountPaid,
    required this.isBlocked,
    this.joinedDate,
    this.lastPaymentDate,
    this.nextDueDate,
    this.mouStatus = DocumentProcessStatus.pending,
    this.llpStatus = DocumentProcessStatus.pending,
    this.depositDiscountAmount = 0,
    this.medicalAllowanceAmount = 0,
    this.medicalAllowanceNote = '',
  });

  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final double totalPayable;
  final double amountPaid;
  final bool isBlocked;
  final DateTime? joinedDate;
  final DateTime? lastPaymentDate;
  final DateTime? nextDueDate;
  final DocumentProcessStatus mouStatus;
  final DocumentProcessStatus llpStatus;
  final double depositDiscountAmount;
  final double medicalAllowanceAmount;
  final String medicalAllowanceNote;

  double get outstandingBalance {
    final remaining = totalPayable - amountPaid;
    return remaining < 0 ? 0 : remaining;
  }

  bool get hasPendingDues => outstandingBalance > 0.01;

  UserPaymentStatus get paymentStatus {
    if (outstandingBalance <= 0.01) return UserPaymentStatus.fullyPaid;
    if (amountPaid > 0) return UserPaymentStatus.partiallyPaid;
    return UserPaymentStatus.pending;
  }

  String get accountStatusLabel => isBlocked ? 'Blocked' : 'Active';

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case UserPaymentStatus.pending:
        return 'Pending';
      case UserPaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case UserPaymentStatus.fullyPaid:
        return 'Fully Paid';
    }
  }

  ManagedUserModel copyWith({
    bool? isBlocked,
    DocumentProcessStatus? mouStatus,
    DocumentProcessStatus? llpStatus,
  }) {
    return ManagedUserModel(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      totalPayable: totalPayable,
      amountPaid: amountPaid,
      isBlocked: isBlocked ?? this.isBlocked,
      joinedDate: joinedDate,
      lastPaymentDate: lastPaymentDate,
      nextDueDate: nextDueDate,
      mouStatus: mouStatus ?? this.mouStatus,
      llpStatus: llpStatus ?? this.llpStatus,
      depositDiscountAmount: depositDiscountAmount,
      medicalAllowanceAmount: medicalAllowanceAmount,
      medicalAllowanceNote: medicalAllowanceNote,
    );
  }
}
