import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../../work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import '../../work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import '../model/all_transaction_history_model.dart';
import '../model/dashboard_model.dart';
import '../model/recent_updates_model.dart';
import '../model/top_investors_model.dart';
import '../repository/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AddPhaseRepository phaseRepository;
  final DashboardRepository dashboardRepository;

  static const String noInternetMessage = ApiErrorMessage.noInternet;

  DashboardCubit({
    required this.phaseRepository,
    required this.dashboardRepository,
  }) : super(const DashboardState());

  Future<void> loadDashboard() async {
    await getDashboardSummary();
    // If offline, apply the same short message to every section and stop.
    if (state.dashboardError == noInternetMessage) {
      _emitOfflineForRemainingSections();
      return;
    }
    await getWorkProgress();
    await getTopInvestors();
    await getRecentPayments();
    await getRecentUpdates();
  }

  void _emitOfflineForRemainingSections() {
    emit(
      state.copyWith(
        workProgressLoading: false,
        workProgressLoaded: true,
        workProgressError: noInternetMessage,
        topInvestorsLoading: false,
        topInvestorsLoaded: true,
        topInvestorsError: noInternetMessage,
        recentPaymentsLoading: false,
        recentPaymentsLoaded: true,
        recentPaymentsError: noInternetMessage,
        recentUpdatesLoading: false,
        recentUpdatesLoaded: true,
        recentUpdatesError: noInternetMessage,
      ),
    );
  }

  Future<void> getDashboardSummary() async {
    emit(
      state.copyWith(
        dashboardLoading: true,
        clearDashboardError: true,
      ),
    );

    try {
      log('DashboardCubit: Fetching dashboard summary...');

      final dashboard = await dashboardRepository.getDashboard();

      log('DashboardCubit: Dashboard summary fetched');

      emit(
        state.copyWith(
          dashboardLoading: false,
          dashboardLoaded: true,
          dashboard: dashboard,
          clearDashboardError: true,
        ),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'DashboardCubit: Dashboard summary Dio error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          dashboardLoading: false,
          dashboardLoaded: true,
          dashboardError: _errorMessage(
            e,
            fallback: 'Failed to load dashboard',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'DashboardCubit: Dashboard summary error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          dashboardLoading: false,
          dashboardLoaded: true,
          dashboardError: _errorMessage(
            e,
            fallback: 'Failed to load dashboard',
          ),
        ),
      );
    }
  }

  Future<void> getWorkProgress() async {
    emit(
      state.copyWith(
        workProgressLoading: true,
        clearWorkProgressError: true,
      ),
    );

    try {
      log('DashboardCubit: Fetching work phase list...');

      final workPhases = await phaseRepository.workPhaseList();

      log(
        'DashboardCubit: Work phase list fetched '
        '(${workPhases.length} items)',
      );

      emit(
        state.copyWith(
          workProgressLoading: false,
          workProgressLoaded: true,
          workPhases: List<WorkPhaseListModel>.unmodifiable(workPhases),
          clearWorkProgressError: true,
        ),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'DashboardCubit: Work phase list Dio error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          workProgressLoading: false,
          workProgressLoaded: true,
          workProgressError: _errorMessage(
            e,
            fallback: 'Failed to load work progress',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'DashboardCubit: Work phase list error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          workProgressLoading: false,
          workProgressLoaded: true,
          workProgressError: _errorMessage(
            e,
            fallback: 'Failed to load work progress',
          ),
        ),
      );
    }
  }

  Future<void> getTopInvestors() async {
    emit(
      state.copyWith(
        topInvestorsLoading: true,
        clearTopInvestorsError: true,
      ),
    );

    try {
      log('DashboardCubit: Fetching top investors...');

      final investors = await dashboardRepository.getTopInvestors();

      log(
        'DashboardCubit: Top investors fetched '
        '(${investors.length} items)',
      );

      emit(
        state.copyWith(
          topInvestorsLoading: false,
          topInvestorsLoaded: true,
          topInvestors: List<TopInvestorsModel>.unmodifiable(investors),
          clearTopInvestorsError: true,
        ),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'DashboardCubit: Top investors Dio error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          topInvestorsLoading: false,
          topInvestorsLoaded: true,
          topInvestorsError: _errorMessage(
            e,
            fallback: 'Failed to load top investors',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'DashboardCubit: Top investors error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          topInvestorsLoading: false,
          topInvestorsLoaded: true,
          topInvestorsError: _errorMessage(
            e,
            fallback: 'Failed to load top investors',
          ),
        ),
      );
    }
  }

  Future<void> getRecentPayments() async {
    emit(
      state.copyWith(
        recentPaymentsLoading: true,
        clearRecentPaymentsError: true,
      ),
    );

    try {
      log('DashboardCubit: Fetching recent payments...');

      final payments = await dashboardRepository.getPaymentHistory();

      log(
        'DashboardCubit: Recent payments fetched '
        '(${payments.length} items)',
      );

      emit(
        state.copyWith(
          recentPaymentsLoading: false,
          recentPaymentsLoaded: true,
          recentPayments: List<TransactionHistoryModel>.unmodifiable(payments),
          clearRecentPaymentsError: true,
        ),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'DashboardCubit: Recent payments Dio error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          recentPaymentsLoading: false,
          recentPaymentsLoaded: true,
          recentPaymentsError: _errorMessage(
            e,
            fallback: 'Failed to load recent payments',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'DashboardCubit: Recent payments error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          recentPaymentsLoading: false,
          recentPaymentsLoaded: true,
          recentPaymentsError: _errorMessage(
            e,
            fallback: 'Failed to load recent payments',
          ),
        ),
      );
    }
  }

  Future<void> getRecentUpdates() async {
    emit(
      state.copyWith(
        recentUpdatesLoading: true,
        clearRecentUpdatesError: true,
      ),
    );

    try {
      log('DashboardCubit: Fetching recent updates...');

      final updates = await dashboardRepository.recentWorkUpdates();

      log(
        'DashboardCubit: Recent updates fetched '
        '(${updates.length} items)',
      );

      emit(
        state.copyWith(
          recentUpdatesLoading: false,
          recentUpdatesLoaded: true,
          recentUpdates: List<WorkUpdateModel>.unmodifiable(updates),
          clearRecentUpdatesError: true,
        ),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'DashboardCubit: Recent updates Dio error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          recentUpdatesLoading: false,
          recentUpdatesLoaded: true,
          recentUpdatesError: _errorMessage(
            e,
            fallback: 'Failed to load recent updates',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'DashboardCubit: Recent updates error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          recentUpdatesLoading: false,
          recentUpdatesLoaded: true,
          recentUpdatesError: _errorMessage(
            e,
            fallback: 'Failed to load recent updates',
          ),
        ),
      );
    }
  }

  String _errorMessage(
    Object e, {
    required String fallback,
  }) {
    return ApiErrorMessage.from(e, fallback: fallback);
  }
}
