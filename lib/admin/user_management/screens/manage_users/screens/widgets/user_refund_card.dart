import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class UserRefundCard extends StatefulWidget {
  const UserRefundCard({
    super.key,
    required this.user,
    required this.committedAmount,
    required this.paidAmount,
    this.isSaving = false,
  });

  final ManageUsersInvestor user;
  final double committedAmount;
  final double paidAmount;
  final bool isSaving;

  @override
  State<UserRefundCard> createState() => _UserRefundCardState();
}

class _UserRefundCardState extends State<UserRefundCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _selectedPaymentMethod;
  String? _paymentMethodError;

  @override
  void didUpdateWidget(covariant UserRefundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _amountController.clear();
    _remarksController.clear();
    _selectedPaymentMethod = null;
    _paymentMethodError = null;
    _formKey.currentState?.reset();
  }

  double? _parseAmount(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _saveRefund() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final maxRefundable = widget.paidAmount;
    if (maxRefundable <= 0) return;

    final paymentMethod = _selectedPaymentMethod?.trim() ?? '';
    if (paymentMethod.isEmpty) {
      setState(() {
        _paymentMethodError = 'Select a payment method';
      });
    } else {
      setState(() => _paymentMethodError = null);
    }

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || paymentMethod.isEmpty) return;

    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (amount > maxRefundable) return;

    final saved = await context.read<ManageUsersCubit>().refundUser(
          user: widget.user,
          refundAmount: amount,
          paymentMethod: paymentMethod,
          remarks: _remarksController.text.trim(),
        );

    if (!mounted || !saved) return;
    _resetForm();
    setState(() {});
  }

  String? _validateAmount(String? value) {
    final maxRefundable = widget.paidAmount;
    if (maxRefundable <= 0) {
      return 'No paid amount available to refund';
    }

    final amount = _parseAmount(value ?? '');
    if (amount == null || amount <= 0) {
      return 'Enter a valid refund amount';
    }
    if (amount > maxRefundable) {
      return 'Amount cannot exceed ${CurrencyFormatter.format(maxRefundable)}';
    }
    return null;
  }

  String? _validateRemarks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Remarks are required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final maxRefundable = widget.paidAmount;
    final canRefund = maxRefundable > 0 && !widget.isSaving;

    return AddInvestorSectionCard(
      title: 'Refund user',
      subtitle:
          'Review committed and paid amounts, then record the refund details',
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 640;

            final committedField = _RefundReadOnlyAmountField(
              label: 'Committed amt',
              amount: widget.committedAmount,
            );
            final paidField = _RefundReadOnlyAmountField(
              label: 'Paid amt',
              amount: widget.paidAmount,
            );

            final refundField = AddInvestorLabeledField(
              label: 'Refund',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: _amountController,
                hint: 'Enter refund amount',
                enabled: !widget.isSaving,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                validator: _validateAmount,
              ),
            );

            final methodField = AddInvestorLabeledField(
              label: 'Method',
              isRequired: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IgnorePointer(
                    ignoring: widget.isSaving,
                    child: Opacity(
                      opacity: widget.isSaving ? 0.6 : 1,
                      child: AddInvestorDropdownInput(
                        value: _selectedPaymentMethod,
                        hint: 'Select payment method',
                        items: kAdvancePaymentModeOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                            _paymentMethodError = null;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_paymentMethodError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _paymentMethodError!,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            );

            final remarksField = AddInvestorLabeledField(
              label: 'Remarks',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: _remarksController,
                hint: 'Enter refund remarks',
                enabled: !widget.isSaving,
                maxLines: 3,
                validator: _validateRemarks,
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RefundFormRow(
                  stacked: stacked,
                  left: committedField,
                  right: paidField,
                ),
                const SizedBox(height: 14),
                _RefundFormRow(
                  stacked: stacked,
                  left: refundField,
                  right: methodField,
                ),
                const SizedBox(height: 14),
                remarksField,
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: canRefund ? _saveRefund : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.textMuted,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: widget.isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          )
                        : Text(
                            'Save refund',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RefundFormRow extends StatelessWidget {
  const _RefundFormRow({
    required this.stacked,
    required this.left,
    required this.right,
  });

  final bool stacked;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          left,
          const SizedBox(height: 14),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }
}

class _RefundReadOnlyAmountField extends StatelessWidget {
  const _RefundReadOnlyAmountField({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return AddInvestorLabeledField(
      label: label,
      child: InputDecorator(
        decoration: addInvestorInputDecoration('—').copyWith(
          filled: true,
          fillColor: const Color(0xFFF8F7FA),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
