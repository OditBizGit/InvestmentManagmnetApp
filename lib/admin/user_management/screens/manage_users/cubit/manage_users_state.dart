part of 'manage_users_cubit.dart';

sealed class ManageUsersState {
  const ManageUsersState();
}

final class ManageUsersInitial extends ManageUsersState {
  const ManageUsersInitial();
}

final class ManageUsersLoading extends ManageUsersState {
  const ManageUsersLoading();
}

final class ManageUsersEmpty extends ManageUsersState {
  const ManageUsersEmpty({this.isTableLoading = false});

  final bool isTableLoading;

  ManageUsersEmpty copyWith({bool? isTableLoading}) {
    return ManageUsersEmpty(
      isTableLoading: isTableLoading ?? this.isTableLoading,
    );
  }
}

class ManageUsersStatusFeedback {
  const ManageUsersStatusFeedback({
    required this.isSuccess,
    required this.message,
    this.title,
  });

  final bool isSuccess;
  final String message;
  final String? title;
}

final class ManageUsersSuccess extends ManageUsersState {
  const ManageUsersSuccess({
    required this.users,
    this.mouStatus = const {},
    this.llpStatus = const {},
    this.statusUpdatingUserId,
    this.refundUpdatingUserId,
    this.statusFeedback,
    this.isTableLoading = false,
  });

  final List<ManageUsersInvestor> users;
  final Map<int, DocumentProcessStatus> mouStatus;
  final Map<int, DocumentProcessStatus> llpStatus;
  final int? statusUpdatingUserId;
  final int? refundUpdatingUserId;
  final ManageUsersStatusFeedback? statusFeedback;
  final bool isTableLoading;

  int get totalUsers => users.length;

  int get activeUsers => users.where((user) => !user.isBlocked).length;

  int get blockedUsers => users.where((user) => user.isBlocked).length;

  int get usersWithPendingDues =>
      users.where((user) => user.hasPendingDues).length;

  ManageUsersSuccess copyWith({
    List<ManageUsersInvestor>? users,
    Map<int, DocumentProcessStatus>? mouStatus,
    Map<int, DocumentProcessStatus>? llpStatus,
    int? statusUpdatingUserId,
    bool clearStatusUpdatingUserId = false,
    int? refundUpdatingUserId,
    bool clearRefundUpdatingUserId = false,
    ManageUsersStatusFeedback? statusFeedback,
    bool clearStatusFeedback = false,
    bool? isTableLoading,
  }) {
    return ManageUsersSuccess(
      users: users ?? this.users,
      mouStatus: mouStatus ?? this.mouStatus,
      llpStatus: llpStatus ?? this.llpStatus,
      statusUpdatingUserId: clearStatusUpdatingUserId
          ? null
          : statusUpdatingUserId ?? this.statusUpdatingUserId,
      refundUpdatingUserId: clearRefundUpdatingUserId
          ? null
          : refundUpdatingUserId ?? this.refundUpdatingUserId,
      statusFeedback: clearStatusFeedback
          ? null
          : statusFeedback ?? this.statusFeedback,
      isTableLoading: isTableLoading ?? this.isTableLoading,
    );
  }
}

final class ManageUsersFailure extends ManageUsersState {
  ManageUsersFailure(this.message);

  final String message;
}
