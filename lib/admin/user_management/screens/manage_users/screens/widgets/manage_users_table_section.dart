import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_list_toolbar.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class ManageUsersTableSection extends StatefulWidget {
  const ManageUsersTableSection({
    super.key,
    required this.users,
    required this.onToggleBlock,
    required this.onUserTap,
    this.statusUpdatingUserId,
  });

  final List<ManageUsersInvestor> users;
  final ValueChanged<ManageUsersInvestor> onToggleBlock;
  final ValueChanged<ManageUsersInvestor> onUserTap;
  final int? statusUpdatingUserId;

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

  List<ManageUsersInvestor> get _filteredUsers {
    final query = _query.trim().toLowerCase();

    return widget.users.where((user) {
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

  Future<void> _confirmToggle(ManageUsersInvestor user) async {
    final blocking = !user.isBlocked;
    final confirmed = await showUserManagementConfirmDialog(
      context: context,
      title: blocking ? 'Block user?' : 'Unblock user?',
      message: blocking
          ? 'Block ${user.name}? They will not be able to access their account.'
          : 'Unblock ${user.name}? They will regain access to their account.',
      confirmLabel: blocking ? 'Block' : 'Unblock',
      confirmColor: blocking ? AppColors.error : AppColors.green,
    );
    if (!confirmed || !mounted) return;
    widget.onToggleBlock(user);
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
    final users = _filteredUsers;

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
          ),
          const SizedBox(height: 14),
          UserManagementTableFrame(
            minTableWidth: _minTableWidth,
            header: const UserManagementHeaderRow(
              children: [
                UserManagementHeaderCell('#', flex: 1),
                UserManagementHeaderCell('Investor Name', flex: 4),
                UserManagementHeaderCell('Mobile No', flex: 3),
                UserManagementHeaderCell('Email', flex: 3),
                UserManagementHeaderCell('Invest Amt', flex: 2),
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
            rowCount: users.length,
            emptyMessage: _query.trim().isEmpty &&
                    _filter == ManageUsersStatusFilter.all
                ? 'No investors found'
                : 'No investors match your search or filter',
            rowBuilder: (context, index) {
              final user = users[index];
              return _ManageUserRow(
                index: index,
                user: user,
                joinedDate: _formatDate(user.joinedDate),
                isUpdating: widget.statusUpdatingUserId == user.id,
                onTap: () => widget.onUserTap(user),
                onToggleBlock: () => _confirmToggle(user),
              );
            },
          ),
        ],
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
                        : TextButton(
                            onPressed: onToggleBlock,
                            style: TextButton.styleFrom(
                              foregroundColor: user.isBlocked
                                  ? AppColors.green
                                  : AppColors.error,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 34),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              user.isBlocked ? 'Unblock' : 'Block',
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
