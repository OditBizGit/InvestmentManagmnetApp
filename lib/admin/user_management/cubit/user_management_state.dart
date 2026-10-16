part of 'user_management_cubit.dart';

class UserManagementState {
  const UserManagementState({required this.users});

  final List<ManagedUserModel> users;

  int get totalUsers => users.length;

  int get activeUsers => users.where((user) => !user.isBlocked).length;

  int get blockedUsers => users.where((user) => user.isBlocked).length;

  int get usersWithPendingDues =>
      users.where((user) => user.hasPendingDues).length;

  double get totalOutstandingDues => users.fold<double>(
        0,
        (sum, user) => sum + user.outstandingBalance,
      );

  int get partiallyPaidUsers => users
      .where((user) => user.paymentStatus == UserPaymentStatus.partiallyPaid)
      .length;

  int get fullyPaidUsers => users
      .where((user) => user.paymentStatus == UserPaymentStatus.fullyPaid)
      .length;

  UserManagementState copyWith({List<ManagedUserModel>? users}) {
    return UserManagementState(users: users ?? this.users);
  }
}
