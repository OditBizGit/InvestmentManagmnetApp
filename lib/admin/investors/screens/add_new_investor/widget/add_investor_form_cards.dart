import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/admin/investors/cubit/investors_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_additional_information.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constants/image_constants.dart';

/// UI-only installment row for the optional payment schedule preview.
class PaymentScheduleInstallment {
  const PaymentScheduleInstallment({
    required this.installmentNumber,
    required this.dueDate,
    required this.installmentAmount,
    required this.paymentStatus,
  });

  final int installmentNumber;
  final DateTime dueDate;
  final double installmentAmount;
  final String paymentStatus;
}

/// Payment methods available for advance payment.
const List<String> kAdvancePaymentModeOptions = [
  'NEFT',
  'RTGS',
  'IMPS',
  'UPI',
  'Cash',
  'Bank Transfer',
  'Cheque',
];

/// Left column: Basic Information + Login Credentials + Investment Details +
/// Additional Information (Bank/KYC + Nominee).
class AddInvestorFormCards extends StatelessWidget {
  const AddInvestorFormCards({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.organizationController,
    required this.mobileController,
    required this.alternateMobileController,
    required this.emailController,
    required this.addressController,
    required this.amountController,
    required this.usernameController,
    required this.passwordController,
    required this.investorType,
    required this.onTypeChanged,
    required this.investmentDate,
    required this.onPickDate,
    required this.formatDate,
    this.profilePhoto,
    required this.onPickProfilePhoto,
    required this.onClearProfilePhoto,
    required this.frequencyOptions,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    required this.monthOptions,
    required this.selectedMonthOption,
    required this.onMonthOptionChanged,
    required this.customMonthsController,
    required this.intervalController,
    required this.advancePaymentController,
    required this.paymentModeOptions,
    required this.selectedPaymentMode,
    required this.onPaymentModeChanged,
    required this.paymentSchedule,
    required this.formatCurrency,
    required this.aadhaarController,
    required this.panController,
    required this.bankNameController,
    required this.ifscController,
    required this.accountNumberController,
    required this.nomineeNameController,
    required this.nomineeAddressController,
    required this.nomineeRelationship,
    required this.onNomineeRelationshipChanged,
    required this.nomineeAadhaarController,
    required this.nomineePanController,
    required this.nomineeDateOfBirth,
    required this.onPickNomineeDateOfBirth,
    required this.nomineePhoneController,
    this.nomineePhoto,
    required this.onPickNomineePhoto,
    required this.onClearNomineePhoto, DateTime? dateOfBirth,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController organizationController;
  final TextEditingController mobileController;
  final TextEditingController alternateMobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController amountController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? investorType;
  final ValueChanged<String?> onTypeChanged;
  final DateTime? investmentDate;
  final VoidCallback onPickDate;
  final String Function(DateTime) formatDate;
  final PickedPhoto? profilePhoto;
  final VoidCallback onPickProfilePhoto;
  final VoidCallback onClearProfilePhoto;
  final List<String> frequencyOptions;
  final String selectedFrequency;
  final ValueChanged<String?> onFrequencyChanged;
  final List<String> monthOptions;
  final String? selectedMonthOption;
  final ValueChanged<String?> onMonthOptionChanged;
  final TextEditingController customMonthsController;
  final TextEditingController intervalController;
  final TextEditingController advancePaymentController;
  final List<String> paymentModeOptions;
  final String? selectedPaymentMode;
  final ValueChanged<String?> onPaymentModeChanged;
  final List<PaymentScheduleInstallment> paymentSchedule;
  final String Function(double) formatCurrency;
  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final TextEditingController bankNameController;
  final TextEditingController ifscController;
  final TextEditingController accountNumberController;
  final TextEditingController nomineeNameController;
  final TextEditingController nomineeAddressController;
  final String? nomineeRelationship;
  final ValueChanged<String?> onNomineeRelationshipChanged;
  final TextEditingController nomineeAadhaarController;
  final TextEditingController nomineePanController;
  final DateTime? nomineeDateOfBirth;
  final VoidCallback onPickNomineeDateOfBirth;
  final TextEditingController nomineePhoneController;
  final PickedPhoto? nomineePhoto;
  final VoidCallback onPickNomineePhoto;
  final VoidCallback onClearNomineePhoto;

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
            alternateMobileController: alternateMobileController,
            emailController: emailController,
            addressController: addressController,
            investorType: investorType,
            onTypeChanged: onTypeChanged,
            profilePhoto: profilePhoto,
            onPickProfilePhoto: onPickProfilePhoto,
            onClearProfilePhoto: onClearProfilePhoto,
          ),
          const SizedBox(height: 16),
          _LoginCredentialsCard(
            usernameController: usernameController,
            passwordController: passwordController,
          ),
          const SizedBox(height: 16),
          _InvestmentDetailsCard(
            amountController: amountController,
            investmentDate: investmentDate,
            onPickDate: onPickDate,
            formatDate: formatDate,
            frequencyOptions: frequencyOptions,
            selectedFrequency: selectedFrequency,
            onFrequencyChanged: onFrequencyChanged,
            monthOptions: monthOptions,
            selectedMonthOption: selectedMonthOption,
            onMonthOptionChanged: onMonthOptionChanged,
            customMonthsController: customMonthsController,
            intervalController: intervalController,
            advancePaymentController: advancePaymentController,
            paymentModeOptions: paymentModeOptions,
            selectedPaymentMode: selectedPaymentMode,
            onPaymentModeChanged: onPaymentModeChanged,
            paymentSchedule: paymentSchedule,
            formatCurrency: formatCurrency,
          ),
          const SizedBox(height: 16),
          AddInvestorAdditionalInformation(
            aadhaarController: aadhaarController,
            panController: panController,
            bankNameController: bankNameController,
            ifscController: ifscController,
            accountNumberController: accountNumberController,
            nomineeNameController: nomineeNameController,
            nomineeAddressController: nomineeAddressController,
            nomineeRelationship: nomineeRelationship,
            onNomineeRelationshipChanged: onNomineeRelationshipChanged,
            nomineeAadhaarController: nomineeAadhaarController,
            nomineePanController: nomineePanController,
            nomineeDateOfBirth: nomineeDateOfBirth,
            onPickNomineeDateOfBirth: onPickNomineeDateOfBirth,
            formatDate: formatDate,
            nomineePhoneController: nomineePhoneController,
            nomineePhoto: nomineePhoto,
            onPickNomineePhoto: onPickNomineePhoto,
            onClearNomineePhoto: onClearNomineePhoto,
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
    required this.alternateMobileController,
    required this.emailController,
    required this.addressController,
    required this.investorType,
    required this.onTypeChanged,
    this.profilePhoto,
    required this.onPickProfilePhoto,
    required this.onClearProfilePhoto,
  });

  final TextEditingController fullNameController;
  final TextEditingController organizationController;
  final TextEditingController mobileController;
  final TextEditingController alternateMobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final String? investorType;
  final ValueChanged<String?> onTypeChanged;
  final PickedPhoto? profilePhoto;
  final VoidCallback onPickProfilePhoto;
  final VoidCallback onClearProfilePhoto;

  String? _validateOptionalPhone(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return null;
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Basic Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddInvestorPhotoUploadBox(
            photo: profilePhoto,
            onPick: onPickProfilePhoto,
            onClear: onClearProfilePhoto,
          ),
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
                      child: _InvestorTypeDropdown(
                        value: investorType,
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
                      label: 'Alternate Phone Number',
                      child: AddInvestorTextInput(
                        controller: alternateMobileController,
                        hint: 'Enter alternate phone number',
                        keyboardType: TextInputType.phone,
                        validator: _validateOptionalPhone,
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
                          child: _InvestorTypeDropdown(
                            value: investorType,
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
                          label: 'Alternate Phone Number',
                          child: AddInvestorTextInput(
                            controller: alternateMobileController,
                            hint: 'Enter alternate phone number',
                            keyboardType: TextInputType.phone,
                            validator: _validateOptionalPhone,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                    ],
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
            },
          ),
        ],
      ),
    );
  }
}

class _InvestorTypeDropdown extends StatelessWidget {
  const _InvestorTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestorsCubit, InvestorsState>(
      listener: (context, state) {
        if (state is InvestorTypesFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final isLoading = state is InvestorTypesLoading ||
            (state is InvestorsInitial &&
                context.read<InvestorsCubit>().investorTypes.isEmpty);
        final types = (state is InvestorTypesSuccess
                ? state.types
                : context.read<InvestorsCubit>().investorTypes)
            .map((type) => type.investorTypeName)
            .where((name) => name.trim().isNotEmpty)
            .toList();

        if (isLoading) {
          return Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.newBorder, width: 1),
            ),
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return AddInvestorDropdownInput(
          value: value,
          hint: types.isEmpty
              ? 'No investor types available'
              : 'Select investor type',
          items: types,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _LoginCredentialsCard extends StatefulWidget {
  const _LoginCredentialsCard({
    required this.usernameController,
    required this.passwordController,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  State<_LoginCredentialsCard> createState() => _LoginCredentialsCardState();
}

class _LoginCredentialsCardState extends State<_LoginCredentialsCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Login Credentials',
      subtitle:
          'Create a username and password for this investor to access their account.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 560;
          final usernameField = AddInvestorLabeledField(
            label: 'Username',
            isRequired: true,
            child: AddInvestorTextInput(
              controller: widget.usernameController,
              hint: 'Enter username',
              validator: (value) {
                final username = value?.trim() ?? '';
                if (username.isEmpty) {
                  return 'Please enter username';
                }
                if (username.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
          );
          final passwordField = AddInvestorLabeledField(
            label: 'Password',
            isRequired: true,
            child: AddInvestorTextInput(
              controller: widget.passwordController,
              hint: 'Enter password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.hint,
                  size: 20,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) {
                  return 'Please enter password';
                }
                if (password.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          );

          if (!twoCol) {
            return Column(
              children: [
                usernameField,
                const SizedBox(height: 14),
                passwordField,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: usernameField),
              const SizedBox(width: 14),
              Expanded(child: passwordField),
            ],
          );
        },
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
    required this.frequencyOptions,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    required this.monthOptions,
    required this.selectedMonthOption,
    required this.onMonthOptionChanged,
    required this.customMonthsController,
    required this.intervalController,
    required this.advancePaymentController,
    required this.paymentModeOptions,
    required this.selectedPaymentMode,
    required this.onPaymentModeChanged,
    required this.paymentSchedule,
    required this.formatCurrency,
  });

  final TextEditingController amountController;
  final DateTime? investmentDate;
  final VoidCallback onPickDate;
  final String Function(DateTime) formatDate;
  final List<String> frequencyOptions;
  final String selectedFrequency;
  final ValueChanged<String?> onFrequencyChanged;
  final List<String> monthOptions;
  final String? selectedMonthOption;
  final ValueChanged<String?> onMonthOptionChanged;
  final TextEditingController customMonthsController;
  final TextEditingController intervalController;
  final TextEditingController advancePaymentController;
  final List<String> paymentModeOptions;
  final String? selectedPaymentMode;
  final ValueChanged<String?> onPaymentModeChanged;
  final List<PaymentScheduleInstallment> paymentSchedule;
  final String Function(double) formatCurrency;

  bool get _needsInterval =>
      selectedFrequency == 'Week' || selectedFrequency == 'Day';

  String get _installmentCountLabel =>
      selectedFrequency == 'Month' ? 'Number of Months' : 'Number of Installments';

  String get _intervalLabel =>
      selectedFrequency == 'Week' ? 'Week Gap' : 'Day Gap';

  String get _intervalHint => selectedFrequency == 'Week'
      ? 'Enter weeks between payments'
      : 'Enter days between payments';

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Investment Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
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
                  children: [
                    amountField,
                    const SizedBox(height: 14),
                    dateField,
                  ],
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
          const SizedBox(height: 18),
          const _SetDueDateSectionHeader(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 560;
              final frequencyField = AddInvestorLabeledField(
                label: 'Payment Frequency',
                isRequired: true,
                child: AddInvestorDropdownInput(
                  value: selectedFrequency,
                  hint: 'Select frequency',
                  items: frequencyOptions,
                  onChanged: onFrequencyChanged,
                ),
              );
              final countField = AddInvestorLabeledField(
                label: _installmentCountLabel,
                isRequired: true,
                child: AddInvestorDropdownInput(
                  value: selectedMonthOption,
                  hint: 'Select count',
                  items: monthOptions,
                  onChanged: onMonthOptionChanged,
                ),
              );
              final customField = AddInvestorLabeledField(
                label: 'Custom Installments',
                isRequired: true,
                child: AddInvestorTextInput(
                  controller: customMonthsController,
                  hint: 'Enter number of installments',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (selectedMonthOption != 'Custom') return null;
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) {
                      return 'Please enter number of installments';
                    }
                    final count = int.tryParse(raw);
                    if (count == null || count <= 0) {
                      return 'Enter a valid number greater than zero';
                    }
                    return null;
                  },
                ),
              );
              final intervalField = AddInvestorLabeledField(
                label: _intervalLabel,
                isRequired: true,
                child: AddInvestorTextInput(
                  controller: intervalController,
                  hint: _intervalHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (!_needsInterval) return null;
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) {
                      return selectedFrequency == 'Week'
                          ? 'Please enter week gap'
                          : 'Please enter day gap';
                    }
                    final interval = int.tryParse(raw);
                    if (interval == null || interval <= 0) {
                      return 'Enter a valid number greater than zero';
                    }
                    return null;
                  },
                ),
              );
              final advanceField = AddInvestorLabeledField(
                label: 'Advance Payment',
                child: AddInvestorTextInput(
                  controller: advancePaymentController,
                  hint: 'Enter advance amount (optional)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) return null;

                    final advance = double.tryParse(
                      raw.replaceAll(',', ''),
                    );
                    if (advance == null || advance < 0) {
                      return 'Enter a valid advance amount';
                    }

                    final investment = double.tryParse(
                      amountController.text.trim().replaceAll(',', ''),
                    );
                    if (investment != null && advance > investment) {
                      return 'Advance cannot exceed total investment';
                    }
                    return null;
                  },
                ),
              );
              final paymentModeField = AddInvestorLabeledField(
                label: 'Payment Mode',
                child: AddInvestorDropdownInput(
                  value: selectedPaymentMode,
                  hint: 'Select payment mode',
                  items: paymentModeOptions,
                  onChanged: onPaymentModeChanged,
                ),
              );

              final fields = <Widget>[
                frequencyField,
                countField,
                if (selectedMonthOption == 'Custom') customField,
                if (_needsInterval) intervalField,
                advanceField,
                paymentModeField,
              ];

              if (!twoCol) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      fields[i],
                    ],
                  ],
                );
              }

              final rows = <Widget>[];
              for (var i = 0; i < fields.length; i += 2) {
                if (i > 0) rows.add(const SizedBox(height: 14));
                if (i + 1 < fields.length) {
                  rows.add(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fields[i]),
                        const SizedBox(width: 14),
                        Expanded(child: fields[i + 1]),
                      ],
                    ),
                  );
                } else {
                  rows.add(fields[i]);
                }
              }
              return Column(children: rows);
            },
          ),
          if (selectedMonthOption == null) ...[
            const SizedBox(height: 8),
            Text(
              'Select the number of installments to generate the schedule.',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (paymentSchedule.isNotEmpty) ...[
            const SizedBox(height: 18),
            _PaymentScheduleTable(
              schedule: paymentSchedule,
              formatDate: formatDate,
              formatCurrency: formatCurrency,
            ),
          ] else if (selectedMonthOption != null) ...[
            const SizedBox(height: 12),
            Text(
              _scheduleEmptyHint(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _scheduleEmptyHint() {
    if (selectedMonthOption == 'Custom' &&
        customMonthsController.text.trim().isEmpty) {
      return 'Enter a custom installment count to preview the schedule.';
    }

    if (_needsInterval && intervalController.text.trim().isEmpty) {
      return selectedFrequency == 'Week'
          ? 'Enter a week gap to preview the schedule.'
          : 'Enter a day gap to preview the schedule.';
    }

    if (_needsInterval) {
      final interval = int.tryParse(intervalController.text.trim());
      if (interval == null || interval <= 0) {
        return 'Enter a valid interval greater than zero.';
      }
    }

    final investment = double.tryParse(
      amountController.text.trim().replaceAll(',', ''),
    );
    final advanceRaw = advancePaymentController.text.trim();
    final advance = advanceRaw.isEmpty
        ? 0.0
        : double.tryParse(advanceRaw.replaceAll(',', ''));

    if (investment == null || investment <= 0) {
      return 'Enter a valid investment amount to preview the schedule.';
    }
    if (advance == null || advance < 0) {
      return 'Enter a valid advance payment to preview the schedule.';
    }
    if (advance > investment) {
      return 'Advance payment cannot exceed total investment.';
    }
    if (advance == investment) {
      return 'Advance covers the full investment. No installments remain.';
    }
    return 'Enter a valid investment amount to preview the schedule.';
  }
}

class _SetDueDateSectionHeader extends StatelessWidget {
  const _SetDueDateSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Set Due Date / Split Payment',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Required. Choose Month, Week, or Day frequency. Week/Day gap is the gap between payments. Advance payment is optional.',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentScheduleTable extends StatelessWidget {
  const _PaymentScheduleTable({
    required this.schedule,
    required this.formatDate,
    required this.formatCurrency,
  });

  final List<PaymentScheduleInstallment> schedule;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payment Schedule',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${schedule.length} installments',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.newBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.sizeOf(context).width < 700
                    ? 520
                    : MediaQuery.sizeOf(context).width * 0.4,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.cardBg),
                headingRowHeight: 44,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 52,
                columnSpacing: 20,
                horizontalMargin: 14,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Due Date')),
                  DataColumn(label: Text('Installment')),
                  DataColumn(label: Text('Status')),
                ],
                rows: [
                  for (final item in schedule)
                    DataRow(
                      cells: [
                        DataCell(Text('${item.installmentNumber}')),
                        DataCell(Text(formatDate(item.dueDate))),
                        DataCell(Text(formatCurrency(item.installmentAmount))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.paymentStatus,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB86E00),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class AddInvestorPhotoUploadBox extends StatelessWidget {
  const AddInvestorPhotoUploadBox({
    super.key,
    this.photo,
    required this.onPick,
    required this.onClear,
    this.uploadLabel = 'Upload Profile Photo',
    this.changeLabel = 'Change Profile Photo',
  });

  final PickedPhoto? photo;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String uploadLabel;
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 10.h,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1F5),
                    borderRadius: BorderRadius.circular(24),
                    image: hasPhoto
                        ? DecorationImage(
                            image: MemoryImage(photo!.bytes),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: hasPhoto
                      ? null
                      : SvgPicture.asset(
                          ImageConstants.camera,
                          width: 4.h,
                          height: 4.h,
                        ),
                ),
                if (hasPhoto)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Material(
                      color: AppColors.white,
                      shape: const CircleBorder(),
                      elevation: 1,
                      child: InkWell(
                        onTap: onClear,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasPhoto ? changeLabel : uploadLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasPhoto ? photo!.name : 'JPEG, PNG (Max 2MB)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
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
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
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
    this.obscureText = false,
    this.suffixIcon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: addInvestorInputDecoration(hint).copyWith(
        suffixIcon: suffixIcon,
      ),
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
    _overlayEntry?.remove();
    _overlayEntry = null;
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
