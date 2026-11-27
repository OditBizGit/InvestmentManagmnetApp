import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

import '../model/investor_option.dart';
import 'investor_statement_status_views.dart';

/// Searchable investor picker (autocomplete styled like the Staff Report
/// search field).
class InvestorStatementPicker extends StatefulWidget {
  const InvestorStatementPicker({
    super.key,
    required this.investors,
    required this.isLoading,
    required this.onSelected,
    required this.onCleared,
  });

  final List<InvestorOption> investors;
  final bool isLoading;
  final ValueChanged<InvestorOption> onSelected;
  final VoidCallback onCleared;

  @override
  State<InvestorStatementPicker> createState() =>
      _InvestorStatementPickerState();
}

class _InvestorStatementPickerState extends State<InvestorStatementPicker> {
  static const double _width = 320;

  TextEditingController? _fieldController;

  void _clear() {
    _fieldController?.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onCleared();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < _width + 40
            ? constraints.maxWidth
            : _width;

        return SizedBox(
          width: width,
          child: RawAutocomplete<InvestorOption>(
            displayStringForOption: (option) => option.label,
            optionsBuilder: (value) =>
                widget.investors.where((o) => o.matches(value.text)),
            onSelected: widget.onSelected,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              _fieldController = controller;
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !widget.isLoading,
                  onChanged: (text) {
                    // Emptying the field (backspace) clears like the X button.
                    if (text.isEmpty) widget.onCleared();
                  },
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _decoration(
                    hint: widget.isLoading
                        ? 'Loading investors...'
                        : 'Search investor by name or code',
                    suffix: value.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clear,
                            splashRadius: 18,
                            tooltip: 'Clear investor',
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              final list = options.toList(growable: false);
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: AppColors.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 260,
                      maxWidth: width,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final option = list[index];
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  InputDecoration _decoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
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
          colorFilter: const ColorFilter.mode(AppColors.hint, BlendMode.srcIn),
        ),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }
}

/// Optional date field (same look as the month range fields). Tap to pick,
/// the clear icon removes the date. Future dates cannot be picked.
class InvestorStatementDateField extends StatelessWidget {
  const InvestorStatementDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final today = DateTime.now();
    final lastDate = DateTime(today.year, today.month, today.day);
    final initial = value == null || value!.isAfter(lastDate)
        ? lastDate
        : value!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: lastDate,
      helpText: 'Select $label date',
    );
    if (picked != null) onChanged(picked);
  }

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
            onTap: () => _pick(context),
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
                    value == null ? 'Any' : formatStatementDate(value),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: value == null
                          ? AppColors.hint
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (value != null)
                    InkWell(
                      onTap: () => onChanged(null),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    )
                  else
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
