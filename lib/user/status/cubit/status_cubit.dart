import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/user/status/model/work_status_model.dart';
import 'package:maribel_wellness_centre_application/user/status/repository/status_repository.dart';

part 'status_state.dart';

class StatusCubit extends Cubit<StatusState> {
  StatusCubit({
    required StatusRepository repository,
  })  : _repository = repository,
        super(
          repository.cachedStatuses != null
              ? StatusSuccess(repository.cachedStatuses!)
              : const StatusInitial(),
        );

  final StatusRepository _repository;
  bool _isLoading = false;

  Future<void> loadStatuses({
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    if (!forceRefresh) {
      final cached = _repository.cachedStatuses;
      if (cached != null) {
        emit(StatusSuccess(cached));
        return;
      }
      if (state is StatusSuccess) return;
    }

    _isLoading = true;
    if (!silent) {
      emit(const StatusLoading());
    }

    try {
      final statuses = await _repository.getWorkStatus(
        forceRefresh: forceRefresh || silent,
      );
      emit(StatusSuccess(statuses));
    } on DioException catch (e) {
      if (silent && state is StatusSuccess) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        StatusFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load work statuses'),
        ),
      );
    } catch (e) {
      if (silent && state is StatusSuccess) return;
      emit(
        StatusFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }
}
