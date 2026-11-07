import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../model/monthly_payment_list_model.dart';
import '../repository/monthly_payment_list_repository.dart';


part 'payment_list_state.dart';

class PaymentListCubit extends Cubit<PaymentListState> {
  PaymentListCubit({
    required this._repository,
  })  : super(PaymentListInitial());

  final MonthlyPaymentListRepository _repository;

  Future<void> fetchMonthlyPaymentList({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    emit(PaymentListLoading());

    try {
      final response = await _repository.getMonthlyPaymentList(
        fromDate: fromDate,
        toDate: toDate,
      );

      if (response.status) {
        emit(
          PaymentListLoaded(
            data: response.data,
          ),
        );
      } else {
        emit(
          PaymentListError(
            message: response.message.isNotEmpty
                ? response.message
                : 'Failed to fetch monthly payment list.',
          ),
        );
      }
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;

      log(
        'Fetch monthly payment list failed: ${error.message}',
        name: 'PaymentListCubit',
      );

      emit(
        PaymentListError(
          message: message ?? error.message ?? 'Something went wrong.',
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Unexpected error: $error',
        name: 'PaymentListCubit',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        PaymentListError(
          message: 'Failed to fetch monthly payment list.',
        ),
      );
    }
  }
}