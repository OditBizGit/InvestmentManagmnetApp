import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_transaction_history_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

part 'funding_payments_state.dart';

class FundingPaymentsCubit extends Cubit<FundingPaymentsState> {
  FundingPaymentsCubit({
    required InvestorsRepository investorsRepository,
    required InvestorPaymentRepository paymentRepository,
    required LocalStorage localStorage,
  })  : _investorsRepository = investorsRepository,
        _paymentRepository = paymentRepository,
        _localStorage = localStorage,
        super(FundingPaymentsInitial());

  final InvestorsRepository _investorsRepository;
  final InvestorPaymentRepository _paymentRepository;
  final LocalStorage _localStorage;

  List<InvestorModel> _investors = [];
  List<InvestorTransactionHistoryModel> _transactionHistory = [];
  bool _isTransactionHistoryRequestInFlight = false;

  List<InvestorModel> get investors => _investors;

  List<InvestorTransactionHistoryModel> get transactionHistory =>
      _transactionHistory;

  bool get hasTransactionHistory => _transactionHistory.isNotEmpty;

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

  /// First load / explicit reload.
  /// Shows a full loading state only when no in-memory or cached data exists.
  Future<void> fetchAllInvestorTransactionHistory() async {
    if (_transactionHistory.isEmpty) {
      final cached = _readCachedTransactionHistory();
      if (cached != null && cached.isNotEmpty) {
        _transactionHistory = cached;
        emit(TransactionHistorySuccess(List.unmodifiable(cached)));
      } else {
        emit(TransactionHistoryLoading());
      }
    }

    await _loadTransactionHistory(
      silent: _transactionHistory.isNotEmpty,
    );
  }

  /// Refreshes from API without emitting [TransactionHistoryLoading],
  /// so existing list UI stays visible.
  Future<void> refreshSilently() async {
    await _loadTransactionHistory(silent: true);
  }

  Future<void> _loadTransactionHistory({required bool silent}) async {
    if (_isTransactionHistoryRequestInFlight) return;
    _isTransactionHistoryRequestInFlight = true;

    try {
      final response =
          await _paymentRepository.getAllInvestorTransactionHistory();

      final hasData = response.data.isNotEmpty;
      final looksSuccessful = response.status ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        if (!silent || _transactionHistory.isEmpty) {
          emit(
            TransactionHistoryFailure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load transaction history',
            ),
          );
        }
        return;
      }

      _transactionHistory = response.data;
      await _cacheTransactionHistory(_transactionHistory);

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

      emit(
        TransactionHistorySuccess(
          List.unmodifiable(_transactionHistory),
        ),
      );
    } on DioException catch (e) {
      if (silent && _transactionHistory.isNotEmpty) return;

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
      if (silent && _transactionHistory.isNotEmpty) return;

      emit(
        TransactionHistoryFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isTransactionHistoryRequestInFlight = false;
    }
  }

  List<InvestorTransactionHistoryModel>? _readCachedTransactionHistory() {
    final raw = _localStorage.getFundingTransactionHistoryJson();
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      final parsed = <InvestorTransactionHistoryModel>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            parsed.add(
              InvestorTransactionHistoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Skip malformed cache rows.
          }
        }
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheTransactionHistory(
    List<InvestorTransactionHistoryModel> transactions,
  ) async {
    try {
      final payload = jsonEncode(
        transactions.map((item) => item.toJson()).toList(),
      );
      await _localStorage.setFundingTransactionHistoryJson(payload);
    } catch (_) {
      // Cache write failures should not break the UI flow.
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
