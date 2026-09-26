import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/complaint_ui_model.dart';
import '../repository/user_complaints_respository.dart';

part 'user_complaints_state.dart';

class UserComplaintsCubit extends Cubit<UserComplaintsState> {
  UserComplaintsCubit({
    required this.userComplaintsRepository,
  }) : super(const UserComplaintsInitial());

  final UserComplaintsRepository userComplaintsRepository;

  List<UserComplaintModel> _complaints = [];
  int? _solvingComplaintId;
  int? _viewingComplaintId;

  List<UserComplaintModel> get complaints => List.unmodifiable(_complaints);

  Future<void> fetchUserComplaints({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      emit(const UserComplaintsLoading());

      final result = await userComplaintsRepository.getUserComplaints(
        fromDate: fromDate,
        toDate: toDate,
      );

      if (result != null) {
        _complaints = List<UserComplaintModel>.from(result);
        emit(
          UserComplaintsSuccess(
            complaints: List.unmodifiable(_complaints),
            message: _complaints.isEmpty
                ? 'No complaints found for the selected date range.'
                : 'Complaints loaded successfully.',
          ),
        );
      } else {
        emit(
          const UserComplaintsFailure(
            'Failed to load complaints. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(
        UserComplaintsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> markAsRead(int complaintId) async {
    if (complaintId <= 0) {
      emit(
        const ViewComplaintFailure(
          message: 'Invalid complaint selected.',
        ),
      );
      return;
    }

    if (_viewingComplaintId != null) return;

    final viewIndex =
        _complaints.indexWhere((item) => item.complaintId == complaintId);
    if (viewIndex >= 0 && _complaints[viewIndex].isRead) return;

    try {
      _viewingComplaintId = complaintId;
      emit(ViewComplaintLoading(complaintId: complaintId));
      log('UserComplaintsCubit: Marking complaint $complaintId as read...');

      final result = await userComplaintsRepository.viewComplaint(
        complaintId: complaintId,
      );

      if (result != null && result.apiStatus != false) {
        _complaints = _complaints
            .map(
              (item) => item.complaintId == complaintId
                  ? item.copyWith(status: 'Viewed')
                  : item,
            )
            .toList(growable: false);

        final message = (result.message?.trim().isNotEmpty ?? false)
            ? result.message!.trim()
            : 'Complaint marked as read';

        log('UserComplaintsCubit: Complaint $complaintId marked as read.');
        emit(
          ViewComplaintSuccess(
            complaintId: complaintId,
            message: message,
          ),
        );
        emit(
          UserComplaintsSuccess(
            complaints: List.unmodifiable(_complaints),
          ),
        );
      } else {
        final message = (result?.message?.trim().isNotEmpty ?? false)
            ? result!.message!.trim()
            : 'Failed to mark complaint as read. Please try again.';
        log('UserComplaintsCubit: Mark as read failed.');
        emit(ViewComplaintFailure(message: message));
      }
    } catch (e, stackTrace) {
      log(
        'UserComplaintsCubit Mark As Read Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        ViewComplaintFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _viewingComplaintId = null;
    }
  }

  Future<void> solveComplaint(int complaintId) async {
    if (complaintId <= 0) {
      emit(
        const SolveComplaintFailure(
          message: 'Invalid complaint selected.',
        ),
      );
      return;
    }

    // Prevent duplicate in-flight solve requests.
    if (_solvingComplaintId != null) return;

    final solveIndex =
        _complaints.indexWhere((item) => item.complaintId == complaintId);
    if (solveIndex >= 0 && _complaints[solveIndex].isSolved) return;

    try {
      _solvingComplaintId = complaintId;
      emit(SolveComplaintLoading(complaintId: complaintId));
      log('UserComplaintsCubit: Solving complaint $complaintId...');

      final result = await userComplaintsRepository.solveComplaint(
        complaintId: complaintId,
      );

      if (result != null &&
          result.apiStatus != false &&
          result.isSolved) {
        _complaints = _complaints
            .map(
              (item) => item.complaintId == complaintId
                  ? item.copyWith(status: 'Solved')
                  : item,
            )
            .toList(growable: false);

        final message = (result.message?.trim().isNotEmpty ?? false)
            ? result.message!.trim()
            : 'Complaint marked as solved';

        log('UserComplaintsCubit: Complaint $complaintId solved.');
        emit(
          SolveComplaintSuccess(
            complaintId: complaintId,
            message: message,
          ),
        );
        emit(
          UserComplaintsSuccess(
            complaints: List.unmodifiable(_complaints),
          ),
        );
      } else {
        final message = (result?.message?.trim().isNotEmpty ?? false)
            ? result!.message!.trim()
            : 'Failed to mark complaint as solved. Please try again.';
        log('UserComplaintsCubit: Solve complaint failed.');
        emit(SolveComplaintFailure(message: message));
      }
    } catch (e, stackTrace) {
      log(
        'UserComplaintsCubit Solve Complaint Error: $e',
        stackTrace: stackTrace,
      );
      emit(
        SolveComplaintFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _solvingComplaintId = null;
    }
  }
}
