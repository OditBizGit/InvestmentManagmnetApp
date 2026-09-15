import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';

part 'investors_state.dart';

class InvestorsCubit extends Cubit<InvestorsState> {
  InvestorsCubit({
    required  this._repository,
  }) : super(InvestorsInitial());

  final InvestorsRepository _repository;

  Future<void> fetchInvestors() async {
    emit(InvestorsLoading());
    try {
      final response = await _repository.getInvestors();

      if (!response.status) {
        emit(
          InvestorsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investors',
          ),
        );
        return;
      }

      emit(InvestorsSuccess(response.data));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        InvestorsFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investors'),
        ),
      );
    } catch (e) {
      emit(
        InvestorsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
