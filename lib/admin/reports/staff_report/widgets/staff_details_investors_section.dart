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
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.items,
  });

  final StaffReportPeriod period;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final List<StaffInvestorAmountModel> items;

  @override
  State<StaffDetailsInvestorsSection> createState() =>
      _StaffDetailsInvestorsSectionState();
}

class _StaffDetailsInvestorsSectionState
    extends State<StaffDetailsInvestorsSection> {
  static const double _minTableWidth = 900;
  static const double _searchFieldMaxWidth = 260;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  List<StaffInvestorAmountModel> _filterItems(
    List<StaffInvestorAmountModel> allItems,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      return item.investorCode.toLowerCase().contains(query) ||
          item.investorName.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InvestorsSectionHeader(
            period: widget.period,
            searchFieldMaxWidth: _searchFieldMaxWidth,
            searchController: _searchController,
            onClearSearch: _clearSearch,
          ),
          const SizedBox(height: 14),
          if (widget.isLoading)
            const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else if (widget.errorMessage != null)
            SizedBox(
              height: 260,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, searchValue, _) {
                final query = searchValue.text.trim().toLowerCase();
                final items = _filterItems(widget.items, searchValue.text);

                return UserManagementTableFrame(
                  minTableWidth: _minTableWidth,
                  header: const UserManagementHeaderRow(
                    children: [
                      UserManagementHeaderCell('#', flex: 1),
                      UserManagementHeaderCell('Investor Code', flex: 2),
                      UserManagementHeaderCell('Investor Name', flex: 3),
                      UserManagementHeaderCell('Amount Received', flex: 3),
                      UserManagementHeaderCell('Refund Amnt', flex: 3),
                      UserManagementHeaderCell(
                        'Amount Received Date',
                        flex: 3,
                      ),
                    ],
                  ),
                  rowCount: items.length,
                  emptyMessage: query.isEmpty
                      ? 'No investor amounts found'
                      : 'No investors match your search',
                  rowBuilder: (context, index) {
                    return _InvestorAmountRow(
                      index: index,
                      item: items[index],
                    );
                  },
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
    required this.searchFieldMaxWidth,
    required this.searchController,
    required this.onClearSearch,
  });

  final StaffReportPeriod period;
  final double searchFieldMaxWidth;
  final TextEditingController searchController;
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

        final searchField = SizedBox(
          width: isCompact ? double.infinity : searchFieldMaxWidth,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              final hasText = value.text.isNotEmpty;

              return TextField(
                controller: searchController,
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
                  suffixIcon: hasText
                      ? IconButton(
                          onPressed: onClearSearch,
                          splashRadius: 18,
                          tooltip: 'Clear search',
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        )
                      : null,
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
              );
            },
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
                CurrencyFormatter.format(item.refundAmount),
                flex: 3,
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

String _formatAmountReceivedDate(DateTime? date) {
  if (date == null) {
    return '—';
  }

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
