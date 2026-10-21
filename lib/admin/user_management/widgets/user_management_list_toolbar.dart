import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum UserManagementExportFormat { excel, pdf }

enum UserManagementExportScope { allTransactions, dues }

Future<UserManagementExportScope?> showUserManagementExportScopeDialog({
  required BuildContext context,
  required UserManagementExportFormat format,
}) {
  final formatLabel = format == UserManagementExportFormat.excel
      ? 'Excel'
      : 'PDF';

  return showDialog<UserManagementExportScope>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Export as $formatLabel',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose what to include',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                _ExportScopeOptionTile(
                  title: 'All transaction',
                  subtitle: 'Full transaction history',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => Navigator.of(dialogContext).pop(
                    UserManagementExportScope.allTransactions,
                  ),
                ),
                const SizedBox(height: 8),
                _ExportScopeOptionTile(
                  title: 'Dues',
                  subtitle: 'Outstanding payments only',
                  icon: Icons.schedule_rounded,
                  onTap: () => Navigator.of(dialogContext).pop(
                    UserManagementExportScope.dues,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<DateTimeRange?> showUserManagementExportDateRangeDialog({
  required BuildContext context,
  required UserManagementExportFormat format,
  required UserManagementExportScope scope,
}) {
  final scopeLabel = scope == UserManagementExportScope.dues
      ? 'Dues'
      : 'All transaction';
  final formatLabel =
      format == UserManagementExportFormat.excel ? 'Excel' : 'PDF';

  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _ExportDateRangeDialog(
        title: 'Export $formatLabel · $scopeLabel',
      );
    },
  );
}

class _ExportDateRangeDialog extends StatefulWidget {
  const _ExportDateRangeDialog({required this.title});

  final String title;

  @override
  State<_ExportDateRangeDialog> createState() => _ExportDateRangeDialogState();
}

class _ExportDateRangeDialogState extends State<_ExportDateRangeDialog> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late DateTime _calendarFocusedDay;
  bool _selectingFrom = true;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _toDate = today;
    _fromDate = today.subtract(const Duration(days: 30));
    _calendarFocusedDay = _selectingFrom ? _fromDate : _toDate;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
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
                widget.title,
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
                    child: _ExportDateChip(
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
                    child: _ExportDateChip(
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
                    colorScheme: ColorScheme.light(
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

class _ExportDateChip extends StatelessWidget {
  const _ExportDateChip({
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

class UserManagementExportIcons extends StatelessWidget {
  const UserManagementExportIcons({
    super.key,
    required this.onExportSelected,
    this.isExporting = false,
  });

  final void Function(
    UserManagementExportFormat format,
    UserManagementExportScope scope,
    DateTimeRange dateRange,
  ) onExportSelected;
  final bool isExporting;

  Future<void> _pickScope(
    BuildContext context,
    UserManagementExportFormat format,
  ) async {
    if (isExporting) return;

    final scope = await showUserManagementExportScopeDialog(
      context: context,
      format: format,
    );
    if (scope == null || !context.mounted) return;

    final range = await showUserManagementExportDateRangeDialog(
      context: context,
      format: format,
      scope: scope,
    );
    if (range == null || !context.mounted) return;

    onExportSelected(format, scope, range);
  }

  @override
  Widget build(BuildContext context) {
    if (isExporting) {
      return const SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExportIconButton(
          tooltip: 'Excel',
          icon: Icons.grid_on_rounded,
          color: const Color(0xFF217346),
          background: const Color(0xFFE8F5EE),
          onTap: () => _pickScope(context, UserManagementExportFormat.excel),
        ),
        const SizedBox(width: 8),
        _ExportIconButton(
          tooltip: 'PDF',
          icon: Icons.picture_as_pdf_rounded,
          color: const Color(0xFFD32F2F),
          background: const Color(0xFFFFEBEE),
          onTap: () => _pickScope(context, UserManagementExportFormat.pdf),
        ),
      ],
    );
  }
}

class _ExportScopeOptionTile extends StatelessWidget {
  const _ExportScopeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportIconButton extends StatelessWidget {
  const _ExportIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}

class UserManagementListToolbar extends StatelessWidget {
  const UserManagementListToolbar({
    super.key,
    required this.title,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.filters,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    this.trailing,
  });

  final String title;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final List<String> filters;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final titleWidget = Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
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
              hintText: searchHint,
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

        final filterChips = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < filters.length; i++)
              _FilterChip(
                label: filters[i],
                selected: i == selectedFilterIndex,
                onTap: () => onFilterSelected(i),
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: titleWidget),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: 12),
              searchField,
              const SizedBox(height: 12),
              filterChips,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: titleWidget),
                const SizedBox(width: 12),
                searchField,
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            filterChips,
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.cardBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
