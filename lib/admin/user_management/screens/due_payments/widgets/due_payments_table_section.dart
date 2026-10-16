import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/payment_details_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/send_reminder_preview_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_list_toolbar.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';

class DuePaymentsTableSection extends StatefulWidget {
  const DuePaymentsTableSection({
    super.key,
    required this.users,
  });

  final List<ManagedUserModel> users;

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
  String _query = '';
  DuePaymentsStatusFilter _filter = DuePaymentsStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ManagedUserModel> get _filteredUsers {
    final query = _query.trim().toLowerCase();

    return widget.users.where((user) {
      final matchesFilter = switch (_filter) {
        DuePaymentsStatusFilter.all => true,
        DuePaymentsStatusFilter.pending =>
          user.paymentStatus == UserPaymentStatus.pending,
        DuePaymentsStatusFilter.partiallyPaid =>
          user.paymentStatus == UserPaymentStatus.partiallyPaid,
        DuePaymentsStatusFilter.fullyPaid =>
          user.paymentStatus == UserPaymentStatus.fullyPaid,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return user.userId.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.contains(query) ||
          user.paymentStatusLabel.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _sendReminder(ManagedUserModel user) async {
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

  Future<void> _viewDetails(ManagedUserModel user) {
    return showPaymentDetailsDialog(context: context, user: user);
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserManagementListToolbar(
            title: 'Payment Status',
            searchController: _searchController,
            searchHint: 'Search by ID, name, email, phone...',
            onSearchChanged: (value) => setState(() => _query = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            filters: _filters,
            selectedFilterIndex: _filter.index,
            onFilterSelected: (index) {
              setState(() {
                _filter = DuePaymentsStatusFilter.values[index];
              });
            },
          ),
          const SizedBox(height: 14),
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
            rowCount: users.length,
            emptyMessage: _query.trim().isEmpty &&
                    _filter == DuePaymentsStatusFilter.all
                ? 'No payment records found'
                : 'No users match your search or filter',
            rowBuilder: (context, index) {
              final user = users[index];
              return _DuePaymentRow(
                index: index,
                user: user,
                onSendReminder: user.hasPendingDues
                    ? () => _sendReminder(user)
                    : null,
                onViewDetails: () => _viewDetails(user),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DuePaymentRow extends StatelessWidget {
  const _DuePaymentRow({
    required this.index,
    required this.user,
    required this.onSendReminder,
    required this.onViewDetails,
  });

  final int index;
  final ManagedUserModel user;
  final VoidCallback? onSendReminder;
  final VoidCallback onViewDetails;

  UserManagementBadgeTone get _tone {
    switch (user.paymentStatus) {
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

    return ColoredBox(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              UserManagementDataCell(user.userId, flex: 2),
              UserManagementDataCell(user.name, flex: 3),
              UserManagementDataCell(user.email, flex: 3),
              UserManagementDataCell(user.phoneNumber, flex: 2),
              UserManagementDataCell(
                CurrencyFormatter.format(user.totalPayable),
                flex: 2,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(user.amountPaid),
                flex: 2,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(user.outstandingBalance),
                flex: 2,
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: UserManagementStatusBadge(
                    label: user.paymentStatusLabel,
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
                        tooltip: user.hasPendingDues
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
