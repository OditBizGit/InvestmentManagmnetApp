import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/model/payment_status_report_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/repository/due_payments_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';
import 'package:flutter/foundation.dart';

part 'due_payments_state.dart';

class DuePaymentsCubit extends Cubit<DuePaymentsState> {
  DuePaymentsCubit(this._repository) : super(const DuePaymentsInitial());

  final PaymentStatusReportRepository _repository;
  CancelToken? _cancelToken;

  DuePaymentsStatusFilter _statusFilter = DuePaymentsStatusFilter.all;
  String _search = '';

  Future<void> fetchPaymentStatusReport({
    DuePaymentsStatusFilter? statusFilter,
    String? search,
  }) async {
    if (statusFilter != null) {
      _statusFilter = statusFilter;
    }
    if (search != null) {
      _search = search;
    }

    _cancelToken?.cancel('Superseded by a new request');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    final previous = state;
    _emitTableLoading(previous);

    try {
      final response = await _repository.getPaymentStatusReport(
        status: _statusFilter.apiStatus,
        search: _search.trim().isEmpty ? null : _search.trim(),
        cancelToken: cancelToken,
      );
      if (isClosed) return;

      final overview = _buildOverview(
        response.data,
        refreshOverview: _statusFilter == DuePaymentsStatusFilter.all &&
            _search.trim().isEmpty,
        previous: previous,
      );

      if (response.data.isEmpty) {
        emit(
          DuePaymentsEmpty(
            statusFilter: _statusFilter,
            search: _search,
            overview: overview,
          ),
        );
        return;
      }

      emit(
        DuePaymentsSuccess(
          items: response.data,
          statusFilter: _statusFilter,
          search: _search,
          overview: overview,
        ),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || isClosed) return;
      emit(
        DuePaymentsFailure(
          message: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load payment status report',
          ),
          statusFilter: _statusFilter,
          search: _search,
          overview: _overviewFromState(previous),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        DuePaymentsFailure(
          message: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load payment status report',
          ),
          statusFilter: _statusFilter,
          search: _search,
          overview: _overviewFromState(previous),
        ),
      );
    }
  }

  void _emitTableLoading(DuePaymentsState previous) {
    switch (previous) {
      case DuePaymentsSuccess():
        emit(previous.copyWith(isTableLoading: true));
      case DuePaymentsEmpty():
        emit(previous.copyWith(isTableLoading: true));
      case DuePaymentsFailure():
        emit(const DuePaymentsLoading());
      default:
        emit(const DuePaymentsLoading());
    }
  }

  DuePaymentsOverviewStats? _overviewFromState(DuePaymentsState state) {
    return switch (state) {
      DuePaymentsSuccess(:final overview) => overview,
      DuePaymentsEmpty(:final overview) => overview,
      DuePaymentsFailure(:final overview) => overview,
      _ => null,
    };
  }

  DuePaymentsOverviewStats? _buildOverview(
    List<PaymentStatusReportModel> items, {
    required bool refreshOverview,
    required DuePaymentsState previous,
  }) {
    if (!refreshOverview) {
      return _overviewFromState(previous);
    }

    var totalOutstanding = 0.0;
    var pendingDues = 0;
    var partiallyPaid = 0;
    var fullyPaid = 0;

    for (final item in items) {
      totalOutstanding += item.outstanding;
      switch (item.normalizedPaymentStatus) {
        case UserPaymentStatus.pending:
          pendingDues++;
        case UserPaymentStatus.partiallyPaid:
          partiallyPaid++;
        case UserPaymentStatus.fullyPaid:
          fullyPaid++;
      }
    }

    return DuePaymentsOverviewStats(
      totalOutstandingDues: totalOutstanding,
      usersWithPendingDues: pendingDues,
      partiallyPaidUsers: partiallyPaid,
      fullyPaidUsers: fullyPaid,
    );
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}

extension DuePaymentsStatusFilterApi on DuePaymentsStatusFilter {
  String get apiStatus {
    switch (this) {
      case DuePaymentsStatusFilter.all:
        return 'All';
      case DuePaymentsStatusFilter.pending:
        return 'Pending';
      case DuePaymentsStatusFilter.partiallyPaid:
        return 'PartiallyPaid';
      case DuePaymentsStatusFilter.fullyPaid:
        return 'FullyPaid';
    }
  }
}

extension PaymentStatusReportModelX on PaymentStatusReportModel {
  String get normalizedPaymentStatusKey =>
      paymentStatus.replaceAll(RegExp(r'\s+'), '');

  UserPaymentStatus get normalizedPaymentStatus {
    switch (normalizedPaymentStatusKey.toLowerCase()) {
      case 'fullypaid':
        return UserPaymentStatus.fullyPaid;
      case 'partiallypaid':
        return UserPaymentStatus.partiallyPaid;
      case 'pending':
        return UserPaymentStatus.pending;
      default:
        if (outstanding <= 0.01) return UserPaymentStatus.fullyPaid;
        if (amountPaid > 0) return UserPaymentStatus.partiallyPaid;
        return UserPaymentStatus.pending;
    }
  }

  String get paymentStatusLabel {
    switch (normalizedPaymentStatus) {
      case UserPaymentStatus.pending:
        return 'Pending';
      case UserPaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case UserPaymentStatus.fullyPaid:
        return 'Fully Paid';
    }
  }

  ManagedUserModel toManagedUser() {
    return ManagedUserModel(
      userId: investorCode.isNotEmpty ? investorCode : '$userId',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      totalPayable: totalPayable,
      amountPaid: amountPaid,
      isBlocked: false,
      lastPaymentDate: paymentDate,
    );
  }
}
