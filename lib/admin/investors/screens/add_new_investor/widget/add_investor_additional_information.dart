import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_entry.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

/// Additional Information: Banking, KYC, and Nominee Details.
class AddInvestorAdditionalInformation extends StatelessWidget {
  const AddInvestorAdditionalInformation({
    super.key,
    required this.aadhaarController,
    required this.panController,
    required this.bankNameController,
    required this.ifscController,
    required this.accountNumberController,
    this.aadhaarCardPhoto,
    this.existingAadhaarCardImageUrl,
    required this.onPickAadhaarCardPhoto,
    required this.onClearAadhaarCardPhoto,
    this.panCardPhoto,
    this.existingPanCardImageUrl,
    required this.onPickPanCardPhoto,
    required this.onClearPanCardPhoto,
    required this.nominees,
    required this.onAddNominee,
    required this.onRemoveNominee,
    required this.onNomineeRelationshipChanged,
    required this.onPickNomineeDateOfBirth,
    required this.formatDate,
    required this.onPickNomineeProfilePhoto,
    required this.onClearNomineeProfilePhoto,
    required this.onPickNomineeAadhaarCardPhoto,
    required this.onClearNomineeAadhaarCardPhoto,
    required this.onPickNomineePanCardPhoto,
    required this.onClearNomineePanCardPhoto,
  });

  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final TextEditingController bankNameController;
  final TextEditingController ifscController;
  final TextEditingController accountNumberController;
  final PickedPhoto? aadhaarCardPhoto;
  final String? existingAadhaarCardImageUrl;
  final VoidCallback onPickAadhaarCardPhoto;
  final VoidCallback onClearAadhaarCardPhoto;
  final PickedPhoto? panCardPhoto;
  final String? existingPanCardImageUrl;
  final VoidCallback onPickPanCardPhoto;
  final VoidCallback onClearPanCardPhoto;
  final List<InvestorNomineeEntry> nominees;
  final VoidCallback onAddNominee;
  final ValueChanged<int> onRemoveNominee;
  final void Function(int index, String? value) onNomineeRelationshipChanged;
  final ValueChanged<int> onPickNomineeDateOfBirth;
  final String Function(DateTime) formatDate;
  final ValueChanged<int> onPickNomineeProfilePhoto;
  final ValueChanged<int> onClearNomineeProfilePhoto;
  final ValueChanged<int> onPickNomineeAadhaarCardPhoto;
  final ValueChanged<int> onClearNomineeAadhaarCardPhoto;
  final ValueChanged<int> onPickNomineePanCardPhoto;
  final ValueChanged<int> onClearNomineePanCardPhoto;

  static const relationshipOptions = [
    'Spouse',
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InvestorBankingDetailsCard(
          bankNameController: bankNameController,
          ifscController: ifscController,
          accountNumberController: accountNumberController,
        ),
        const SizedBox(height: 16),
        _InvestorKycDetailsCard(
          aadhaarController: aadhaarController,
          panController: panController,
          aadhaarCardPhoto: aadhaarCardPhoto,
          existingAadhaarCardImageUrl: existingAadhaarCardImageUrl,
          onPickAadhaarCardPhoto: onPickAadhaarCardPhoto,
          onClearAadhaarCardPhoto: onClearAadhaarCardPhoto,
          panCardPhoto: panCardPhoto,
          existingPanCardImageUrl: existingPanCardImageUrl,
          onPickPanCardPhoto: onPickPanCardPhoto,
          onClearPanCardPhoto: onClearPanCardPhoto,
        ),
        const SizedBox(height: 16),
        _NomineesSectionCard(
          nominees: nominees,
          onAddNominee: onAddNominee,
          onRemoveNominee: onRemoveNominee,
          onNomineeRelationshipChanged: onNomineeRelationshipChanged,
          onPickNomineeDateOfBirth: onPickNomineeDateOfBirth,
          formatDate: formatDate,
          onPickNomineeProfilePhoto: onPickNomineeProfilePhoto,
          onClearNomineeProfilePhoto: onClearNomineeProfilePhoto,
          onPickNomineeAadhaarCardPhoto: onPickNomineeAadhaarCardPhoto,
          onClearNomineeAadhaarCardPhoto: onClearNomineeAadhaarCardPhoto,
          onPickNomineePanCardPhoto: onPickNomineePanCardPhoto,
          onClearNomineePanCardPhoto: onClearNomineePanCardPhoto,
        ),
      ],
    );
  }
}

class _InvestorBankingDetailsCard extends StatelessWidget {
  const _InvestorBankingDetailsCard({
    required this.bankNameController,
    required this.ifscController,
    required this.accountNumberController,
  });

  final TextEditingController bankNameController;
  final TextEditingController ifscController;
  final TextEditingController accountNumberController;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Investor Banking Details',
      subtitle:
          'Optional bank account information. Format is validated when provided.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 560;
          final fields = [
            AddInvestorLabeledField(
              label: 'Bank Name',
              child: AddInvestorTextInput(
                controller: bankNameController,
                hint: 'Enter bank name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  if (raw.length < 2) {
                    return 'Enter a valid bank name';
                  }
                  return null;
                },
              ),
            ),
            AddInvestorLabeledField(
              label: 'IFSC Code',
              child: AddInvestorTextInput(
                controller: ifscController,
                hint: 'Enter 11-character IFSC code',
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(11),
                  _UpperCaseTextFormatter(),
                ],
                validator: _validateIfsc,
              ),
            ),
            AddInvestorLabeledField(
              label: 'Account Number',
              child: AddInvestorTextInput(
                controller: accountNumberController,
                hint: 'Enter bank account number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  if (raw.length < 9) {
                    return 'Enter a valid account number';
                  }
                  return null;
                },
              ),
            ),
          ];

          return _ResponsiveFieldGrid(twoCol: twoCol, fields: fields);
        },
      ),
    );
  }
}

class _InvestorKycDetailsCard extends StatelessWidget {
  const _InvestorKycDetailsCard({
    required this.aadhaarController,
    required this.panController,
    this.aadhaarCardPhoto,
    this.existingAadhaarCardImageUrl,
    required this.onPickAadhaarCardPhoto,
    required this.onClearAadhaarCardPhoto,
    this.panCardPhoto,
    this.existingPanCardImageUrl,
    required this.onPickPanCardPhoto,
    required this.onClearPanCardPhoto,
  });

  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final PickedPhoto? aadhaarCardPhoto;
  final String? existingAadhaarCardImageUrl;
  final VoidCallback onPickAadhaarCardPhoto;
  final VoidCallback onClearAadhaarCardPhoto;
  final PickedPhoto? panCardPhoto;
  final String? existingPanCardImageUrl;
  final VoidCallback onPickPanCardPhoto;
  final VoidCallback onClearPanCardPhoto;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Investor KYC Details',
      subtitle:
          'Optional identity details and document uploads. Format is validated when provided.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 560;
          final fields = [
            AddInvestorLabeledField(
              label: 'Aadhaar Card Number',
              child: AddInvestorTextInput(
                controller: aadhaarController,
                hint: 'Enter 12-digit Aadhaar number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: _validateAadhaar,
              ),
            ),
            AddInvestorLabeledField(
              label: 'PAN Card Number',
              child: AddInvestorTextInput(
                controller: panController,
                hint: 'Enter PAN (e.g. ABCDE1234F)',
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                  _UpperCaseTextFormatter(),
                ],
                validator: _validatePan,
              ),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResponsiveFieldGrid(twoCol: twoCol, fields: fields),
              const SizedBox(height: 20),
              if (twoCol)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AddInvestorPhotoUploadBox(
                        photo: aadhaarCardPhoto,
                        existingImageUrl: existingAadhaarCardImageUrl,
                        onPick: onPickAadhaarCardPhoto,
                        onClear: onClearAadhaarCardPhoto,
                        uploadLabel: 'Upload Aadhaar Card',
                        changeLabel: 'Change Aadhaar Card',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AddInvestorPhotoUploadBox(
                        photo: panCardPhoto,
                        existingImageUrl: existingPanCardImageUrl,
                        onPick: onPickPanCardPhoto,
                        onClear: onClearPanCardPhoto,
                        uploadLabel: 'Upload PAN Card',
                        changeLabel: 'Change PAN Card',
                      ),
                    ),
                  ],
                )
              else ...[
                AddInvestorPhotoUploadBox(
                  photo: aadhaarCardPhoto,
                  existingImageUrl: existingAadhaarCardImageUrl,
                  onPick: onPickAadhaarCardPhoto,
                  onClear: onClearAadhaarCardPhoto,
                  uploadLabel: 'Upload Aadhaar Card',
                  changeLabel: 'Change Aadhaar Card',
                ),
                const SizedBox(height: 16),
                AddInvestorPhotoUploadBox(
                  photo: panCardPhoto,
                  existingImageUrl: existingPanCardImageUrl,
                  onPick: onPickPanCardPhoto,
                  onClear: onClearPanCardPhoto,
                  uploadLabel: 'Upload PAN Card',
                  changeLabel: 'Change PAN Card',
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NomineesSectionCard extends StatelessWidget {
  const _NomineesSectionCard({
    required this.nominees,
    required this.onAddNominee,
    required this.onRemoveNominee,
    required this.onNomineeRelationshipChanged,
    required this.onPickNomineeDateOfBirth,
    required this.formatDate,
    required this.onPickNomineeProfilePhoto,
    required this.onClearNomineeProfilePhoto,
    required this.onPickNomineeAadhaarCardPhoto,
    required this.onClearNomineeAadhaarCardPhoto,
    required this.onPickNomineePanCardPhoto,
    required this.onClearNomineePanCardPhoto,
  });

  final List<InvestorNomineeEntry> nominees;
  final VoidCallback onAddNominee;
  final ValueChanged<int> onRemoveNominee;
  final void Function(int index, String? value) onNomineeRelationshipChanged;
  final ValueChanged<int> onPickNomineeDateOfBirth;
  final String Function(DateTime) formatDate;
  final ValueChanged<int> onPickNomineeProfilePhoto;
  final ValueChanged<int> onClearNomineeProfilePhoto;
  final ValueChanged<int> onPickNomineeAadhaarCardPhoto;
  final ValueChanged<int> onClearNomineeAadhaarCardPhoto;
  final ValueChanged<int> onPickNomineePanCardPhoto;
  final ValueChanged<int> onClearNomineePanCardPhoto;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Nominee Details',
      subtitle:
          'Add up to 3 nominees. Fields are optional unless you start filling a nominee.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < nominees.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _NomineeEntryBlock(
              index: i,
              totalCount: nominees.length,
              entry: nominees[i],
              formatDate: formatDate,
              onRemove: () => onRemoveNominee(i),
              onRelationshipChanged: (value) =>
                  onNomineeRelationshipChanged(i, value),
              onPickDateOfBirth: () => onPickNomineeDateOfBirth(i),
              onPickProfilePhoto: () => onPickNomineeProfilePhoto(i),
              onClearProfilePhoto: () => onClearNomineeProfilePhoto(i),
              onPickAadhaarCardPhoto: () => onPickNomineeAadhaarCardPhoto(i),
              onClearAadhaarCardPhoto: () => onClearNomineeAadhaarCardPhoto(i),
              onPickPanCardPhoto: () => onPickNomineePanCardPhoto(i),
              onClearPanCardPhoto: () => onClearNomineePanCardPhoto(i),
            ),
          ],
          if (nominees.length < 3) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAddNominee,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add Another Nominee (${nominees.length}/3)',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NomineeEntryBlock extends StatelessWidget {
  const _NomineeEntryBlock({
    required this.index,
    required this.totalCount,
    required this.entry,
    required this.formatDate,
    required this.onRemove,
    required this.onRelationshipChanged,
    required this.onPickDateOfBirth,
    required this.onPickProfilePhoto,
    required this.onClearProfilePhoto,
    required this.onPickAadhaarCardPhoto,
    required this.onClearAadhaarCardPhoto,
    required this.onPickPanCardPhoto,
    required this.onClearPanCardPhoto,
  });

  final int index;
  final int totalCount;
  final InvestorNomineeEntry entry;
  final String Function(DateTime) formatDate;
  final VoidCallback onRemove;
  final ValueChanged<String?> onRelationshipChanged;
  final VoidCallback onPickDateOfBirth;
  final VoidCallback onPickProfilePhoto;
  final VoidCallback onClearProfilePhoto;
  final VoidCallback onPickAadhaarCardPhoto;
  final VoidCallback onClearAadhaarCardPhoto;
  final VoidCallback onPickPanCardPhoto;
  final VoidCallback onClearPanCardPhoto;

  static final _phoneInputFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  String? _validateOptionalPhone(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return null;
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.newBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nominee ${index + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (totalCount > 1)
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(
                    'Remove',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AddInvestorPhotoUploadBox(
            photo: entry.profilePhoto,
            existingImageUrl: entry.existingProfileImageUrl,
            onPick: onPickProfilePhoto,
            onClear: onClearProfilePhoto,
            uploadLabel: 'Upload Nominee Photo',
            changeLabel: 'Change Nominee Photo',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 560;
              final fields = [
                AddInvestorLabeledField(
                  label: 'Nominee Name',
                  child: AddInvestorTextInput(
                    controller: entry.nameController,
                    hint: 'Enter nominee name',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      final raw = value?.trim() ?? '';
                      if (raw.isEmpty) return null;
                      if (raw.length < 2) {
                        return 'Enter a valid nominee name';
                      }
                      return null;
                    },
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Relationship',
                  child: AddInvestorDropdownInput(
                    value: entry.relationship,
                    hint: 'Select relationship',
                    items: AddInvestorAdditionalInformation.relationshipOptions,
                    onChanged: onRelationshipChanged,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Phone Number',
                  child: AddInvestorTextInput(
                    controller: entry.phoneController,
                    hint: 'Enter nominee phone number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: _phoneInputFormatters,
                    validator: _validateOptionalPhone,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Date of Birth',
                  child: AddInvestorDateInput(
                    value: entry.dateOfBirth == null
                        ? null
                        : formatDate(entry.dateOfBirth!),
                    hint: 'Select Date',
                    onTap: onPickDateOfBirth,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Address',
                  child: AddInvestorTextInput(
                    controller: entry.addressController,
                    hint: 'Enter nominee address',
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    validator: (value) {
                      final raw = value?.trim() ?? '';
                      if (raw.isEmpty) return null;
                      if (raw.length < 5) {
                        return 'Enter a valid address';
                      }
                      return null;
                    },
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Aadhaar Card Number',
                  child: AddInvestorTextInput(
                    controller: entry.aadhaarController,
                    hint: 'Enter 12-digit Aadhaar number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: _validateAadhaar,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'PAN Card Number',
                  child: AddInvestorTextInput(
                    controller: entry.panController,
                    hint: 'Enter PAN (e.g. ABCDE1234F)',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                      _UpperCaseTextFormatter(),
                    ],
                    validator: _validatePan,
                  ),
                ),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResponsiveFieldGrid(twoCol: twoCol, fields: fields),
                  const SizedBox(height: 20),
                  if (twoCol)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AddInvestorPhotoUploadBox(
                            photo: entry.aadhaarCardPhoto,
                            existingImageUrl: entry.existingAadhaarCardImageUrl,
                            onPick: onPickAadhaarCardPhoto,
                            onClear: onClearAadhaarCardPhoto,
                            uploadLabel: 'Upload Nominee Aadhaar',
                            changeLabel: 'Change Nominee Aadhaar',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AddInvestorPhotoUploadBox(
                            photo: entry.panCardPhoto,
                            existingImageUrl: entry.existingPanCardImageUrl,
                            onPick: onPickPanCardPhoto,
                            onClear: onClearPanCardPhoto,
                            uploadLabel: 'Upload Nominee PAN',
                            changeLabel: 'Change Nominee PAN',
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AddInvestorPhotoUploadBox(
                      photo: entry.aadhaarCardPhoto,
                      existingImageUrl: entry.existingAadhaarCardImageUrl,
                      onPick: onPickAadhaarCardPhoto,
                      onClear: onClearAadhaarCardPhoto,
                      uploadLabel: 'Upload Nominee Aadhaar',
                      changeLabel: 'Change Nominee Aadhaar',
                    ),
                    const SizedBox(height: 16),
                    AddInvestorPhotoUploadBox(
                      photo: entry.panCardPhoto,
                      existingImageUrl: entry.existingPanCardImageUrl,
                      onPick: onPickPanCardPhoto,
                      onClear: onClearPanCardPhoto,
                      uploadLabel: 'Upload Nominee PAN',
                      changeLabel: 'Change Nominee PAN',
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({
    required this.twoCol,
    required this.fields,
  });

  final bool twoCol;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
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
  }
}

String? _validateAadhaar(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  if (raw.length != 12) {
    return 'Aadhaar must be 12 digits';
  }
  return null;
}

String? _validatePan(String? value) {
  final raw = value?.trim().toUpperCase() ?? '';
  if (raw.isEmpty) return null;
  final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  if (!panRegex.hasMatch(raw)) {
    return 'Enter a valid PAN (e.g. ABCDE1234F)';
  }
  return null;
}

String? _validateIfsc(String? value) {
  final raw = value?.trim().toUpperCase() ?? '';
  if (raw.isEmpty) return null;
  final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  if (!ifscRegex.hasMatch(raw)) {
    return 'Enter a valid 11-character IFSC code';
  }
  return null;
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
