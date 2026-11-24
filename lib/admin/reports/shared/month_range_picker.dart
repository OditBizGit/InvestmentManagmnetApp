import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

/// Max distance between From and To months: 12 months inclusive (R24).
const int kMaxMonthRange = 11;

const List<String> _monthNames = [
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

/// Result of [adjustMonthRange]. Both dates are the first day of a month.
class MonthRangeChange {
  const MonthRangeChange({
    required this.from,
    required this.to,
    required this.limited,
  });

  final DateTime from;
  final DateTime to;

  /// True when the other end was shifted to respect the month cap.
  final bool limited;
}

DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

/// Adds [months] to a first-of-month date.
DateTime _addMonths(DateTime d, int months) =>
    DateTime(d.year, d.month + months, 1);

int _monthIndex(DateTime d) => d.year * 12 + d.month;

/// Default range: the last 6 months ending with the current month.
({DateTime from, DateTime to}) defaultMonthRange({DateTime? now}) {
  final current = _monthStart(now ?? DateTime.now());
  return (from: _addMonths(current, -5), to: current);
}

/// Applies a user change to one end of a month range.
///
/// [from] / [to] already hold the new value for the end that changed
/// ([fromChanged]). Rules, matching Funding & Payments Overview:
/// no future months; To before From aligns the other end; a span over
/// [maxMonths] shifts the other end and sets [MonthRangeChange.limited].
MonthRangeChange adjustMonthRange({
  required DateTime from,
  required DateTime to,
  required bool fromChanged,
  DateTime? now,
  int maxMonths = kMaxMonthRange,
}) {
  final current = _monthStart(now ?? DateTime.now());

  var nextFrom = _monthStart(from);
  var nextTo = _monthStart(to);
  if (nextFrom.isAfter(current)) nextFrom = current;
  if (nextTo.isAfter(current)) nextTo = current;

  var limited = false;

  if (nextTo.isBefore(nextFrom)) {
    if (fromChanged) {
      nextTo = nextFrom;
    } else {
      nextFrom = nextTo;
    }
  } else if (_monthIndex(nextTo) - _monthIndex(nextFrom) > maxMonths) {
    limited = true;
    if (fromChanged) {
      nextTo = _addMonths(nextFrom, maxMonths);
      if (nextTo.isAfter(current)) nextTo = current;
    } else {
      nextFrom = _addMonths(nextTo, -maxMonths);
    }
  }

  return MonthRangeChange(from: nextFrom, to: nextTo, limited: limited);
}

/// From / To month picker with a 12-month cap and no future months.
///
/// Owns no state: the parent keeps [from] / [to] and refetches in [onChanged].
class MonthRangePicker extends StatelessWidget {
  const MonthRangePicker({
    super.key,
    required this.from,
    required this.to,
    required this.onChanged,
    this.toastTitle = 'Date range',
  });

  final DateTime from;
  final DateTime to;
  final void Function(DateTime from, DateTime to) onChanged;
  final String toastTitle;

  static String formatMonth(DateTime d) =>
      '${_monthNames[d.month - 1]} ${d.year}';

  Future<void> _pick(BuildContext context, {required bool isFrom}) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initial: isFrom ? from : to,
        title: isFrom ? 'Select from month' : 'Select to month',
      ),
    );
    if (picked == null || !context.mounted) return;

    final result = adjustMonthRange(
      from: isFrom ? picked : from,
      to: isFrom ? to : picked,
      fromChanged: isFrom,
    );
    if (result.limited) {
      AppToast.info(
        'Date range limited to 12 months',
        title: toastTitle,
        context: context,
      );
    }
    onChanged(result.from, result.to);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MonthField(
          label: 'From',
          value: formatMonth(from),
          onTap: () => _pick(context, isFrom: true),
        ),
        _MonthField(
          label: 'To',
          value: formatMonth(to),
          onTap: () => _pick(context, isFrom: false),
        ),
      ],
    );
  }
}

class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ImageConstants.calender,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Year + 12-month grid. Future months are disabled.
class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.initial, required this.title});

  final DateTime initial;
  final String title;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final current = _monthStart(DateTime.now());

    return Dialog(
      backgroundColor: AppColors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Previous year',
                    onPressed: () => setState(() => _year--),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    '$_year',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next year',
                    onPressed: _year < current.year
                        ? () => setState(() => _year++)
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var m = 1; m <= 12; m++)
                    _MonthCell(
                      label: _monthNames[m - 1],
                      selected:
                          widget.initial.year == _year &&
                          widget.initial.month == m,
                      enabled: !DateTime(_year, m, 1).isAfter(current),
                      onTap: () =>
                          Navigator.of(context).pop(DateTime(_year, m, 1)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Material(
        color: selected ? const Color(0xFFF0EBF6) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: enabled ? AppColors.textPrimary : AppColors.hint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
