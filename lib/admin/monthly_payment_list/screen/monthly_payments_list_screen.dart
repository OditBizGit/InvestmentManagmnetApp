import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/cubit/payment_list_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/model/monthly_payment_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/repository/monthly_payment_list_repository.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/montly_payment_overview.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/montly_payment_table.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/payment_verification_history_screen.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/reject_payment_verification_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_nav_permissions.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class MonthlyPaymentListScreen extends StatelessWidget {
  const MonthlyPaymentListScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final role = getIt<LocalStorage>().getUserRole();
    if (!AdminNavPermissions.canAccessMonthlyList(role)) {
      return const _MonthlyPaymentListAccessDenied();
    }

    return RepositoryProvider(
      create: (_) => MonthlyPaymentListRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => PaymentListCubit(
          repository: context.read<MonthlyPaymentListRepository>(),
        ),
        child: _MonthlyPaymentListView(isActive: isActive),
      ),
    );
  }
}

class _MonthlyPaymentListView extends StatefulWidget {
  const _MonthlyPaymentListView({required this.isActive});

  final bool isActive;

  @override
  State<_MonthlyPaymentListView> createState() =>
      _MonthlyPaymentListViewState();
}

class _MonthlyPaymentListViewState extends State<_MonthlyPaymentListView> {
  final TextEditingController _searchController = TextEditingController();

  late DateTime _fromDate;
  late DateTime _toDate;

  final Map<int, PaymentReviewIntent> _reviewIntents = {};

  MonthlyPaymentListDataModel? _lastLoadedData;
  bool _showVerificationHistory = false;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
    _refreshIfActive();
  }

  @override
  void didUpdateWidget(covariant _MonthlyPaymentListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      _fetchPayments();
    });
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month, now.day);
  }

  DateTime get _fetchFromDate => DateTime(
        _fromDate.year,
        _fromDate.month,
        _fromDate.day,
      );

  DateTime get _fetchToDate => DateTime(
        _toDate.year,
        _toDate.month,
        _toDate.day,
      );

  void _fetchPayments() {
    context.read<PaymentListCubit>().fetchMonthlyPaymentList(
          fromDate: _fetchFromDate,
          toDate: _fetchToDate,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PaymentStatus _parsePaymentStatus(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.contains('reject')) {
      return PaymentStatus.rejected;
    }
    if (normalized.contains('approv')) {
      return PaymentStatus.approved;
    }
    return PaymentStatus.pending;
  }

  List<MonthlyPayment> _mapTransactions(
    List<MonthlyPaymentTransactionModel> transactions,
  ) {
    return transactions.map((transaction) {
      final paidOn = transaction.paymentDate ??
          DateTime(
            _fetchFromDate.year,
            _fetchFromDate.month,
            _fetchFromDate.day,
          );

      return MonthlyPayment(
        id: transaction.transactionId,
        investorName: transaction.investorName,
        investorCode: transaction.investorCode,
        contact: transaction.mobileNumber,
        staff: transaction.staffName,
        method: transaction.paymentMethod,
        amount: transaction.paidAmount,
        paidOn: paidOn,
        status: _parsePaymentStatus(transaction.paymentStatus),
      );
    }).toList();
  }

  List<MonthlyPayment> _filterBySearch(List<MonthlyPayment> payments) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return payments;

    return payments.where((payment) {
      return payment.investorName.toLowerCase().contains(query) ||
          payment.investorCode.toLowerCase().contains(query) ||
          payment.contact.toLowerCase().contains(query) ||
          payment.staff.toLowerCase().contains(query);
    }).toList();
  }

  void _onFromDateChanged(DateTime? value) {
    setState(() {
      if (value == null) {
        _setDefaultDateRange();
      } else {
        _fromDate = DateTime(value.year, value.month, value.day);
      }
      _reviewIntents.clear();
    });
    _fetchPayments();
  }

  void _onToDateChanged(DateTime? value) {
    setState(() {
      if (value == null) {
        _setDefaultDateRange();
      } else {
        _toDate = DateTime(value.year, value.month, value.day);
      }
      _reviewIntents.clear();
    });
    _fetchPayments();
  }

  void _setApproveIntent(int id, bool selected) {
    setState(() {
      if (selected) {
        _reviewIntents[id] = PaymentReviewIntent.approve;
      } else {
        _reviewIntents.remove(id);
      }
    });
  }

  void _setRejectIntent(int id, bool selected) {
    setState(() {
      if (selected) {
        _reviewIntents[id] = PaymentReviewIntent.reject;
      } else {
        _reviewIntents.remove(id);
      }
    });
  }

  Future<void> _onSaveRow(
    int id, {
    required List<MonthlyPayment> payments,
  }) async {
    final intent = _reviewIntents[id];
    if (intent == null) return;

    final cubit = context.read<PaymentListCubit>();

    if (intent == PaymentReviewIntent.reject) {
      MonthlyPayment? payment;
      for (final item in payments) {
        if (item.id == id) {
          payment = item;
          break;
        }
      }

      final remarks = await showRejectPaymentVerificationDialog(
        context: context,
        investorName: payment?.investorName,
        transactionId: id,
      );
      if (!mounted || remarks == null) return;

      await cubit.reviewPaymentVerification(
        transactionId: id,
        status: 'Rejected',
        remarks: remarks,
      );
      return;
    }

    await cubit.reviewPaymentVerification(
      transactionId: id,
      status: 'Approved',
      remarks: '',
    );
  }

  void _selectAllApprove(
    List<MonthlyPayment> pendingPayments,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        for (final payment in pendingPayments) {
          _reviewIntents[payment.id] = PaymentReviewIntent.approve;
        }
      } else {
        for (final payment in pendingPayments) {
          _reviewIntents.remove(payment.id);
        }
      }
    });
  }

  Future<void> _onApproveAll(List<MonthlyPayment> filteredPayments) async {
    final pending = filteredPayments
        .where((payment) => payment.status == PaymentStatus.pending)
        .toList();

    if (pending.isEmpty) {
      AppToast.error(
        'No pending payments to approve.',
        title: 'Approve All',
        context: context,
      );
      return;
    }

    final hasRejectSelection = pending.any(
      (payment) =>
          _reviewIntents[payment.id] == PaymentReviewIntent.reject,
    );

    if (hasRejectSelection) {
      AppToast.error(
        'Clear reject selections before using Approve All.',
        title: 'Cannot approve all',
        context: context,
      );
      return;
    }

    setState(() {
      for (final payment in pending) {
        _reviewIntents[payment.id] = PaymentReviewIntent.approve;
      }
    });

    final transactionIds = pending.map((payment) => payment.id).toList();
    await context.read<PaymentListCubit>().approvePaymentsBatch(
          transactionIds: transactionIds,
        );
  }

  void _openVerificationHistory() {
    setState(() => _showVerificationHistory = true);
  }

  void _backFromVerificationHistory() {
    setState(() => _showVerificationHistory = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showVerificationHistory) {
      return PaymentVerificationHistoryScreen(
        onBack: _backFromVerificationHistory,
      );
    }

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<PaymentListCubit, PaymentListState>(
            listenWhen: (previous, current) {
              if (current is! PaymentListLoaded) return false;
              if (previous is! PaymentListLoaded) return true;
              return previous.data != current.data ||
                  previous.actionMessage != current.actionMessage;
            },
            listener: (context, state) {
              if (state is! PaymentListLoaded) return;

              _lastLoadedData = state.data;

              final message = state.actionMessage;
              if (message == null || message.isEmpty) return;

              if (state.actionIsSuccess) {
                AppToast.success(message, context: context);
                setState(() => _reviewIntents.clear());
              } else {
                AppToast.error(message, context: context);
              }
              context.read<PaymentListCubit>().clearActionFeedback();
            },
            builder: (context, state) {
              final isLoading = state is PaymentListLoading;
              final isError = state is PaymentListError;
              final loaded =
                  state is PaymentListLoaded ? state : null;

              MonthlyPaymentListDataModel? data;
              String? errorMessage;

              if (loaded != null) {
                data = loaded.data;
              } else if (state is PaymentListError) {
                errorMessage = state.message;
                data = _lastLoadedData;
              } else if (isLoading) {
                data = _lastLoadedData;
              }

              final showTopProgress = data != null &&
                  (isLoading ||
                      (loaded?.isListRefreshing ?? false) ||
                      (loaded?.isReviewSubmitting ?? false));

              return AdminMainScreenLayout(
                horizontalPadding: horizontalPadding,
                showRefetchProgress: showTopProgress,
                body: _buildBody(
                  horizontalPadding: horizontalPadding,
                  isLoading: isLoading,
                  isError: isError,
                  errorMessage: errorMessage,
                  data: data,
                  isReviewSubmitting: loaded?.isReviewSubmitting ?? false,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required double horizontalPadding,
    required bool isLoading,
    required bool isError,
    required String? errorMessage,
    required MonthlyPaymentListDataModel? data,
    required bool isReviewSubmitting,
  }) {
    final allPayments = data != null
        ? _mapTransactions(data.transactions)
        : <MonthlyPayment>[];

    final filteredPayments = _filterBySearch(allPayments);

    final pendingCount =
        allPayments.where((p) => p.status == PaymentStatus.pending).length;
    final approvedCount =
        allPayments.where((p) => p.status == PaymentStatus.approved).length;
    final rejectedCount =
        allPayments.where((p) => p.status == PaymentStatus.rejected).length;

    final totalPayments = data?.totalPayments ?? 0;
    final totalAmount = data?.totalAmount ?? 0.0;

    if (isLoading && data == null && !isError) {
      return const AdminInitialLoadingBody();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthlyPaymentOverview(
            totalPayments: totalPayments,
            totalAmount: totalAmount,
            pendingCount: pendingCount,
            approvedCount: approvedCount,
            rejectedCount: rejectedCount,
          ),
          const SizedBox(height: 20),
          if (isError && errorMessage != null)
            _MonthlyPaymentListError(
              message: errorMessage,
              onRetry: _fetchPayments,
            )
          else
            MonthlyPaymentTable(
              payments: filteredPayments,
              reviewIntents: _reviewIntents,
              searchController: _searchController,
              fromDate: _fromDate,
              toDate: _toDate,
              onSearchChanged: (_) => setState(() {}),
              onClearSearch: () {
                _searchController.clear();
                setState(() {});
              },
              onFromDateChanged: _onFromDateChanged,
              onToDateChanged: _onToDateChanged,
              onApproveIntentChanged: _setApproveIntent,
              onRejectIntentChanged: _setRejectIntent,
              onSaveRow: (id) => _onSaveRow(
                    id,
                    payments: filteredPayments,
                  ),
              onSelectAllApproveChanged: (selected) {
                final pending = filteredPayments
                    .where((p) => p.status == PaymentStatus.pending)
                    .toList();
                _selectAllApprove(pending, selected);
              },
              onApproveAll: () => _onApproveAll(filteredPayments),
              onViewHistory: _openVerificationHistory,
              isReviewSubmitting: isReviewSubmitting,
            ),
        ],
      ),
    );
  }
}

class _MonthlyPaymentListError extends StatelessWidget {
  const _MonthlyPaymentListError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyPaymentListAccessDenied extends StatelessWidget {
  const _MonthlyPaymentListAccessDenied();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'Access restricted',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monthly List is not available for your account role.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
