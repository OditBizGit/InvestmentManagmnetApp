import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/funding_investor_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/repository/create_project_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

part 'funding_payments_state.dart';

class FundingPaymentsCubit extends Cubit<FundingPaymentsState> {
  FundingPaymentsCubit({
    required InvestorsRepository investorsRepository,
    required InvestorPaymentRepository paymentRepository,
    required ProjectRepository projectRepository,
  })  : _investorsRepository = investorsRepository,
        _paymentRepository = paymentRepository,
        _projectRepository = projectRepository,
        super(FundingPaymentsInitial());

  final InvestorsRepository _investorsRepository;
  final InvestorPaymentRepository _paymentRepository;
  final ProjectRepository _projectRepository;

  List<InvestorModel> _investors = [];
  List<FundingInvestorModel> _fundingInvestors = [];
  InvestorDetailsModel? _investorDetails;
  double? _projectTotalFund;
  bool _isFundingInvestorsRequestInFlight = false;

  List<InvestorModel> get investors => _investors;

  List<FundingInvestorModel> get fundingInvestors => _fundingInvestors;

  InvestorDetailsModel? get investorDetails => _investorDetails;

  /// Project funding goal (Total Fund) from the live project, if available.
  double? get projectTotalFund => _projectTotalFund;

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
      emit(
        FundingInvestorsFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to load investors'),
        ),
      );
    } catch (e) {
      emit(
        FundingInvestorsFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to load investors'),
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
      emit(
        AddPaymentFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to add payment'),
        ),
      );
    } catch (e) {
      emit(
        AddPaymentFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to add payment'),
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
      emit(
        InvestorDetailsFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to load investor details',
          ),
        ),
      );
    } catch (e) {
      emit(
        InvestorDetailsFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to load investor details',
          ),
        ),
      );
    }
  }

  void clearInvestorDetails() {
    _investorDetails = null;
  }

  Future<void> _refreshProjectTotalFund() async {
    try {
      final response = await _projectRepository.getProjects();
      if (response == null) return;

      final projects = response.data;
      if (projects.isEmpty) {
        _projectTotalFund = null;
        return;
      }

      final fund = projects.first.totalFund;
      _projectTotalFund = fund > 0 ? fund : null;
    } catch (_) {
      // Keep the last known project fund if refresh fails.
    }
  }

  Future<void> _loadFundingInvestors({required bool silent}) async {
    if (_isFundingInvestorsRequestInFlight) return;
    _isFundingInvestorsRequestInFlight = true;

    try {
      final fundingFuture = _paymentRepository.getFundingInvestors();
      await Future.wait([
        fundingFuture,
        _refreshProjectTotalFund(),
      ]);
      final response = await fundingFuture;

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
            projectTotalFund: _projectTotalFund,
          ),
        );
        return;
      }

      emit(
        TransactionHistorySuccess(
          List<FundingInvestorModel>.unmodifiable(_fundingInvestors),
          projectTotalFund: _projectTotalFund,
        ),
      );
    } on DioException catch (e) {
      if (silent && _fundingInvestors.isNotEmpty) return;

      emit(
        TransactionHistoryFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to load investors'),
        ),
      );
    } catch (e) {
      if (silent && _fundingInvestors.isNotEmpty) return;

      emit(
        TransactionHistoryFailure(
          ApiErrorMessage.from(e, fallback: 'Failed to load investors'),
        ),
      );
    } finally {
      _isFundingInvestorsRequestInFlight = false;
    }
  }
}
