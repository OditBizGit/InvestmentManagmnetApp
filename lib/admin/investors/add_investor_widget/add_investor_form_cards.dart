import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/image_constants.dart';

/// Left column: Basic Information + Investment Details cards.
class AddInvestorFormCards extends StatelessWidget {
  const AddInvestorFormCards({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.organizationController,
    required this.mobileController,
    required this.emailController,
    required this.addressController,
    required this.amountController,
    required this.investorType,
    required this.typeOptions,
    required this.onTypeChanged,
    required this.investmentDate,
    required this.onPickDate,
    required this.formatDate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController organizationController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController amountController;
  final String? investorType;
  final List<String> typeOptions;
  final ValueChanged<String?> onTypeChanged;
  final DateTime? investmentDate;
  final VoidCallback onPickDate;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _BasicInformationCard(
            fullNameController: fullNameController,
            organizationController: organizationController,
            mobileController: mobileController,
            emailController: emailController,
            addressController: addressController,
            investorType: investorType,
            typeOptions: typeOptions,
            onTypeChanged: onTypeChanged,
          ),
          const SizedBox(height: 16),
          _InvestmentDetailsCard(
            amountController: amountController,
            investmentDate: investmentDate,
            onPickDate: onPickDate,
            formatDate: formatDate,
          ),
        ],
      ),
    );
  }
}

class _BasicInformationCard extends StatelessWidget {
  const _BasicInformationCard({
    required this.fullNameController,
    required this.organizationController,
    required this.mobileController,
    required this.emailController,
    required this.addressController,
    required this.investorType,
    required this.typeOptions,
    required this.onTypeChanged,
  });

  final TextEditingController fullNameController;
  final TextEditingController organizationController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final String? investorType;
  final List<String> typeOptions;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Basic Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PhotoUploadBox(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 560;
              if (!twoCol) {
                return Column(
                  children: [
                    AddInvestorLabeledField(
                      label: 'Full Name',
                      isRequired: true,
                      child: AddInvestorTextInput(
                        controller: fullNameController,
                        hint: 'Enter investor name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AddInvestorLabeledField(
                      label: 'Investor Type',
                      child: AddInvestorDropdownInput(
                        value: investorType,
                        hint: 'Select investor type',
                        items: typeOptions,
                        onChanged: onTypeChanged,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AddInvestorLabeledField(
                      label: 'Organization',
                      child: AddInvestorTextInput(
                        controller: organizationController,
                        hint: 'Enter organization',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AddInvestorLabeledField(
                      label: 'Mobile Number',
                      isRequired: true,
                      child: AddInvestorTextInput(
                        controller: mobileController,
                        hint: 'Enter mobile number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final mobile = value?.trim() ?? '';
                          if (mobile.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          final digits = mobile.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 10) {
                            return 'Enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AddInvestorLabeledField(
                      label: 'Email Address',
                      child: AddInvestorTextInput(
                        controller: emailController,
                        hint: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AddInvestorLabeledField(
                      label: 'Address',
                      isRequired: true,
                      child: AddInvestorTextInput(
                        controller: addressController,
                        hint: 'Enter address',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Full Name',
                          isRequired: true,
                          child: AddInvestorTextInput(
                            controller: fullNameController,
                            hint: 'Enter investor name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter full name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Investor Type',
                          child: AddInvestorDropdownInput(
                            value: investorType,
                            hint: 'Select investor type',
                            items: typeOptions,
                            onChanged: onTypeChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Organization',
                          child: AddInvestorTextInput(
                            controller: organizationController,
                            hint: 'Enter organization',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Mobile Number',
                          isRequired: true,
                          child: AddInvestorTextInput(
                            controller: mobileController,
                            hint: 'Enter mobile number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final mobile = value?.trim() ?? '';
                              if (mobile.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              final digits =
                                  mobile.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 10) {
                                return 'Enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Email Address',
                          child: AddInvestorTextInput(
                            controller: emailController,
                            hint: 'Enter email address',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AddInvestorLabeledField(
                          label: 'Address',
                          isRequired: true,
                          child: AddInvestorTextInput(
                            controller: addressController,
                            hint: 'Enter address',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter address';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvestmentDetailsCard extends StatelessWidget {
  const _InvestmentDetailsCard({
    required this.amountController,
    required this.investmentDate,
    required this.onPickDate,
    required this.formatDate,
  });

  final TextEditingController amountController;
  final DateTime? investmentDate;
  final VoidCallback onPickDate;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Investment Details',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 560;
          final amountField = AddInvestorLabeledField(
            label: 'Investment Amount',
            isRequired: true,
            child: AddInvestorTextInput(
              controller: amountController,
              hint: 'Enter amount',
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = value?.trim() ?? '';
                if (amount.isEmpty) {
                  return 'Please enter investment amount';
                }
                final parsed = double.tryParse(
                  amount.replaceAll(',', ''),
                );
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
          );
          final dateField = AddInvestorLabeledField(
            label: 'Investment Date',
            isRequired: true,
            child: AddInvestorDateInput(
              value: investmentDate == null
                  ? null
                  : formatDate(investmentDate!),
              hint: 'Select date',
              onTap: onPickDate,
              validator: (_) {
                if (investmentDate == null) {
                  return 'Please select investment date';
                }
                return null;
              },
            ),
          );

          if (!twoCol) {
            return Column(
              children: [amountField, const SizedBox(height: 14), dateField],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: amountField),
              const SizedBox(width: 14),
              Expanded(child: dateField),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  const _PhotoUploadBox();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 10.h,
              height: 10.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1F5),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                ImageConstants.camera,
                width: 4.h,
                height: 4.h,
              ),
            ),

            const SizedBox(width: 30),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Upload Profile Photo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'JPEG, PNG (Max 2MB)',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddInvestorSectionCard extends StatelessWidget {
  const AddInvestorSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class AddInvestorLabeledField extends StatelessWidget {
  const AddInvestorLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  final String label;
  final Widget child;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class AddInvestorTextInput extends StatelessWidget {
  const AddInvestorTextInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: addInvestorInputDecoration(hint),
    );
  }
}

class AddInvestorDropdownInput extends StatefulWidget {
  const AddInvestorDropdownInput({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<AddInvestorDropdownInput> createState() =>
      _AddInvestorDropdownInputState();
}

class _AddInvestorDropdownInputState extends State<AddInvestorDropdownInput> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

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
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.newBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: AppColors.newBorder),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item == widget.value;

                    return InkWell(
                      onTap: () {
                        widget.onChanged(item);
                        _closeDropdown();
                      },
                      child: Container(
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
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _closeDropdown();
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
              color: _isOpen ? AppColors.accent : AppColors.newBorder,
              width: 1,
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

class AddInvestorDateInput extends StatelessWidget {
  const AddInvestorDateInput({
    super.key,
    required this.value,
    required this.hint,
    required this.onTap,
    this.validator,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ValueKey(value),
      initialValue: value,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: (field) {
        final hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: addInvestorInputDecoration(hint).copyWith(
                  errorText: hasError ? '' : null,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      ImageConstants.calender,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                isEmpty: value == null,
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color:
                        value == null ? AppColors.hint : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

InputDecoration addInvestorInputDecoration(String hint) {
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
