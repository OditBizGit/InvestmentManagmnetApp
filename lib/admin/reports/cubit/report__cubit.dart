import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_transaction_history_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/model/funding_payment_overview_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/model/investor_type_count_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/repository/report_repository.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';

part 'report__state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit({
    required AddPhaseRepository phaseRepository,
    required InvestorPaymentRepository paymentRepository,
    required ReportRepository overviewRepository,
  })  : _phaseRepository = phaseRepository,
        _paymentRepository = paymentRepository,
        _overviewRepository = overviewRepository,
        super(const ReportState());

  final AddPhaseRepository _phaseRepository;
  final InvestorPaymentRepository _paymentRepository;
  final ReportRepository _overviewRepository;

  String? _overviewFromDate;
  String? _overviewToDate;

  List<WorkPhaseListModel> get phases => state.phases;
  List<InvestorTransactionHistoryModel> get transactions => state.transactions;
  FundingPaymentOverviewModel? get fundingOverview => state.fundingOverview;
  List<FundingPaymentMonthModel> get fundingOverviewMonths =>
      state.fundingOverviewMonths;
  FundingPaymentSummaryModel? get fundingOverviewSummary =>
      state.fundingOverviewSummary;
  InvestorTypeCountModel? get investorTypeCount => state.investorTypeCount;

  Future<void> loadReports({
    String? overviewFromDate,
    String? overviewToDate,
  }) async {
    final from = overviewFromDate ?? _overviewFromDate;
    final to = overviewToDate ?? _overviewToDate;

    await Future.wait([
      fetchWorkPhaseList(),
      fetchRecentTransactions(),
      fetchInvestorTypeCount(),
      if (from != null && to != null)
        fetchFundingPaymentOverview(fromDate: from, toDate: to),
    ]);
  }

  Future<void> fetchWorkPhaseList() async {
    emit(
      state.copyWith(
        workProgressLoading: true,
        clearWorkProgressError: true,
      ),
    );
    try {
      final result = await _phaseRepository.workPhaseList();
      emit(
        state.copyWith(
          workProgressLoading: false,
          phases: List<WorkPhaseListModel>.unmodifiable(result),
          clearWorkProgressError: true,
        ),
      );
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          workProgressLoading: false,
          workProgressError: message.isNotEmpty
              ? message
              : 'Failed to load work progress',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          workProgressLoading: false,
          workProgressError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> fetchRecentTransactions() async {
    emit(
      state.copyWith(
        transactionsLoading: true,
        clearTransactionsError: true,
      ),
    );
    try {
      final response =
          await _paymentRepository.getAllInvestorTransactionHistory();

      final looksSuccessful = response.status ||
          response.message.toLowerCase().contains('success') ||
          response.data.isNotEmpty;

      if (!looksSuccessful && response.data.isEmpty) {
        emit(
          state.copyWith(
            transactionsLoading: false,
            transactions: const [],
            transactionsError: response.message.isNotEmpty
                ? response.message
                : 'Failed to load recent transactions',
          ),
        );
        return;
      }

      final sorted = List<InvestorTransactionHistoryModel>.from(response.data)
        ..sort((a, b) => b.date.compareTo(a.date));

      emit(
        state.copyWith(
          transactionsLoading: false,
          transactions: List<InvestorTransactionHistoryModel>.unmodifiable(
            sorted,
          ),
          clearTransactionsError: true,
        ),
      );
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          transactionsLoading: false,
          transactionsError: message.isNotEmpty
              ? message
              : 'Failed to load recent transactions',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          transactionsLoading: false,
          transactionsError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> fetchFundingPaymentOverview({
    required String fromDate,
    required String toDate,
  }) async {
    _overviewFromDate = fromDate;
    _overviewToDate = toDate;
    emit(
      state.copyWith(
        fundingOverviewLoading: true,
        clearFundingOverviewError: true,
      ),
    );
    try {
      final result = await _overviewRepository.getFundingPaymentOverview(
        fromDate: fromDate,
        toDate: toDate,
      );
      emit(
        state.copyWith(
          fundingOverviewLoading: false,
          fundingOverview: result,
          clearFundingOverviewError: true,
        ),
      );
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          fundingOverviewLoading: false,
          fundingOverviewError: message.isNotEmpty
              ? message
              : 'Failed to load funding & payments overview',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          fundingOverviewLoading: false,
          fundingOverviewError:
              e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> fetchInvestorTypeCount() async {
    emit(
      state.copyWith(
        investorTypeCountLoading: true,
        clearInvestorTypeCountError: true,
      ),
    );
    try {
      final result = await _overviewRepository.getInvestorTypeCount();
      emit(
        state.copyWith(
          investorTypeCountLoading: false,
          investorTypeCount: result,
          clearInvestorTypeCountError: true,
        ),
      );
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          investorTypeCountLoading: false,
          investorTypeCountError: message.isNotEmpty
              ? message
              : 'Failed to load investor summary',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          investorTypeCountLoading: false,
          investorTypeCountError:
              e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['Message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return e.message ?? '';
  }
}
