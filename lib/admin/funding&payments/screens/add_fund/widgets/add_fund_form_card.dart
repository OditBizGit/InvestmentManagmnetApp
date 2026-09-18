import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

/// Payment methods available when recording a fund payment.
const List<String> kFundPaymentMethodOptions = [
  'NEFT',
  'RTGS',
  'IMPS',
  'UPI',
  'Cash',
  'Bank Transfer',
  'Cheque',
];

class AddFundFormCard extends StatelessWidget {
  const AddFundFormCard({
    super.key,
    required this.formKey,
    required this.investor,
    required this.investorOptions,
    required this.onInvestorChanged,
    required this.investorType,
    required this.totalAmountController,
    required this.totalPaidAmountController,
    required this.remainingAmountController,
    required this.dueAmountLabel,
    required this.dueDateLabel,
    required this.dueStatus,
    required this.payingNowController,
    required this.payingNowValidator,
    required this.onPayDue,
    required this.paymentMethodOptions,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.fundingDate,
    required this.onPickDate,
    required this.formatDate,
    required this.descriptionController,
    this.isLoadingInvestors = false,
    this.canPayDue = false,
  });

  final GlobalKey<FormState> formKey;
  final String? investor;
  final List<String> investorOptions;
  final ValueChanged<String?> onInvestorChanged;
  final String? investorType;
  final TextEditingController totalAmountController;
  final TextEditingController totalPaidAmountController;
  final TextEditingController remainingAmountController;
  final String? dueAmountLabel;
  final String? dueDateLabel;
  final String? dueStatus;
  final TextEditingController payingNowController;
  final String? Function(String?) payingNowValidator;
  final VoidCallback onPayDue;
  final List<String> paymentMethodOptions;
  final String? selectedPaymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;
  final DateTime fundingDate;
  final VoidCallback onPickDate;
  final String Function(DateTime) formatDate;
  final TextEditingController descriptionController;
  final bool isLoadingInvestors;
  final bool canPayDue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Funding Details',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 520;

                final investorField = _LabeledField(
                  label: 'Investor',
                  child: isLoadingInvestors
                      ? Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.newBorder,
                              width: 1,
                            ),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _DropdownInput(
                          value: investor,
                          hint: investorOptions.isEmpty
                              ? 'No investors available'
                              : 'Select investor',
                          items: investorOptions,
                          onChanged: onInvestorChanged,
                          enableSearch: true,
                          searchHint: 'Search investor',
                        ),
                );
                final typeField = _LabeledField(
                  label: 'Investor Type',
                  child: _ReadOnlyField(
                    value: investorType,
                    hint: 'Auto-filled after investor selection',
                  ),
                );
                final totalAmountField = _LabeledField(
                  label: 'Total Amount',
                  child: _TextInput(
                    controller: totalAmountController,
                    hint: 'Auto-filled after investor selection',
                    readOnly: true,
                  ),
                );
                final totalPaidAmountField = _LabeledField(
                  label: 'Paid Amount',
                  child: _TextInput(
                    controller: totalPaidAmountController,
                    hint: 'Updates with paying now',
                    readOnly: true,
                  ),
                );
                final remainingAmountField = _LabeledField(
                  label: 'Remaining Amount',
                  child: _TextInput(
                    controller: remainingAmountController,
                    hint: 'Updates with paying now',
                    readOnly: true,
                  ),
                );
                final dueAmountField = _LabeledField(
                  label: 'Due Amount',
                  child: _DueAmountField(
                    amount: dueAmountLabel,
                    status: dueStatus,
                  ),
                );
                final dueDateField = _LabeledField(
                  label: 'Due Date',
                  child: _ReadOnlyField(
                    value: dueDateLabel,
                    hint: 'Auto-filled after investor selection',
                  ),
                );
                final payingNowField = _LabeledField(
                  label: 'Paying Now',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _TextInput(
                          controller: payingNowController,
                          hint: 'Enter amount (partial OK)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: payingNowValidator,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PayDueButton(
                        enabled: canPayDue,
                        onTap: onPayDue,
                      ),
                    ],
                  ),
                );
                final paymentMethodField = _LabeledField(
                  label: 'Payment Method',
                  child: _DropdownInput(
                    value: selectedPaymentMethod,
                    hint: 'Select payment method',
                    items: paymentMethodOptions,
                    onChanged: onPaymentMethodChanged,
                  ),
                );
                final dateField = _LabeledField(
                  label: 'Funding Date',
                  child: _DateInput(
                    value: formatDate(fundingDate),
                    hint: 'Select date',
                    onTap: onPickDate,
                  ),
                );
                final descriptionField = _LabeledField(
                  label: 'Description',
                  child: _TextInput(
                    controller: descriptionController,
                    hint: 'Enter description',
                    maxLines: 4,
                  ),
                );

                if (!twoCol) {
                  return Column(
                    children: [
                      investorField,
                      const SizedBox(height: 14),
                      typeField,
                      const SizedBox(height: 14),
                      totalAmountField,
                      const SizedBox(height: 14),
                      totalPaidAmountField,
                      const SizedBox(height: 14),
                      remainingAmountField,
                      const SizedBox(height: 14),
                      dueAmountField,
                      const SizedBox(height: 14),
                      dueDateField,
                      const SizedBox(height: 14),
                      payingNowField,
                      const SizedBox(height: 14),
                      paymentMethodField,
                      const SizedBox(height: 14),
                      dateField,
                      const SizedBox(height: 14),
                      descriptionField,
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: investorField),
                        const SizedBox(width: 14),
                        Expanded(child: typeField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: totalAmountField),
                        const SizedBox(width: 14),
                        Expanded(child: totalPaidAmountField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    remainingAmountField,
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: dueAmountField),
                        const SizedBox(width: 14),
                        Expanded(child: dueDateField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    payingNowField,
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: paymentMethodField),
                        const SizedBox(width: 14),
                        Expanded(child: dateField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    descriptionField,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DueAmountField extends StatelessWidget {
  const _DueAmountField({
    required this.amount,
    required this.status,
  });

  final String? amount;
  final String? status;

  Color get _statusColor {
    switch (status) {
      case 'Completed':
        return AppColors.green;
      case 'Partially Paid':
        return const Color(0xFFFB8C00);
      default:
        return AppColors.accent;
    }
  }

  Color get _statusBg {
    switch (status) {
      case 'Completed':
        return const Color(0xFFE6F6EC);
      case 'Partially Paid':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFF0EBF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              amount ?? 'Auto-filled after investor selection',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: amount == null ? AppColors.hint : AppColors.textPrimary,
              ),
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status!,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayDueButton extends StatelessWidget {
  const _PayDueButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Pay Due',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    required this.hint,
  });

  final String? value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value ?? hint,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: value == null ? AppColors.hint : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(hint).copyWith(
        fillColor: readOnly ? const Color(0xFFF8F7FA) : AppColors.white,
      ),
    );
  }
}

class _DropdownInput extends StatefulWidget {
  const _DropdownInput({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.enableSearch = false,
    this.searchHint = 'Search',
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool enableSearch;
  final String searchHint;

  @override
  State<_DropdownInput> createState() => _DropdownInputState();
}

class _DropdownInputState extends State<_DropdownInput> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();

  bool get _isOpen => _overlayEntry != null;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    _searchController.clear();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setOverlayState) {
                  final query = _searchController.text.trim().toLowerCase();
                  final filtered = query.isEmpty
                      ? widget.items
                      : widget.items
                          .where(
                            (item) => item.toLowerCase().contains(query),
                          )
                          .toList();

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.newBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.enableSearch) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (_) => setOverlayState(() {}),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.searchHint,
                                hintStyle: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.hint,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F7FA),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.newBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.accent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: AppColors.newBorder,
                          ),
                        ],
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: filtered.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'No matches found',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shrinkWrap: true,
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, _) => const Divider(
                                    height: 1,
                                    color: AppColors.newBorder,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    final isSelected = item == widget.value;

                                    return InkWell(
                                      onTap: () {
                                        widget.onChanged(item);
                                        _closeDropdown();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 18,
                                                color: AppColors.accent,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) setState(() {});
  }

  void _closeDropdown({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    }
    if (notify && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Avoid setState during dispose — it marks a defunct element dirty.
    _closeDropdown(notify: false);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isOpen ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value ?? widget.hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: widget.value == null
                        ? AppColors.hint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(hint).copyWith(
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              ImageConstants.calender,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.hint,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: AppColors.white,
    errorStyle: TextStyle(
      fontSize: 9.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.error,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.2),
    ),
  );
}
