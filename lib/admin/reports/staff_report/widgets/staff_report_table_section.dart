import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../model/staff_report_row_model.dart';

enum StaffReportPeriod {
  thisMonth,
  lastMonth,
  thisYear,
  allTime,
}

extension StaffReportPeriodX on StaffReportPeriod {
  String get label => switch (this) {
        StaffReportPeriod.thisMonth => 'This Month',
        StaffReportPeriod.lastMonth => 'Last Month',
        StaffReportPeriod.thisYear => 'This Year',
        StaffReportPeriod.allTime => 'All Time',
      };
}

class StaffReportTableSection extends StatefulWidget {
  const StaffReportTableSection({
    super.key,
    required this.items,
    required this.onViewStaff,
  });

  final List<StaffReportRowModel> items;
  final void Function(StaffReportRowModel staff, StaffReportPeriod period)
      onViewStaff;

  @override
  State<StaffReportTableSection> createState() =>
      _StaffReportTableSectionState();
}

class _StaffReportTableSectionState extends State<StaffReportTableSection> {
  static const double _minTableWidth = 900;

  final TextEditingController _searchController = TextEditingController();
  StaffReportPeriod _period = StaffReportPeriod.thisMonth;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffReportRowModel> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.items;

    return widget.items.where((item) {
      return item.code.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.mobileNumber.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StaffReportToolbar(
            searchController: _searchController,
            period: _period,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onPeriodSelected: (period) {
              setState(() => _period = period);
            },
          ),
          const SizedBox(height: 14),
          UserManagementTableFrame(
            minTableWidth: _minTableWidth,
            header: UserManagementHeaderRow(
              children: [
                const UserManagementHeaderCell('#', flex: 1),
                const UserManagementHeaderCell('Staff Code', flex: 2),
                const UserManagementHeaderCell('Staff Name', flex: 3),
                const UserManagementHeaderCell('Mobile Number', flex: 3),
                UserManagementHeaderCell(
                  'Total Amount (${_period.label})',
                  flex: 3,
                ),
                const UserManagementHeaderCell(
                  'Action',
                  flex: 2,
                  align: TextAlign.center,
                ),
              ],
            ),
            rowCount: items.length,
            emptyMessage: _searchQuery.trim().isEmpty
                ? 'No staff records found'
                : 'No staff match your search',
            rowBuilder: (context, index) {
              final item = items[index];
              return _StaffReportRow(
                index: index,
                item: item,
                onView: () => widget.onViewStaff(item, _period),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StaffReportToolbar extends StatelessWidget {
  const _StaffReportToolbar({
    required this.searchController,
    required this.period,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onPeriodSelected,
  });

  final TextEditingController searchController;
  final StaffReportPeriod period;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<StaffReportPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final searchField = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isCompact ? double.infinity : 360,
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search staff by name, code or mobile',
              hintStyle: TextStyle(
                fontSize: 10.sp,
                color: AppColors.hint,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  ImageConstants.search,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.hint,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
              filled: true,
              fillColor: AppColors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        );

        final periodButton = PopupMenuButton<StaffReportPeriod>(
          initialValue: period,
          onSelected: onPeriodSelected,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (context) {
            return [
              for (final option in StaffReportPeriod.values)
                PopupMenuItem(
                  value: option,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: option == period
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ];
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  ImageConstants.calender,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: periodButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 12),
            periodButton,
          ],
        );
      },
    );
  }
}

class _StaffReportRow extends StatelessWidget {
  const _StaffReportRow({
    required this.index,
    required this.item,
    required this.onView,
  });

  final int index;
  final StaffReportRowModel item;
  final VoidCallback onView;

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
              UserManagementDataCell('${index + 1}', flex: 1),
              Expanded(
                flex: 2,
                child: Text(
                  item.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(item.name, flex: 3),
              UserManagementDataCell(item.mobileNumber, flex: 3),
              UserManagementDataCell(
                CurrencyFormatter.format(item.totalAmount),
                flex: 3,
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
