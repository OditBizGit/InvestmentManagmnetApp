import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/cubit/due_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/model/payment_status_report_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/payment_details_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/send_reminder_preview_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_list_toolbar.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class DuePaymentsTableSection extends StatefulWidget {
  const DuePaymentsTableSection({super.key});

  @override
  State<DuePaymentsTableSection> createState() =>
      _DuePaymentsTableSectionState();
}

class _DuePaymentsTableSectionState extends State<DuePaymentsTableSection> {
  static const double _minTableWidth = 1180;
  static const _filters = [
    'All',
    'Pending',
    'Partially Paid',
    'Fully Paid',
  ];

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  DuePaymentsStatusFilter _filter = DuePaymentsStatusFilter.all;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _fetch({DuePaymentsStatusFilter? filter, String? search}) {
    context.read<DuePaymentsCubit>().fetchPaymentStatusReport(
          statusFilter: filter,
          search: search,
        );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetch(search: value);
    });
  }

  Future<void> _sendReminder(PaymentStatusReportModel item) async {
    final user = item.toManagedUser();
    final sent = await showSendReminderPreviewDialog(
      context: context,
      user: user,
    );
    if (!sent || !mounted) return;
    AppToast.success(
      'Reminder preview queued for ${user.name}',
      title: 'Reminder (dummy)',
      context: context,
    );
  }

  Future<void> _viewDetails(PaymentStatusReportModel item) {
    return showPaymentDetailsDialog(
      context: context,
      user: item.toManagedUser(),
    );
  }

  String _emptyMessage(DuePaymentsState state) {
    final search = switch (state) {
      DuePaymentsSuccess(:final search) => search,
      DuePaymentsEmpty(:final search) => search,
      DuePaymentsFailure(:final search) => search,
      _ => '',
    };
    final filter = switch (state) {
      DuePaymentsSuccess(:final statusFilter) => statusFilter,
      DuePaymentsEmpty(:final statusFilter) => statusFilter,
      DuePaymentsFailure(:final statusFilter) => statusFilter,
      _ => _filter,
    };

    if (search.trim().isEmpty && filter == DuePaymentsStatusFilter.all) {
      return 'No payment records found';
    }
    return 'No users match your search or filter';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DuePaymentsCubit, DuePaymentsState>(
      listenWhen: (previous, current) => current is DuePaymentsFailure,
      listener: (context, state) {
        if (state is! DuePaymentsFailure) return;
        AppToast.error(
          state.message,
          title: 'Could not load payments',
          context: context,
        );
      },
      builder: (context, state) {
        final activeFilter = switch (state) {
          DuePaymentsSuccess(:final statusFilter) => statusFilter,
          DuePaymentsEmpty(:final statusFilter) => statusFilter,
          DuePaymentsFailure(:final statusFilter) => statusFilter,
          _ => _filter,
        };

        final items = switch (state) {
          DuePaymentsSuccess(:final items) => items,
          DuePaymentsEmpty() => const <PaymentStatusReportModel>[],
          _ => const <PaymentStatusReportModel>[],
        };

        final isTableLoading = state is DuePaymentsInitial ||
            state is DuePaymentsLoading ||
            (state is DuePaymentsSuccess && state.isTableLoading) ||
            (state is DuePaymentsEmpty && state.isTableLoading);
        final failure = state is DuePaymentsFailure ? state : null;
        final showErrorPanel = failure != null && !isTableLoading;
        final showTable = (state is DuePaymentsSuccess ||
                state is DuePaymentsEmpty) &&
            !isTableLoading;

        return UserManagementTableCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserManagementListToolbar(
                title: 'Payment Status',
                searchController: _searchController,
                searchHint: 'Search by ID, name, email, phone...',
                onSearchChanged: _onSearchChanged,
                onClearSearch: () {
                  _searchController.clear();
                  _searchDebounce?.cancel();
                  _fetch(search: '');
                },
                filters: _filters,
                selectedFilterIndex: activeFilter.index,
                onFilterSelected: (index) {
                  final filter = DuePaymentsStatusFilter.values[index];
                  setState(() => _filter = filter);
                  _fetch(filter: filter, search: _searchController.text);
                },
              ),
              const SizedBox(height: 14),
              if (isTableLoading)
                const _DuePaymentsTableLoading()
              else if (showErrorPanel)
                _DuePaymentsTableErrorPanel(
                  message: failure.message,
                  onRetry: () => _fetch(
                        filter: failure.statusFilter,
                        search: failure.search,
                      ),
                )
              else if (showTable)
                UserManagementTableFrame(
                  minTableWidth: _minTableWidth,
                  header: const UserManagementHeaderRow(
                    children: [
                      UserManagementHeaderCell('User ID', flex: 2),
                      UserManagementHeaderCell('Name', flex: 3),
                      UserManagementHeaderCell('Email', flex: 3),
                      UserManagementHeaderCell('Phone Number', flex: 2),
                      UserManagementHeaderCell('Total Payable', flex: 2),
                      UserManagementHeaderCell('Amount Paid', flex: 2),
                      UserManagementHeaderCell('Outstanding', flex: 2),
                      UserManagementHeaderCell('Payment Status', flex: 2),
                      UserManagementHeaderCell(
                        'Actions',
                        flex: 2,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  rowCount: items.length,
                  emptyMessage: _emptyMessage(state),
                  rowBuilder: (context, index) {
                    final item = items[index];
                    final hasPendingDues = item.outstanding > 0.01;
                    return _DuePaymentRow(
                      index: index,
                      item: item,
                      onSendReminder: hasPendingDues
                          ? () => _sendReminder(item)
                          : null,
                      onViewDetails: () => _viewDetails(item),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DuePaymentsTableLoading extends StatelessWidget {
  const _DuePaymentsTableLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading payment status...',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuePaymentsTableErrorPanel extends StatelessWidget {
  const _DuePaymentsTableErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
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
    );
  }
}

class _DuePaymentRow extends StatelessWidget {
  const _DuePaymentRow({
    required this.index,
    required this.item,
    required this.onSendReminder,
    required this.onViewDetails,
  });

  final int index;
  final PaymentStatusReportModel item;
  final VoidCallback? onSendReminder;
  final VoidCallback onViewDetails;

  UserManagementBadgeTone get _tone {
    switch (item.normalizedPaymentStatus) {
      case UserPaymentStatus.fullyPaid:
        return UserManagementBadgeTone.success;
      case UserPaymentStatus.partiallyPaid:
        return UserManagementBadgeTone.warning;
      case UserPaymentStatus.pending:
        return UserManagementBadgeTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;
    final displayUserId =
        item.investorCode.isNotEmpty ? item.investorCode : '${item.userId}';

    return ColoredBox(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              UserManagementDataCell(displayUserId, flex: 2),
              UserManagementDataCell(item.name, flex: 3),
              UserManagementDataCell(item.email, flex: 3),
              UserManagementDataCell(item.phoneNumber, flex: 2),
              UserManagementDataCell(
                CurrencyFormatter.format(item.totalPayable),
                flex: 2,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(item.amountPaid),
                flex: 2,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(item.outstanding),
                flex: 2,
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: UserManagementStatusBadge(
                    label: item.paymentStatusLabel,
                    tone: _tone,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: onSendReminder != null
                            ? 'Send reminder'
                            : 'No outstanding dues',
                        onPressed: onSendReminder,
                        icon: Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: onSendReminder == null
                              ? AppColors.textMuted
                              : AppColors.accent,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                      IconButton(
                        tooltip: 'View details',
                        onPressed: onViewDetails,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
