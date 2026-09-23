import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/funding_investor_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';

part 'funding_payments_state.dart';

class FundingPaymentsCubit extends Cubit<FundingPaymentsState> {
  FundingPaymentsCubit({
    required InvestorsRepository investorsRepository,
    required InvestorPaymentRepository paymentRepository,
  })  : _investorsRepository = investorsRepository,
        _paymentRepository = paymentRepository,
        super(FundingPaymentsInitial());

  final InvestorsRepository _investorsRepository;
  final InvestorPaymentRepository _paymentRepository;

  List<InvestorModel> _investors = [];
  List<FundingInvestorModel> _fundingInvestors = [];
  InvestorDetailsModel? _investorDetails;
  bool _isFundingInvestorsRequestInFlight = false;

  List<InvestorModel> get investors => _investors;

  List<FundingInvestorModel> get fundingInvestors => _fundingInvestors;

  InvestorDetailsModel? get investorDetails => _investorDetails;

  bool get hasFundingInvestors => _fundingInvestors.isNotEmpty;

  /// Kept for existing UI naming.
  List<FundingInvestorModel> get transactionHistory => _fundingInvestors;

  bool get hasTransactionHistory => hasFundingInvestors;

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

  /// Investors-style first load: spinner only when memory is empty.
  Future<void> fetchFundingInvestors() async {
    if (_fundingInvestors.isEmpty) {
      emit(TransactionHistoryLoading());
    }
    await _loadFundingInvestors(silent: _fundingInvestors.isNotEmpty);
  }

  /// Keeps current rows visible — used after returning from Add Fund.
  Future<void> refreshSilently() async {
    await _loadFundingInvestors(silent: true);
  }

  Future<void> fetchInvestorDetails(int userId) async {
    emit(InvestorDetailsLoading());
    try {
      final response = await _paymentRepository.getInvestorDetails(
        userId: userId,
      );

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful || response.data == null) {
        emit(
          InvestorDetailsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investor details',
          ),
        );
        return;
      }

      _investorDetails = response.data;
      emit(InvestorDetailsSuccess(response.data!));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        InvestorDetailsFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investor details'),
        ),
      );
    } catch (e) {
      emit(
        InvestorDetailsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearInvestorDetails() {
    _investorDetails = null;
  }

  Future<void> _loadFundingInvestors({required bool silent}) async {
    if (_isFundingInvestorsRequestInFlight) return;
    _isFundingInvestorsRequestInFlight = true;

    try {
      final response = await _paymentRepository.getFundingInvestors();

      final hasData = response.investors.isNotEmpty;
      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        if (!silent || _fundingInvestors.isEmpty) {
          emit(
            TransactionHistoryFailure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load investors',
            ),
          );
        }
        return;
      }

      _fundingInvestors = List<FundingInvestorModel>.from(response.investors);

      if (_fundingInvestors.isEmpty) {
        emit(
          TransactionHistoryEmpty(
            message: response.message.isNotEmpty
                ? response.message
                : 'No investors found',
          ),
        );
        return;
      }

      emit(
        TransactionHistorySuccess(
          List<FundingInvestorModel>.unmodifiable(_fundingInvestors),
        ),
      );
    } on DioException catch (e) {
      if (silent && _fundingInvestors.isNotEmpty) return;

      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        TransactionHistoryFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investors'),
        ),
      );
    } catch (e) {
      if (silent && _fundingInvestors.isNotEmpty) return;

      emit(
        TransactionHistoryFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isFundingInvestorsRequestInFlight = false;
    }
  }
}
