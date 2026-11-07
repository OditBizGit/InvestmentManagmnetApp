
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../cubit/staff_report_cubit.dart';
import '../model/staff_report_row_model.dart';

enum StaffReportPeriod {
  thisMonth,
  lastMonth,
  custom,
}

extension StaffReportPeriodX on StaffReportPeriod {
  String get label => switch (this) {
    StaffReportPeriod.thisMonth => 'This Month',
    StaffReportPeriod.lastMonth => 'Last Month',
    StaffReportPeriod.custom => 'Custom',
  };

  String get apiValue => switch (this) {
    StaffReportPeriod.thisMonth => 'ThisMonth',
    StaffReportPeriod.lastMonth => 'LastMonth',
    StaffReportPeriod.custom => 'Custom',
  };
}

class StaffReportTableSection extends StatefulWidget {
  const StaffReportTableSection({
    super.key,
    this.items,
    required this.onViewStaff,
  });

  final List<StaffReportRowModel>? items;

  final void Function(
    StaffReportRowModel staff,
    StaffReportPeriod period, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) onViewStaff;

  @override
  State<StaffReportTableSection> createState() =>
      _StaffReportTableSectionState();
}

class _StaffReportTableSectionState extends State<StaffReportTableSection> {
  static const double _minTableWidth = 900;
  static const double _searchFieldMaxWidth = 260;

  final TextEditingController _searchController = TextEditingController();

  StaffReportPeriod _period = StaffReportPeriod.thisMonth;

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _fetchStaffReport() {
    context.read<StaffReportCubit>().fetchStaffReport(
      period: _period.apiValue,
      fromDate: _period == StaffReportPeriod.custom &&
              _selectedFromDate != null
          ? _formatDate(_selectedFromDate!)
          : null,
      toDate: _period == StaffReportPeriod.custom &&
              _selectedToDate != null
          ? _formatDate(_selectedToDate!)
          : null,
    );
  }

  void _clearSearch() {
    _searchController.clear();
  }

  List<StaffReportRowModel> _filterItems(
    List<StaffReportRowModel> allItems,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.code.toLowerCase().contains(query) ||
          item.mobileNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _onPeriodSelected(StaffReportPeriod period) async {
    if (period == StaffReportPeriod.custom) {
      final dateRange = await showStaffReportCustomDateRangeDialog(
        context: context,
        initialRange: _selectedFromDate != null && _selectedToDate != null
            ? DateTimeRange(
                start: _selectedFromDate!,
                end: _selectedToDate!,
              )
            : null,
      );

      if (!mounted || dateRange == null) return;

      setState(() {
        _period = StaffReportPeriod.custom;
        _selectedFromDate = dateRange.start;
        _selectedToDate = dateRange.end;
      });

      _fetchStaffReport();
      return;
    }

    setState(() {
      _period = period;
      _selectedFromDate = null;
      _selectedToDate = null;
    });

    _fetchStaffReport();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffReportCubit, StaffReportState>(
      listenWhen: (previous, current) =>
          current.listStatus == StaffReportListStatus.failure &&
          current.listErrorMessage != null &&
          previous.listErrorMessage != current.listErrorMessage,
      listener: (context, state) {
        AppToast.error(state.listErrorMessage!, context: context);
      },
      child: BlocBuilder<StaffReportCubit, StaffReportState>(
        buildWhen: (previous, current) =>
            previous.listStatus != current.listStatus ||
            previous.staffList != current.staffList ||
            previous.listErrorMessage != current.listErrorMessage,
        builder: (context, state) {
          final List<StaffReportRowModel> allItems;
          final bool isLoading;
          final String? errorMessage;

          if (widget.items != null) {
            allItems = widget.items!;
            isLoading = false;
            errorMessage = null;
          } else if (state.listStatus == StaffReportListStatus.loading) {
            allItems = const [];
            isLoading = true;
            errorMessage = null;
          } else if (state.listStatus == StaffReportListStatus.failure) {
            allItems = const [];
            isLoading = false;
            errorMessage = state.listErrorMessage;
          } else if (state.listStatus == StaffReportListStatus.success) {
            allItems = state.staffList.map((staff) {
              return StaffReportRowModel(
                staffId: staff.staffId,
                code: staff.staffCode,
                name: staff.staffName,
                mobileNumber: staff.mobileNumber,
                totalAmount: staff.totalAmount,
              );
            }).toList();
            isLoading = false;
            errorMessage = null;
          } else {
            allItems = const [];
            isLoading = false;
            errorMessage = null;
          }

          return UserManagementTableCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StaffReportToolbar(
                  searchFieldMaxWidth: _searchFieldMaxWidth,
                  searchController: _searchController,
                  period: _period,
                  onClearSearch: _clearSearch,
                  onPeriodSelected: _onPeriodSelected,
                ),

                if (_period == StaffReportPeriod.custom &&
                    _selectedFromDate != null &&
                    _selectedToDate != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_formatDate(_selectedFromDate!)} - '
                      '${_formatDate(_selectedToDate!)}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, searchValue, _) {
                    final query = searchValue.text.trim().toLowerCase();
                    final filteredItems =
                        _filterItems(allItems, searchValue.text);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isLoading &&
                            errorMessage == null &&
                            allItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${filteredItems.length} staff records found',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (isLoading)
                          const SizedBox(
                            height: 260,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                            ),
                          )
                        else if (errorMessage != null)
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
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _fetchStaffReport,
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
                          UserManagementTableFrame(
                            minTableWidth: _minTableWidth,
                            header: UserManagementHeaderRow(
                              children: [
                                const UserManagementHeaderCell('#', flex: 1),
                                const UserManagementHeaderCell(
                                  'Staff Code',
                                  flex: 2,
                                ),
                                const UserManagementHeaderCell(
                                  'Staff Name',
                                  flex: 3,
                                ),
                                const UserManagementHeaderCell(
                                  'Mobile Number',
                                  flex: 3,
                                ),
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
                            rowCount: filteredItems.length,
                            emptyMessage: query.isEmpty
                                ? 'No staff records found'
                                : 'No staff match your search',
                            rowBuilder: (context, index) {
                              final item = filteredItems[index];

                              return _StaffReportRow(
                                index: index,
                                item: item,
                                onView: () => widget.onViewStaff(
                                  item,
                                  _period,
                                  customFromDate: _selectedFromDate,
                                  customToDate: _selectedToDate,
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<DateTimeRange?> showStaffReportCustomDateRangeDialog({
  required BuildContext context,
  DateTimeRange? initialRange,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _StaffReportDateRangeDialog(initialRange: initialRange);
    },
  );
}

class _StaffReportDateRangeDialog extends StatefulWidget {
  const _StaffReportDateRangeDialog({this.initialRange});

  final DateTimeRange? initialRange;

  @override
  State<_StaffReportDateRangeDialog> createState() =>
      _StaffReportDateRangeDialogState();
}

class _StaffReportDateRangeDialogState
    extends State<_StaffReportDateRangeDialog> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late DateTime _calendarFocusedDay;
  bool _selectingFrom = true;

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    final initial = widget.initialRange;

    if (initial != null) {
      _fromDate = _dateOnly(initial.start);
      _toDate = _dateOnly(initial.end);
    } else {
      _toDate = today;
      _fromDate = today.subtract(const Duration(days: 30));
    }

    _calendarFocusedDay = _fromDate;
  }

  String _formatDate(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]}, ${date.year}';
  }

  void _applyCalendarDate(DateTime picked) {
    final day = _dateOnly(picked);
    setState(() {
      if (_selectingFrom) {
        _fromDate = day;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
      } else {
        _toDate = day.isBefore(_fromDate) ? _fromDate : day;
      }
      _calendarFocusedDay = _selectingFrom ? _fromDate : _toDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());

    return Dialog(
      backgroundColor: AppColors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Custom date range',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose from and to dates',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StaffReportDateChip(
                      label: 'From',
                      value: _formatDate(_fromDate),
                      selected: _selectingFrom,
                      onTap: () => setState(() {
                        _selectingFrom = true;
                        _calendarFocusedDay = _fromDate;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StaffReportDateChip(
                      label: 'To',
                      value: _formatDate(_toDate),
                      selected: !_selectingFrom,
                      onTap: () => setState(() {
                        _selectingFrom = false;
                        _calendarFocusedDay = _toDate;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 290,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.accent,
                      onPrimary: AppColors.white,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: CalendarDatePicker(
                    key: ValueKey(
                      '${_selectingFrom}_'
                      '${_calendarFocusedDay.year}_'
                      '${_calendarFocusedDay.month}_'
                      '${_calendarFocusedDay.day}',
                    ),
                    initialDate: _calendarFocusedDay,
                    firstDate: DateTime(2020),
                    lastDate: today,
                    currentDate: today,
                    onDateChanged: _applyCalendarDate,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(
                      DateTimeRange(start: _fromDate, end: _toDate),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffReportDateChip extends StatelessWidget {
  const _StaffReportDateChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF0EBF6) : AppColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffReportToolbar extends StatelessWidget {
  const _StaffReportToolbar({
    required this.searchFieldMaxWidth,
    required this.searchController,
    required this.period,
    required this.onClearSearch,
    required this.onPeriodSelected,
  });

  final double searchFieldMaxWidth;
  final TextEditingController searchController;
  final StaffReportPeriod period;
  final VoidCallback onClearSearch;
  final ValueChanged<StaffReportPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

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
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              );
            },
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
            searchField,
            const Spacer(),
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
              UserManagementDataCell(
                '${index + 1}',
                flex: 1,
              ),
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
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(
                        color: AppColors.accent,
                      ),
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
