import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/user/home/model/app_notification_model.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required NotificationsRepository repository,
  })  : _repository = repository,
        super(const NotificationsInitial());

  final NotificationsRepository _repository;

  bool _isLoading = false;
  bool _isMarkingAllAsRead = false;
  int _loadToken = 0;
  final Set<int> _markingAsReadIds = <int>{};

  static const _minShimmerDuration = Duration(seconds: 3);

  Future<void> loadNotifications({bool silent = false}) async {
    // Silent refresh should not interrupt an in-flight request.
    if (_isLoading && silent) return;

    final token = ++_loadToken;
    _isLoading = true;
    final startedAt = DateTime.now();

    if (!silent) {
      emit(const NotificationsLoading());
    }

    try {
      final notifications = await _repository.getMyNotifications();
      if (token != _loadToken) return;
      emit(NotificationsSuccess(notifications));
    } on DioException catch (e) {
      if (token != _loadToken) return;
      if (silent && state is NotificationsSuccess) return;
      await _holdShimmerIfNeeded(
        silent: silent,
        startedAt: startedAt,
        token: token,
      );
      if (token != _loadToken || isClosed) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        NotificationsFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load notifications'),
        ),
      );
    } catch (e) {
      if (token != _loadToken) return;
      if (silent && state is NotificationsSuccess) return;
      await _holdShimmerIfNeeded(
        silent: silent,
        startedAt: startedAt,
        token: token,
      );
      if (token != _loadToken || isClosed) return;
      emit(
        NotificationsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      if (token == _loadToken) {
        _isLoading = false;
      }
    }
  }

  Future<void> _holdShimmerIfNeeded({
    required bool silent,
    required DateTime startedAt,
    required int token,
  }) async {
    if (silent) return;

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minShimmerDuration - elapsed;
    if (remaining <= Duration.zero) return;

    await Future<void>.delayed(remaining);
    if (token != _loadToken || isClosed) return;
  }

  Future<void> markAsRead(int notificationId) async {
    if (notificationId <= 0) return;

    final current = state;
    if (current is! NotificationsSuccess) return;

    final index = current.notifications.indexWhere(
      (item) => item.notificationId == notificationId,
    );
    if (index < 0) return;

    final target = current.notifications[index];
    if (target.isRead || _markingAsReadIds.contains(notificationId)) return;

    _markingAsReadIds.add(notificationId);

    // Optimistically mark as read for immediate UI feedback.
    final optimistic = List<AppNotificationModel>.from(current.notifications);
    optimistic[index] = target.copyWith(
      isRead: true,
      readDate: DateTime.now(),
    );
    emit(NotificationsSuccess(optimistic));

    try {
      await _repository.markAsRead(notificationId: notificationId);
    } catch (_) {
      // Revert if the API call fails.
      if (!isClosed && state is NotificationsSuccess) {
        final latest = state as NotificationsSuccess;
        final revertIndex = latest.notifications.indexWhere(
          (item) => item.notificationId == notificationId,
        );
        if (revertIndex >= 0) {
          final reverted =
              List<AppNotificationModel>.from(latest.notifications);
          reverted[revertIndex] = target;
          emit(NotificationsSuccess(reverted));
        }
      }
    } finally {
      _markingAsReadIds.remove(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsSuccess || _isMarkingAllAsRead) return;

    final hasUnread = current.notifications.any((item) => !item.isRead);
    if (!hasUnread) return;

    _isMarkingAllAsRead = true;
    final previous = current.notifications;
    final now = DateTime.now();

    emit(
      NotificationsSuccess(
        previous
            .map(
              (item) => item.isRead
                  ? item
                  : item.copyWith(isRead: true, readDate: now),
            )
            .toList(growable: false),
      ),
    );

    try {
      await _repository.markAllAsRead();
    } catch (_) {
      if (!isClosed) {
        emit(NotificationsSuccess(previous));
      }
    } finally {
      _isMarkingAllAsRead = false;
    }
  }
}
