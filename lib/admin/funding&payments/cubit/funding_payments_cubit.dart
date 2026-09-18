import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_transaction_history_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';

part 'funding_payments_state.dart';

class FundingPaymentsCubit extends Cubit<FundingPaymentsState> {
  FundingPaymentsCubit({
    required this._investorsRepository,
    required this._paymentRepository,
  }) : super(FundingPaymentsInitial());

  final InvestorsRepository _investorsRepository;
  final InvestorPaymentRepository _paymentRepository;

  List<InvestorModel> _investors = [];
  List<InvestorTransactionHistoryModel> _transactionHistory = [];

  List<InvestorModel> get investors => _investors;

  List<InvestorTransactionHistoryModel> get transactionHistory =>
      _transactionHistory;

  Future<void> fetchInvestors() async {
    emit(FundingInvestorsLoading());
    try {
      final response = await _investorsRepository.getInvestors();

      final hasData = response.data.isNotEmpty;
      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        emit(
          FundingInvestorsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investors',
          ),
        );
        return;
      }

      _investors = response.data;
      emit(FundingInvestorsSuccess(response.data));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        FundingInvestorsFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investors'),
        ),
      );
    } catch (e) {
      emit(
        FundingInvestorsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> addInvestorPayment(
    AddInvestorPaymentRequestModel request,
  ) async {
    emit(AddPaymentLoading());
    try {
      final response = await _paymentRepository.addInvestorPayment(request);

      if (!response.status) {
        emit(
          AddPaymentFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to add payment',
          ),
        );
        return;
      }

      emit(
        AddPaymentSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Payment added successfully',
          data: response.data,
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        AddPaymentFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to add payment'),
        ),
      );
    } catch (e) {
      emit(
        AddPaymentFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> fetchAllInvestorTransactionHistory() async {
    emit(TransactionHistoryLoading());
    try {
      final response =
          await _paymentRepository.getAllInvestorTransactionHistory();

      final hasData = response.data.isNotEmpty;
      final looksSuccessful = response.status ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        emit(
          TransactionHistoryFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load transaction history',
          ),
        );
        return;
      }

      _transactionHistory = response.data;

      if (_transactionHistory.isEmpty) {
        emit(
          TransactionHistoryEmpty(
            message: response.message.isNotEmpty
                ? response.message
                : 'No transaction history found',
          ),
        );
        return;
      }

      emit(TransactionHistorySuccess(_transactionHistory));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        TransactionHistoryFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load transaction history'),
        ),
      );
    } catch (e) {
      emit(
        TransactionHistoryFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  List<InvestorTransactionHistoryModel> transactionsForInvestor({
    String? fullName,
    int? userId,
  }) {
    final name = fullName?.trim().toLowerCase();
    return _transactionHistory.where((item) {
      final matchesName = name == null ||
          name.isEmpty ||
          item.fullName.trim().toLowerCase() == name;
      final matchesUser =
          userId == null || userId == 0 || item.userId == userId;
      return matchesName && matchesUser;
    }).toList();
  }
}
