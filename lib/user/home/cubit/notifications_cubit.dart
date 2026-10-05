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

  Future<void> loadNotifications({bool silent = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!silent) {
      emit(const NotificationsLoading());
    }

    try {
      final notifications = await _repository.getMyNotifications();
      emit(NotificationsSuccess(notifications));
    } on DioException catch (e) {
      if (silent && state is NotificationsSuccess) return;
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
      if (silent && state is NotificationsSuccess) return;
      emit(
        NotificationsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }
}
