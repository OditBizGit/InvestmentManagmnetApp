import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class CreateAdminFormCard extends StatefulWidget {
  const CreateAdminFormCard({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.alternativePhoneController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController alternativePhoneController;

  @override
  State<CreateAdminFormCard> createState() => _CreateAdminFormCardState();
}

class _CreateAdminFormCardState extends State<CreateAdminFormCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: AddInvestorSectionCard(
        title: 'Admin Details',
        subtitle:
            'Username, password, and full name are required. Contact details are optional.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoCol = constraints.maxWidth >= 560;

            final fullNameField = AddInvestorLabeledField(
              label: 'Full Name',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: widget.fullNameController,
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

            final usernameField = AddInvestorLabeledField(
              label: 'Username',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: widget.usernameController,
                hint: 'Enter username',
                validator: (value) {
                  final username = value?.trim() ?? '';
                  if (username.isEmpty) return 'Username is required';
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
                  if (password.isEmpty) return 'Password is required';
                  if (password.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            );

            final emailField = AddInvestorLabeledField(
              label: 'Email',
              child: AddInvestorTextInput(
                controller: widget.emailController,
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
              child: AddInvestorTextInput(
                controller: widget.phoneController,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (phone.isEmpty) return null;
                  if (phone.length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            );

            final altPhoneField = AddInvestorLabeledField(
              label: 'Alternative Number',
              child: AddInvestorTextInput(
                controller: widget.alternativePhoneController,
                hint: 'Enter alternative number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (phone.isEmpty) return null;
                  if (phone.length < 10) {
                    return 'Enter a valid phone number';
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
                  usernameField,
                  const SizedBox(height: 14),
                  passwordField,
                  const SizedBox(height: 14),
                  emailField,
                  const SizedBox(height: 14),
                  phoneField,
                  const SizedBox(height: 14),
                  altPhoneField,
                ],
              );
            }

            return Column(
              children: [
                fullNameField,
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: usernameField),
                    const SizedBox(width: 14),
                    Expanded(child: passwordField),
                  ],
                ),
                const SizedBox(height: 14),
                emailField,
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: phoneField),
                    const SizedBox(width: 14),
                    Expanded(child: altPhoneField),
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

class CreateAdminSidePanel extends StatelessWidget {
  const CreateAdminSidePanel({
    super.key,
    required this.onCancel,
    required this.onCreate,
    this.isLoading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CreateAdminNotesCard(),
        const SizedBox(height: 16),
        CreateAdminActionButtons(
          onCancel: onCancel,
          onCreate: onCreate,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class CreateAdminNotesCard extends StatelessWidget {
  const CreateAdminNotesCard({
    super.key,
    this.matchFormHeight = false,
  });

  final bool matchFormHeight;

  static const _notes = [
    'All mandatory fields are marked with *',
    'Username, password, and full name are required',
    'Email, phone, and alternative number are optional',
    'Choose a unique username that is easy to remember',
    'Password must be at least 6 characters',
    'Use a strong password for admin account security',
    'Cancel discards unsaved changes and returns to Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final notesList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in _notes) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  note,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
            'Notes',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (matchFormHeight)
            Expanded(child: SingleChildScrollView(child: notesList))
          else
            notesList,
        ],
      ),
    );
  }
}

class CreateAdminActionButtons extends StatelessWidget {
  const CreateAdminActionButtons({
    super.key,
    required this.onCancel,
    required this.onCreate,
    this.isLoading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
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
                'Cancel',
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
              onPressed: isLoading ? null : onCreate,
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
                      'Create Admin',
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
