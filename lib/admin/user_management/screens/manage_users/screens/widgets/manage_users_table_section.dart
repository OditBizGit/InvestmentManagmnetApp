import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_list_toolbar.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class ManageUsersTableSection extends StatefulWidget {
  const ManageUsersTableSection({
    super.key,
    required this.onToggleBlock,
    required this.onUserTap,
  });

  final ValueChanged<ManageUsersInvestor> onToggleBlock;
  final ValueChanged<ManageUsersInvestor> onUserTap;

  @override
  State<ManageUsersTableSection> createState() =>
      _ManageUsersTableSectionState();
}

class _ManageUsersTableSectionState extends State<ManageUsersTableSection> {
  static const double _minTableWidth = 1040;
  static const _filters = [
    'All',
    'Active',
    'Blocked',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  ManageUsersStatusFilter _filter = ManageUsersStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ManageUsersInvestor> _filteredUsers(List<ManageUsersInvestor> users) {
    final query = _query.trim().toLowerCase();

    return users.where((user) {
      final matchesFilter = switch (_filter) {
        ManageUsersStatusFilter.all => true,
        ManageUsersStatusFilter.active => !user.isBlocked,
        ManageUsersStatusFilter.blocked => user.isBlocked,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return user.userId.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.toLowerCase().contains(query) ||
          user.accountStatusLabel.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _confirmTerminate(ManageUsersInvestor user) async {
    // Unblock is disabled — only allow terminate for active users.
    if (user.isBlocked) return;

    final confirmed = await showUserManagementConfirmDialog(
      context: context,
      title: 'Terminate user?',
      message:
          'This action will not be undone. Are you sure you want to continue terminating ${user.name}?',
      confirmLabel: 'Terminate',
      confirmColor: AppColors.error,
    );
    if (!confirmed || !mounted) return;
    widget.onToggleBlock(user);
  }

  Future<void> _handleExportSelected(
    UserManagementExportFormat format,
    UserManagementExportScope scope,
    DateTimeRange range,
  ) async {
    final fromDate = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final toDate = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
      999,
    );

    final section = scope == UserManagementExportScope.dues ? 'due' : 'all';
    final result = await context.read<ManageUsersCubit>().exportInvestorPaymentReport(
          asPdf: format == UserManagementExportFormat.pdf,
          section: section,
          fromDate: fromDate,
          toDate: toDate,
        );
    if (!mounted) return;

    if (result.success) {
      AppToast.success(
        result.message,
        title: 'Export ready',
        context: context,
      );
    } else {
      AppToast.error(
        result.message,
        title: 'Export failed',
        context: context,
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageUsersCubit, ManageUsersState>(
      builder: (context, state) {
        final isTableLoading = state is ManageUsersInitial ||
            state is ManageUsersLoading ||
            (state is ManageUsersSuccess && state.isTableLoading) ||
            (state is ManageUsersEmpty && state.isTableLoading);

        final users = switch (state) {
          ManageUsersSuccess(:final users) => users,
          ManageUsersEmpty() => const <ManageUsersInvestor>[],
          _ => const <ManageUsersInvestor>[],
        };

        final statusUpdatingUserId = state is ManageUsersSuccess
            ? state.statusUpdatingUserId
            : null;

        final isExporting = switch (state) {
          ManageUsersSuccess(:final isExporting) => isExporting,
          ManageUsersEmpty(:final isExporting) => isExporting,
          ManageUsersFailure(:final isExporting) => isExporting,
          _ => false,
        };

        final filteredUsers = _filteredUsers(users);
        final failure = state is ManageUsersFailure ? state : null;
        final showErrorPanel = failure != null && !isTableLoading;
        final showTable = (state is ManageUsersSuccess ||
                state is ManageUsersEmpty) &&
            !isTableLoading;

        return UserManagementTableCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserManagementListToolbar(
                title: 'All Investors',
                searchController: _searchController,
                searchHint: 'Search by name, mobile, email...',
                onSearchChanged: (value) => setState(() => _query = value),
                onClearSearch: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                filters: _filters,
                selectedFilterIndex: _filter.index,
                onFilterSelected: (index) {
                  setState(() {
                    _filter = ManageUsersStatusFilter.values[index];
                  });
                },
                trailing: UserManagementExportIcons(
                  isExporting: isExporting,
                  onExportSelected: _handleExportSelected,
                ),
              ),
              if (isExporting) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    color: AppColors.accent,
                    backgroundColor: Color(0xFFE8E6EC),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (isTableLoading)
                const _ManageUsersTableLoading()
              else if (showErrorPanel)
                _ManageUsersTableErrorPanel(
                  message: failure.message,
                  onRetry: () =>
                      context.read<ManageUsersCubit>().fetchUsers(),
                )
              else if (showTable)
                UserManagementTableFrame(
                  minTableWidth: _minTableWidth,
                  header: const UserManagementHeaderRow(
                    children: [
                      UserManagementHeaderCell('#', flex: 1),
                      UserManagementHeaderCell('Investor Name', flex: 4),
                      UserManagementHeaderCell('Mobile No', flex: 3),
                      UserManagementHeaderCell('Email', flex: 3),
                      UserManagementHeaderCell('Committed Amt', flex: 2),
                      UserManagementHeaderCell('Paid Amt', flex: 2),
                      UserManagementHeaderCell('Status', flex: 2),
                      UserManagementHeaderCell('Joined Date', flex: 2),
                      UserManagementHeaderCell(
                        'Action',
                        flex: 2,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  rowCount: filteredUsers.length,
                  emptyMessage: _query.trim().isEmpty &&
                          _filter == ManageUsersStatusFilter.all
                      ? 'No investors found'
                      : 'No investors match your search or filter',
                  rowBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _ManageUserRow(
                      index: index,
                      user: user,
                      joinedDate: _formatDate(user.joinedDate),
                      isUpdating: statusUpdatingUserId == user.id,
                      onTap: () => widget.onUserTap(user),
                      onToggleBlock: () => _confirmTerminate(user),
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

class _ManageUsersTableLoading extends StatelessWidget {
  const _ManageUsersTableLoading();

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
              'Loading users...',
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

class _ManageUsersTableErrorPanel extends StatelessWidget {
  const _ManageUsersTableErrorPanel({
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

String _displayOrNA(String value) {
  final text = value.trim();
  return text.isEmpty ? 'N/A' : text;
}

class _ManageUserRow extends StatelessWidget {
  const _ManageUserRow({
    required this.index,
    required this.user,
    required this.joinedDate,
    required this.isUpdating,
    required this.onTap,
    required this.onToggleBlock,
  });

  final int index;
  final ManageUsersInvestor user;
  final String joinedDate;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback onToggleBlock;

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;

    return Material(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                UserManagementDataCell('${index + 1}', flex: 1),
                UserManagementDataCell(_displayOrNA(user.name), flex: 4),
                UserManagementDataCell(_displayOrNA(user.phoneNumber), flex: 3),
                UserManagementDataCell(_displayOrNA(user.email), flex: 3),
                UserManagementDataCell(
                  CurrencyFormatter.format(user.totalPayable),
                  flex: 2,
                ),
                UserManagementDataCell(
                  CurrencyFormatter.format(user.amountPaid),
                  flex: 2,
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: UserManagementStatusBadge(
                      label: user.accountStatusLabel,
                      tone: user.isBlocked
                          ? UserManagementBadgeTone.danger
                          : UserManagementBadgeTone.success,
                    ),
                  ),
                ),
                UserManagementDataCell(joinedDate, flex: 2),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: isUpdating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          )
                        // Unblock option removed — terminated users have no action.
                        : user.isBlocked
                            ? Text(
                                'Terminated',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              )
                            : TextButton(
                                onPressed: onToggleBlock,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  minimumSize: const Size(0, 34),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Terminate',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
