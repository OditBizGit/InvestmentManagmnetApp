import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/add_or_update_phase_request_model.dart';
import '../model/add_or_update_phase_response_model.dart';
import '../model/add_phase_model.dart';
import '../model/work_phase_list_model.dart';
import '../repository/update_phase_repository.dart';

part 'update_phase_state.dart';

class UpdatePhaseCubit extends Cubit<UpdatePhaseState> {
  final AddPhaseRepository addPhaseRepository;

  UpdatePhaseCubit({
    required this.addPhaseRepository,
  }) : super(const UpdatePhaseInitial());

  List<AddPhaseModel> _stages = [];
  bool _stageListFetched = false;
  List<WorkPhaseListModel> _workPhases = [];
  bool _workPhaseListFetched = false;

  List<AddPhaseModel> get stages => List.unmodifiable(_stages);

  List<WorkPhaseListModel> get workPhases => List.unmodifiable(_workPhases);

  bool get hasFetchedWorkPhaseList => _workPhaseListFetched;

  Future<void> fetchStageListIfNeeded() async {
    if (_stageListFetched || state is StageListLoading) return;
    await fetchStageList();
  }

  Future<void> fetchStageList() async {
    emit(const StageListLoading());

    try {
      log('UpdatePhaseCubit: Fetching stage list...');
      final result = await addPhaseRepository.getStageList();
      _stages = List<AddPhaseModel>.from(result);
      _stageListFetched = true;
      log('UpdatePhaseCubit: Loaded ${_stages.length} stages.');
      emit(StageListSuccess(List.unmodifiable(_stages)));
    } catch (e, stackTrace) {
      log(
        'UpdatePhaseCubit Stage List Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        StageListFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addPhase({
    required String stageName,
  }) async {
    if (stageName.trim().isEmpty) {
      emit(
        const UpdatePhaseError(
          message: 'Please enter a phase name.',
        ),
      );
      return;
    }

    try {
      emit(const UpdatePhaseLoading());

      log('UpdatePhaseCubit: Adding phase...');
      log('Stage Name: ${stageName.trim()}');

      final request = AddPhaseRequestModel(
        stageName: stageName.trim(),
      );

      final result = await addPhaseRepository.addPhase(request);

      if (result != null) {
        log('UpdatePhaseCubit: Phase added successfully.');
        log('Stage ID: ${result.stageId}');
        log('Stage Name: ${result.stageName}');

        final exists = _stages.any(
          (stage) =>
              stage.stageId == result.stageId ||
              stage.stageName.toLowerCase() ==
                  result.stageName.toLowerCase(),
        );
        if (!exists) {
          _stages = [..._stages, result];
        }

        emit(
          UpdatePhaseSuccess(
            phase: result,
            message: 'Project stage added successfully.',
          ),
        );
      } else {
        log('UpdatePhaseCubit: Failed to add phase.');

        emit(
          const UpdatePhaseError(
            message: 'Failed to add project stage.',
          ),
        );
      }
    } catch (e, stackTrace) {
      log(
        'UpdatePhaseCubit Add Phase Error: $e',
        stackTrace: stackTrace,
      );

      emit(
        UpdatePhaseError(
          message: e.toString(),
        ),
      );
    }
  }

  void restoreStageListState() {
    emit(StageListSuccess(List.unmodifiable(_stages)));
  }

  Future<void> fetchWorkPhaseListIfNeeded() async {
    if (_workPhaseListFetched || state is WorkPhaseListLoading) return;
    await fetchWorkPhaseList();
  }

  Future<void> fetchWorkPhaseList() async {
    emit(const WorkPhaseListLoading());

    try {
      log('UpdatePhaseCubit: Fetching work phase list...');
      final result = await addPhaseRepository.workPhaseList();
      _workPhases = List<WorkPhaseListModel>.from(result);
      _workPhaseListFetched = true;
      log('UpdatePhaseCubit: Loaded ${_workPhases.length} work phases.');
      emit(WorkPhaseListSuccess(List.unmodifiable(_workPhases)));
    } catch (e, stackTrace) {
      log(
        'UpdatePhaseCubit Work Phase List Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        WorkPhaseListFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addOrUpdateWorkPhase({
    required AddOrUpdatePhaseRequestModel request,
    required bool isUpdate,
  }) async {
    try {
      emit(const SaveWorkPhaseLoading());

      log('UpdatePhaseCubit: Saving work phase...');
      log('Stage ID: ${request.stageId}');
      log('Is Update: $isUpdate');

      final result = await addPhaseRepository.addOrUpdatePhase(request);

      if (result != null) {
        log('UpdatePhaseCubit: Work phase saved successfully.');
        emit(
          SaveWorkPhaseSuccess(
            phase: result,
            message: isUpdate
                ? 'Project phase updated successfully.'
                : 'Project phase added successfully.',
            isUpdate: isUpdate,
          ),
        );
        await fetchWorkPhaseList();
      } else {
        emit(
          SaveWorkPhaseFailure(
            isUpdate
                ? 'Failed to update project phase.'
                : 'Failed to add project phase.',
          ),
        );
      }
    } catch (e, stackTrace) {
      log(
        'UpdatePhaseCubit Save Work Phase Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        SaveWorkPhaseFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
