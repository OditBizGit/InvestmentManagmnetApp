import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';

part 'work_progress_state.dart';

class WorkProgressCubit extends Cubit<WorkProgressState> {
  WorkProgressCubit({
    required this.repository,
  }) : super(const WorkProgressInitial());

  final AddPhaseRepository repository;

  List<WorkPhaseListModel> _phases = [];

  List<WorkPhaseListModel> get phases => List.unmodifiable(_phases);

  Future<void> fetchWorkPhaseList() async {
    emit(const WorkProgressLoading());

    try {
      log('WorkProgressCubit: Fetching work phase list...');
      final result = await repository.workPhaseList();
      _phases = List<WorkPhaseListModel>.from(result);
      log('WorkProgressCubit: Loaded ${_phases.length} phases.');
      emit(WorkProgressSuccess(List.unmodifiable(_phases)));
    } catch (e, stackTrace) {
      log(
        'WorkProgressCubit Work Phase List Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        WorkProgressFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
