import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_data_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/repository/investments_repository.dart';

part 'investments_state.dart';

class InvestmentsCubit extends Cubit<InvestmentsState> {
  InvestmentsCubit({
    required InvestmentsRepository repository,
    required LocalStorage localStorage,
  })  : _repository = repository,
        _localStorage = localStorage,
        super(const InvestmentsInitial());

  final InvestmentsRepository _repository;
  final LocalStorage _localStorage;

  Future<void> loadInvestments({bool silent = false}) async {
    if (!silent) {
      emit(const InvestmentsLoading());
    }

    final userId = _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      if (!silent || state is! InvestmentsSuccess) {
        emit(const InvestmentsFailure('User not logged in'));
      }
      return;
    }

    try {
      final response =
          await _repository.getInvestorTransactionHistory(userId);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful || response.data == null) {
        if (silent && state is InvestmentsSuccess) return;
        emit(
          InvestmentsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investment history',
          ),
        );
        return;
      }

      emit(InvestmentsSuccess(response.data!));
    } on DioException catch (e) {
      if (silent && state is InvestmentsSuccess) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        InvestmentsFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investment history'),
        ),
      );
    } catch (e) {
      if (silent && state is InvestmentsSuccess) return;
      emit(
        InvestmentsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
