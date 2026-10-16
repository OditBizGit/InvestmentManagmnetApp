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
  const ManageUsersEmpty();
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
    this.statusFeedback,
  });

  final List<ManageUsersInvestor> users;
  final Map<int, DocumentProcessStatus> mouStatus;
  final Map<int, DocumentProcessStatus> llpStatus;
  final int? statusUpdatingUserId;
  final ManageUsersStatusFeedback? statusFeedback;

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
    ManageUsersStatusFeedback? statusFeedback,
    bool clearStatusFeedback = false,
  }) {
    return ManageUsersSuccess(
      users: users ?? this.users,
      mouStatus: mouStatus ?? this.mouStatus,
      llpStatus: llpStatus ?? this.llpStatus,
      statusUpdatingUserId: clearStatusUpdatingUserId
          ? null
          : statusUpdatingUserId ?? this.statusUpdatingUserId,
      statusFeedback: clearStatusFeedback
          ? null
          : statusFeedback ?? this.statusFeedback,
    );
  }
}

final class ManageUsersFailure extends ManageUsersState {
  ManageUsersFailure(this.message);

  final String message;
}
