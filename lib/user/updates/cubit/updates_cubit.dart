import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_update_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/repository/updates_repository.dart';

part 'updates_state.dart';

class UpdatesCubit extends Cubit<UpdatesState> {
  UpdatesCubit({
    required UpdatesRepository repository,
  })  : _repository = repository,
        super(
          repository.cachedUpdates != null
              ? UpdatesSuccess(repository.cachedUpdates!)
              : const UpdatesInitial(),
        );

  final UpdatesRepository _repository;
  bool _isLoading = false;

  Future<void> loadUpdates({
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // Instant UI from cache when available (non-forced loads only).
    if (!forceRefresh) {
      final cached = _repository.cachedUpdates;
      if (cached != null) {
        emit(UpdatesSuccess(cached));
        return;
      }
      if (state is UpdatesSuccess) return;
    }

    _isLoading = true;
    if (!silent) {
      emit(const UpdatesLoading());
    }

    try {
      final updates = await _repository.getWorkUpdates(
        forceRefresh: forceRefresh || silent,
      );
      emit(UpdatesSuccess(updates));
    } on DioException catch (e) {
      if (silent && state is UpdatesSuccess) return;
      emit(
        UpdatesFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to load work updates',
          ),
        ),
      );
    } catch (e) {
      if (silent && state is UpdatesSuccess) return;
      emit(
        UpdatesFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to load work updates',
          ),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }
}
