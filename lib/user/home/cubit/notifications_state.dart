part of 'notifications_cubit.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsSuccess extends NotificationsState {
  const NotificationsSuccess(this.notifications);

  final List<AppNotificationModel> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

final class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(this.message);

  final String message;
}
