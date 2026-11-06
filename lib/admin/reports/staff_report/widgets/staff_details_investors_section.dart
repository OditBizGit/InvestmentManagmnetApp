import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_investor_amount_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class StaffDetailsInvestorsSection extends StatefulWidget {
  const StaffDetailsInvestorsSection({
    super.key,
    required this.period,
    required this.items,
  });

  final StaffReportPeriod period;
  final List<StaffInvestorAmountModel> items;

  @override
  State<StaffDetailsInvestorsSection> createState() =>
      _StaffDetailsInvestorsSectionState();
}

class _StaffDetailsInvestorsSectionState
    extends State<StaffDetailsInvestorsSection> {
  static const double _minTableWidth = 900;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffInvestorAmountModel> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.items;

    return widget.items.where((item) {
      return item.investorCode.toLowerCase().contains(query) ||
          item.investorName.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InvestorsSectionHeader(
            period: widget.period,
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          const SizedBox(height: 14),
          UserManagementTableFrame(
            minTableWidth: _minTableWidth,
            header: const UserManagementHeaderRow(
              children: [
                UserManagementHeaderCell('#', flex: 1),
                UserManagementHeaderCell('Investor Code', flex: 2),
                UserManagementHeaderCell('Investor Name', flex: 3),
                UserManagementHeaderCell('Amount Received', flex: 3),
                UserManagementHeaderCell('Amount Received Date', flex: 3),
              ],
            ),
            rowCount: items.length,
            emptyMessage: _searchQuery.trim().isEmpty
                ? 'No investor amounts found'
                : 'No investors match your search',
            rowBuilder: (context, index) {
              return _InvestorAmountRow(
                index: index,
                item: items[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvestorsSectionHeader extends StatelessWidget {
  const _InvestorsSectionHeader({
    required this.period,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final StaffReportPeriod period;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investors (${period.label})',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'List of investors and amount received from this staff',
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final searchField = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isCompact ? double.infinity : 280,
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
              hintText: 'Search investor by name or code',
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

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              searchField,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 12),
            searchField,
          ],
        );
      },
    );
  }
}

class _InvestorAmountRow extends StatelessWidget {
  const _InvestorAmountRow({
    required this.index,
    required this.item,
  });

  final int index;
  final StaffInvestorAmountModel item;

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
                  item.investorCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(item.investorName, flex: 3),
              Expanded(
                flex: 3,
                child: Text(
                  CurrencyFormatter.format(item.amountReceived),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              UserManagementDataCell(
                _formatAmountReceivedDate(item.amountReceivedDate),
                flex: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmountReceivedDate(DateTime date) {
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
