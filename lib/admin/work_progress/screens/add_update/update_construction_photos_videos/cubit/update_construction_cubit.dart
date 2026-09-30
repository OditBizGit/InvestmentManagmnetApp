import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/add_work_update_response_model.dart';
import '../model/get_work_updates_model.dart';
import '../repository/update_construction_repository.dart';
part 'update_construction_state.dart';

class UpdateConstructionCubit extends Cubit<UpdateConstructionState> {
  final WorkUpdateRepository workUpdateRepository;

  UpdateConstructionCubit({
    required this.workUpdateRepository,
  }) : super(UpdateConstructionInitial());

  List<WorkUpdateModel> _workUpdates = [];
  bool _workUpdatesFetched = false;

  List<WorkUpdateModel> get workUpdates => List.unmodifiable(_workUpdates);

  bool get hasFetchedWorkUpdates => _workUpdatesFetched;

  Future<void> fetchWorkUpdatesIfNeeded() async {
    if (_workUpdatesFetched || state is GetWorkUpdatesLoading) return;
    await fetchWorkUpdates();
  }

  Future<void> fetchWorkUpdates() async {
    emit(GetWorkUpdatesLoading());

    try {
      final result = await workUpdateRepository.getWorkUpdates();

      if (result != null && result.status) {
        _workUpdates = List<WorkUpdateModel>.from(result.data);
        _workUpdatesFetched = true;
        emit(GetWorkUpdatesSuccess(updates: List.unmodifiable(_workUpdates)));
        return;
      }

      final apiMessage = result?.message.trim();
      emit(
        GetWorkUpdatesError(
          message: (apiMessage != null && apiMessage.isNotEmpty)
              ? apiMessage
              : 'Failed to load construction media. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        GetWorkUpdatesError(
          message:
              'Something went wrong while loading media. Please try again.',
        ),
      );
    }
  }

  Future<void> deleteWorkUpdate({required int workUpdateId}) async {
    if (state is DeleteWorkUpdateLoading) return;

    if (workUpdateId <= 0) {
      emit(
        DeleteWorkUpdateError(
          message: 'Invalid media selected. Please try again.',
        ),
      );
      return;
    }

    emit(DeleteWorkUpdateLoading(workUpdateId: workUpdateId));

    try {
      final result = await workUpdateRepository.deleteWorkUpdate(
        id: workUpdateId,
      );

      if (result != null && result.status) {
        _workUpdates = _workUpdates
            .where((item) => item.workUpdateId != workUpdateId)
            .toList();

        final apiMessage = result.message.trim();
        emit(
          DeleteWorkUpdateSuccess(
            workUpdateId: workUpdateId,
            message: apiMessage.isNotEmpty
                ? apiMessage
                : 'Construction media deleted successfully.',
          ),
        );
        return;
      }

      final apiMessage = result?.message.trim();
      emit(
        DeleteWorkUpdateError(
          message: (apiMessage != null && apiMessage.isNotEmpty)
              ? apiMessage
              : 'Failed to delete construction media. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        DeleteWorkUpdateError(
          message:
              'Something went wrong while deleting. Please try again.',
        ),
      );
    }
  }

  Future<void> addWorkUpdate({
    required String title,
    required String description,
    required MultipartFile file,
  }) async {
    emit(UpdateConstructionLoading());

    try {
      final result = await workUpdateRepository.addWorkUpdate(
        title: title,
        description: description,
        file: file,
      );

      if (result != null && result.status) {
        emit(
          UpdateConstructionSuccess(
            response: result,
          ),
        );
        // Refresh list so View shows the new upload.
        _workUpdatesFetched = false;
        await fetchWorkUpdates();
      } else {
        final apiMessage = result?.message.trim();
        emit(
          UpdateConstructionError(
            message: (apiMessage != null && apiMessage.isNotEmpty)
                ? apiMessage
                : 'Failed to upload construction media. Please try again.',
          ),
        );
      }
    } catch (_) {
      emit(
        UpdateConstructionError(
          message:
              'Something went wrong while uploading. Please try again.',
        ),
      );
    }
  }
}
