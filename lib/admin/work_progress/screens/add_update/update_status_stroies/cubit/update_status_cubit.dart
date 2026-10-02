import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/add_work_status_model.dart';
import '../repository/add_work_status_repository.dart';

part 'update_status_state.dart';

class UpdateStatusCubit extends Cubit<UpdateStatusState> {
  UpdateStatusCubit({
    required this.repository,
  }) : super(UpdateStatusInitial());

  final AddWorkStatusRepository repository;

  List<WorkStatusModel> _workStatuses = [];
  bool _workStatusesFetched = false;

  List<WorkStatusModel> get workStatuses => List.unmodifiable(_workStatuses);

  bool get hasFetchedWorkStatuses => _workStatusesFetched;

  Future<void> addWorkStatus({
    required String title,
    required String description,
    required MultipartFile file,
  }) async {
    try {
      emit(UpdateStatusLoading());

      final response = await repository.addWorkStatus(
        title: title,
        description: description,
        file: file,
      );

      if (response == null) {
        emit(
          UpdateStatusError(
            message: 'Failed to add work status. Please try again.',
          ),
        );
        return;
      }

      if (response.status) {
        emit(
          UpdateStatusSuccess(
            message: response.message.isNotEmpty
                ? response.message
                : 'Work status added successfully.',
            data: response.data,
          ),
        );
        // Refresh list so View shows the new upload.
        _workStatusesFetched = false;
        await fetchWorkStatus();
      } else {
        emit(
          UpdateStatusError(
            message: response.message.isNotEmpty
                ? response.message
                : 'Failed to add work status. Please try again.',
          ),
        );
      }
    } catch (_) {
      emit(
        UpdateStatusError(
          message:
              'Something went wrong while adding work status. Please try again.',
        ),
      );
    }
  }

  Future<void> fetchWorkStatusIfNeeded() async {
    if (_workStatusesFetched || state is GetWorkStatusLoading) return;
    await fetchWorkStatus();
  }

  Future<void> fetchWorkStatus() async {
    emit(GetWorkStatusLoading());

    try {
      final response = await repository.getWorkStatus();

      if (response != null && response.status) {
        _workStatuses = List<WorkStatusModel>.from(response.data);
        _workStatusesFetched = true;
        emit(
          GetWorkStatusSuccess(
            message: response.message.isNotEmpty
                ? response.message
                : 'Work statuses fetched successfully.',
            workStatuses: List.unmodifiable(_workStatuses),
          ),
        );
        return;
      }

      final apiMessage = response?.message.trim();
      emit(
        GetWorkStatusError(
          message: (apiMessage != null && apiMessage.isNotEmpty)
              ? apiMessage
              : 'Failed to fetch work statuses. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        GetWorkStatusError(
          message: 'Something went wrong while fetching work statuses.',
        ),
      );
    }
  }

  Future<void> deleteWorkStatus({required int workStatusId}) async {
    if (state is DeleteWorkStatusLoading) return;

    if (workStatusId <= 0) {
      emit(
        DeleteWorkStatusError(
          message: 'Invalid media selected. Please try again.',
        ),
      );
      return;
    }

    emit(DeleteWorkStatusLoading(workStatusId: workStatusId));

    try {
      final result = await repository.deleteWorkStatus(id: workStatusId);

      if (result != null && result.status) {
        _workStatuses = _workStatuses
            .where((item) => item.workStatusId != workStatusId)
            .toList();

        final apiMessage = result.message.trim();
        emit(
          DeleteWorkStatusSuccess(
            workStatusId: workStatusId,
            message: apiMessage.isNotEmpty
                ? apiMessage
                : 'Status media deleted successfully.',
          ),
        );
        return;
      }

      final apiMessage = result?.message.trim();
      emit(
        DeleteWorkStatusError(
          message: (apiMessage != null && apiMessage.isNotEmpty)
              ? apiMessage
              : 'Failed to delete status media. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        DeleteWorkStatusError(
          message: 'Something went wrong while deleting. Please try again.',
        ),
      );
    }
  }
}
