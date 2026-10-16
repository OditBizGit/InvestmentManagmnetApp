import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

part 'manage_users_state.dart';

class ManageUsersCubit extends Cubit<ManageUsersState> {
  ManageUsersCubit({required ManageUsersRepository repository})
      : _repository = repository,
        super(const ManageUsersInitial());

  final ManageUsersRepository _repository;

  Future<void> fetchUsers() async {
    if (state is ManageUsersLoading) return;

    emit(const ManageUsersLoading());
    try {
      final response = await _repository.getInvestors();
      if (isClosed) return;

      if (response.skippedCount > 0) {
        log(
          'Get manage users skipped ${response.skippedCount} invalid rows',
          name: 'ManageUsersCubit',
        );
      }

      final hasData = response.users.isNotEmpty;
      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        emit(
          ManageUsersFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load users',
          ),
        );
        return;
      }

      if (!hasData) {
        emit(const ManageUsersEmpty());
        return;
      }

      emit(ManageUsersSuccess(users: response.users));
    } on DioException catch (error) {
      if (isClosed) return;
      emit(
        ManageUsersFailure(
          ApiErrorMessage.from(error, fallback: 'Failed to load users'),
        ),
      );
    } catch (error) {
      log(
        'Get manage users unexpected error: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;
      emit(
        ManageUsersFailure(
          ApiErrorMessage.from(error, fallback: 'Failed to load users'),
        ),
      );
    }
  }

  Future<void> toggleBlockStatus(ManageUsersInvestor user) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.statusUpdatingUserId != null) return;

    final targetIsActive = user.isBlocked;
    final displayName =
        user.name.trim().isEmpty ? 'User' : user.name.trim();

    emit(
      current.copyWith(
        statusUpdatingUserId: user.id,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.blockUser(
        userId: user.id,
        isActive: targetIsActive,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : targetIsActive
              ? '$displayName has been unblocked'
              : '$displayName has been blocked';

      emit(
        latest.copyWith(
          users: [
            for (final item in latest.users)
              if (item.id == user.id)
                item.copyWith(isActive: targetIsActive)
              else
                item,
          ],
          clearStatusUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: targetIsActive ? 'User Unblocked' : 'User Blocked',
            message: message,
          ),
        ),
      );
    } catch (error) {
      log(
        'Update user block status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          clearStatusUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: 'Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to update user status',
            ),
          ),
        ),
      );
    }
  }

  void clearStatusFeedback() {
    final current = state;
    if (current is! ManageUsersSuccess || current.statusFeedback == null) {
      return;
    }

    emit(current.copyWith(clearStatusFeedback: true));
  }

  void updateMouStatus(int userId, DocumentProcessStatus status) {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    emit(
      current.copyWith(
        mouStatus: {...current.mouStatus, userId: status},
      ),
    );
  }

  void updateLlpStatus(int userId, DocumentProcessStatus status) {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    emit(
      current.copyWith(
        llpStatus: {...current.llpStatus, userId: status},
      ),
    );
  }
}
