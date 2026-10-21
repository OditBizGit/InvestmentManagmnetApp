import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/cubit/staff_allocation_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/model/create_staff_request_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

const staffDesignationOptions = [
  'Relationship Manager',
  'Financial Manager'
];

class AddStaffFormCard extends StatelessWidget {
  const AddStaffFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedDesignation,
    required this.onDesignationChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? selectedDesignation;
  final ValueChanged<String?> onDesignationChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AddInvestorSectionCard(
        title: 'Staff Details',
        subtitle: 'Add a team member to the system.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoCol = constraints.maxWidth >= 560;

            final fullNameField = AddInvestorLabeledField(
              label: 'Full Name',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: fullNameController,
                hint: 'Enter full name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
            );

            final designationField = AddInvestorLabeledField(
              label: 'Designation',
              isRequired: true,
              child: FormField<String>(
                validator: (_) {
                  if (selectedDesignation == null ||
                      selectedDesignation!.trim().isEmpty) {
                    return 'Designation is required';
                  }
                  return null;
                },
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddInvestorDropdownInput(
                        value: selectedDesignation,
                        hint: 'Select designation',
                        items: staffDesignationOptions,
                        onChanged: (value) {
                          field.didChange(value);
                          onDesignationChanged(value);
                        },
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );

            final emailField = AddInvestorLabeledField(
              label: 'Email',
              child: AddInvestorTextInput(
                controller: emailController,
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return null;
                  final isValid = RegExp(
                    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
                  ).hasMatch(email);
                  if (!isValid) return 'Enter a valid email address';
                  return null;
                },
              ),
            );

            final phoneField = AddInvestorLabeledField(
              label: 'Phone Number',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: phoneController,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (phone.isEmpty) return 'Phone number is required';
                  if (phone.length != 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
            );

            if (!twoCol) {
              return Column(
                children: [
                  fullNameField,
                  const SizedBox(height: 14),
                  designationField,
                  const SizedBox(height: 14),
                  emailField,
                  const SizedBox(height: 14),
                  phoneField,
                ],
              );
            }

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fullNameField),
                    const SizedBox(width: 14),
                    Expanded(child: designationField),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: emailField),
                    const SizedBox(width: 14),
                    Expanded(child: phoneField),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Listens for staff creation outcomes and shows toasts.
class AddStaffCreationListener extends StatelessWidget {
  const AddStaffCreationListener({
    super.key,
    required this.child,
    required this.onClearForm,
  });

  final Widget child;
  final VoidCallback onClearForm;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffAllocationCubit, StaffAllocationState>(
      listener: (context, state) {
        if (state is StaffAllocationCreateSuccess) {
          AppToast.success(
            state.message,
            title: 'Staff Added',
            context: context,
          );
          onClearForm();
        } else if (state is StaffAllocationCreateFailure) {
          AppToast.error(
            state.message,
            title: 'Add Staff',
            context: context,
          );
        } else if (state is StaffAllocationStaffLoadFailure) {
          AppToast.error(
            state.message,
            title: 'Staff List',
            context: context,
          );
        } else if (state is StaffAllocationInvestorsLoadFailure) {
          AppToast.error(
            state.message,
            title: 'Assigned Investors',
            context: context,
          );
        }
      },
      child: child,
    );
  }
}

/// Validates the form and dispatches [StaffAllocationCubit.createStaff].
void submitAddStaffForm({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController fullNameController,
  required TextEditingController emailController,
  required TextEditingController phoneController,
  required String? selectedDesignation,
}) {
  FocusScope.of(context).unfocus();

  final isValid = formKey.currentState?.validate() ?? false;
  if (!isValid) return;

  final cubit = context.read<StaffAllocationCubit>();
  final cubitState = cubit.state;
  if (cubitState is StaffAllocationStaffLoaded && cubitState.isCreating) {
    return;
  }

  final request = CreateStaffRequestModel(
    fullName: fullNameController.text.trim(),
    designation: selectedDesignation?.trim() ?? '',
    email: emailController.text.trim(),
    phoneNumber: phoneController.text.trim(),
    role: selectedDesignation?.trim() ?? '',
  );

  cubit.createStaff(request);
}

class AddStaffActionButtons extends StatelessWidget {
  const AddStaffActionButtons({
    super.key,
    required this.onClear,
    required this.onAdd,
    this.isLoading = false,
  });

  final VoidCallback onClear;
  final VoidCallback onAdd;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: isLoading ? null : onClear,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F0F3),
                foregroundColor: AppColors.textPrimary,
                disabledForegroundColor: AppColors.textMuted,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                disabledBackgroundColor:
                    AppColors.accent.withValues(alpha: 0.6),
                disabledForegroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Add Staff',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
