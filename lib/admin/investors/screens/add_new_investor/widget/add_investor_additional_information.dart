import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';

/// Additional Information: Investor Bank & KYC + Nominee Details.
/// UI-only — not sent to the API yet.
class AddInvestorAdditionalInformation extends StatelessWidget {
  const AddInvestorAdditionalInformation({
    super.key,
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
    required this.formatDate,
    required this.nomineePhoneController,
    this.nomineePhoto,
    required this.onPickNomineePhoto,
    required this.onClearNomineePhoto,
  });

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
  final String Function(DateTime) formatDate;
  final TextEditingController nomineePhoneController;
  final PickedPhoto? nomineePhoto;
  final VoidCallback onPickNomineePhoto;
  final VoidCallback onClearNomineePhoto;

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
        _InvestorBankKycCard(
          aadhaarController: aadhaarController,
          panController: panController,
          bankNameController: bankNameController,
          ifscController: ifscController,
          accountNumberController: accountNumberController,
        ),
        const SizedBox(height: 16),
        _NomineeDetailsCard(
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
    );
  }
}

class _InvestorBankKycCard extends StatelessWidget {
  const _InvestorBankKycCard({
    required this.aadhaarController,
    required this.panController,
    required this.bankNameController,
    required this.ifscController,
    required this.accountNumberController,
  });

  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final TextEditingController bankNameController;
  final TextEditingController ifscController;
  final TextEditingController accountNumberController;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Investor Bank & KYC Details',
      subtitle:
          'Optional identity and bank details for records. Format is validated when provided.',
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

class _NomineeDetailsCard extends StatelessWidget {
  const _NomineeDetailsCard({
    required this.nomineeNameController,
    required this.nomineeAddressController,
    required this.nomineeRelationship,
    required this.onNomineeRelationshipChanged,
    required this.nomineeAadhaarController,
    required this.nomineePanController,
    required this.nomineeDateOfBirth,
    required this.onPickNomineeDateOfBirth,
    required this.formatDate,
    required this.nomineePhoneController,
    this.nomineePhoto,
    required this.onPickNomineePhoto,
    required this.onClearNomineePhoto,
  });

  final TextEditingController nomineeNameController;
  final TextEditingController nomineeAddressController;
  final String? nomineeRelationship;
  final ValueChanged<String?> onNomineeRelationshipChanged;
  final TextEditingController nomineeAadhaarController;
  final TextEditingController nomineePanController;
  final DateTime? nomineeDateOfBirth;
  final VoidCallback onPickNomineeDateOfBirth;
  final String Function(DateTime) formatDate;
  final TextEditingController nomineePhoneController;
  final PickedPhoto? nomineePhoto;
  final VoidCallback onPickNomineePhoto;
  final VoidCallback onClearNomineePhoto;

  String? _validateOptionalPhone(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return null;
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: 'Nominee Details',
      subtitle:
          'Optional nominee information. Leave blank if not applicable.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddInvestorPhotoUploadBox(
            photo: nomineePhoto,
            onPick: onPickNomineePhoto,
            onClear: onClearNomineePhoto,
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
                    controller: nomineeNameController,
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
                    value: nomineeRelationship,
                    hint: 'Select relationship',
                    items: AddInvestorAdditionalInformation.relationshipOptions,
                    onChanged: onNomineeRelationshipChanged,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Phone Number',
                  child: AddInvestorTextInput(
                    controller: nomineePhoneController,
                    hint: 'Enter nominee phone number',
                    keyboardType: TextInputType.phone,
                    validator: _validateOptionalPhone,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Date of Birth',
                  child: AddInvestorDateInput(
                    value: nomineeDateOfBirth == null
                        ? null
                        : formatDate(nomineeDateOfBirth!),
                    hint: 'Select Date',
                    onTap: onPickNomineeDateOfBirth,
                  ),
                ),
                AddInvestorLabeledField(
                  label: 'Address',
                  child: AddInvestorTextInput(
                    controller: nomineeAddressController,
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
                    controller: nomineeAadhaarController,
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
                    controller: nomineePanController,
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

              return _ResponsiveFieldGrid(twoCol: twoCol, fields: fields);
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
