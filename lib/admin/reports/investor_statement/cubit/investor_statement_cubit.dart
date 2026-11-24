import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../model/investor_option.dart';
import '../model/investor_statement_model.dart';
import '../repository/investor_statement_repository.dart';

part 'investor_statement_state.dart';

const String _genericError = 'Something went wrong. Please try again.';

class InvestorStatementCubit extends Cubit<InvestorStatementState> {
  InvestorStatementCubit({
    required this.repository,
    required this.investorsRepository,
  }) : super(const InvestorStatementState());

  final InvestorStatementRepository repository;
  final InvestorsRepository investorsRepository;

  /// Ignores answers of requests that were superseded or cleared.
  int _statementRequest = 0;
  int _investorsRequest = 0;

  Future<void> loadInvestors() async {
    final request = ++_investorsRequest;
    emit(
      state.copyWith(
        investorsStatus: InvestorStatementInvestorsStatus.loading,
        clearInvestorsError: true,
      ),
    );
    try {
      final response = await investorsRepository.getInvestors();
      if (isClosed || request != _investorsRequest) return;
      if (response.status) {
        final options = response.data
            .map(InvestorOption.fromInvestor)
            .toList(growable: false);
        emit(
          state.copyWith(
            investorsStatus: InvestorStatementInvestorsStatus.success,
            investors: options,
          ),
        );
      } else {
        emit(
          state.copyWith(
            investorsStatus: InvestorStatementInvestorsStatus.failure,
            investorsErrorMessage: response.message.isEmpty
                ? _genericError
                : response.message,
          ),
        );
      }
    } catch (e) {
      if (isClosed || request != _investorsRequest) return;
      emit(
        state.copyWith(
          investorsStatus: InvestorStatementInvestorsStatus.failure,
          investorsErrorMessage: ApiErrorMessage.from(e),
        ),
      );
    }
  }

  /// [fromDate] / [toDate] are optional; the other end stays open.
  Future<void> fetchStatement({
    required int userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final request = ++_statementRequest;
    emit(
      state.copyWith(
        statementStatus: InvestorStatementStatus.loading,
        statement: const InvestorStatement(),
        clearStatementError: true,
      ),
    );
    try {
      final response = await repository.getStatement(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
      );
      if (isClosed || request != _statementRequest) return;
      if (response.success) {
        emit(
          state.copyWith(
            statementStatus: InvestorStatementStatus.success,
            statement: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            statementStatus: InvestorStatementStatus.failure,
            statementErrorMessage: response.message.isEmpty
                ? _genericError
                : response.message,
          ),
        );
      }
    } catch (e) {
      if (isClosed || request != _statementRequest) return;
      emit(
        state.copyWith(
          statementStatus: InvestorStatementStatus.failure,
          statementErrorMessage: ApiErrorMessage.from(e),
        ),
      );
    }
  }

  /// Back to "Select an investor" (used on re-activation and on clear).
  void clearStatement() {
    _statementRequest++;
    emit(
      state.copyWith(
        statementStatus: InvestorStatementStatus.initial,
        statement: const InvestorStatement(),
        clearStatementError: true,
      ),
    );
  }
}
