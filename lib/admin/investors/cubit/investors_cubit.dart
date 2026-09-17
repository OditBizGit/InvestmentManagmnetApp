import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_type_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/register_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';

part 'investors_state.dart';

class InvestorsCubit extends Cubit<InvestorsState> {
  InvestorsCubit({
    required this._repository,
  }) : super(InvestorsInitial());

  final InvestorsRepository _repository;

  List<InvestorTypeModel> _investorTypes = [];

  List<InvestorTypeModel> get investorTypes => _investorTypes;

  Future<void> fetchInvestors() async {
    emit(InvestorsLoading());
    try {
      final response = await _repository.getInvestors();

      // Some API payloads mark success via code/message even if `status` is absent.
      final hasData = response.data.isNotEmpty;
      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        emit(
          InvestorsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investors',
          ),
        );
        return;
      }

      emit(
        InvestorsSuccess(
          response.data,
          total: response.total,
        ),
      );
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

  Future<void> fetchInvestorTypes() async {
    emit(InvestorTypesLoading());
    try {
      final response = await _repository.getInvestorTypes();

      if (!response.status) {
        emit(
          InvestorTypesFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investor types',
          ),
        );
        return;
      }

      _investorTypes = response.data;
      emit(InvestorTypesSuccess(response.data));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        InvestorTypesFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investor types'),
        ),
      );
    } catch (e) {
      emit(
        InvestorTypesFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> registerInvestor(RegisterInvestorRequestModel request) async {
    emit(RegisterInvestorLoading());
    try {
      final response = await _repository.registerInvestor(request);

      if (!response.status) {
        emit(
          RegisterInvestorFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to register investor',
          ),
        );
        return;
      }

      emit(
        RegisterInvestorSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Investor registered successfully',
          data: response.data,
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        RegisterInvestorFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to register investor'),
        ),
      );
    } catch (e) {
      emit(
        RegisterInvestorFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
