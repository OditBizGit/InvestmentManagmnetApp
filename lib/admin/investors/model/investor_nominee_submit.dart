import 'package:dio/dio.dart';

class InvestorNomineeSubmitData {
  const InvestorNomineeSubmitData({
    this.name = '',
    this.relationship = '',
    this.address = '',
    this.dateOfBirth,
    this.aadhaarNumber = '',
    this.panCardNumber = '',
    this.phoneNumber = '',
    this.profilePhoto,
    this.aadhaarCardImage,
    this.panCardImage,
  });

  final String name;
  final String relationship;
  final String address;
  final DateTime? dateOfBirth;
  final String aadhaarNumber;
  final String panCardNumber;
  final String phoneNumber;
  final MultipartFile? profilePhoto;
  final MultipartFile? aadhaarCardImage;
  final MultipartFile? panCardImage;

  bool get isEmpty {
    return name.trim().isEmpty &&
        relationship.trim().isEmpty &&
        address.trim().isEmpty &&
        dateOfBirth == null &&
        aadhaarNumber.trim().isEmpty &&
        panCardNumber.trim().isEmpty &&
        phoneNumber.trim().isEmpty &&
        profilePhoto == null &&
        aadhaarCardImage == null &&
        panCardImage == null;
  }
}

/// RegisterInvestor API: flat Nominee / Nominee2 / Nominee3 field names (max 3).
void appendRegisterInvestorNomineesToFormData(
  FormData formData,
  List<InvestorNomineeSubmitData> nominees,
) {
  final slots = List<InvestorNomineeSubmitData>.generate(
    3,
    (index) => index < nominees.length
        ? nominees[index]
        : const InvestorNomineeSubmitData(),
  );

  for (var index = 0; index < slots.length; index++) {
    _appendRegisterNomineeSlot(formData, index, slots[index]);
  }
}

void _appendRegisterNomineeSlot(
  FormData formData,
  int index,
  InvestorNomineeSubmitData nominee,
) {
  final prefix = _registerNomineeFieldPrefix(index);

  formData.fields.addAll([
    MapEntry('${prefix}Name', nominee.name.trim()),
    MapEntry('${prefix}Relationship', nominee.relationship.trim()),
    MapEntry('${prefix}Address', nominee.address.trim()),
    MapEntry(
      '${prefix}DateOfBirth',
      nominee.dateOfBirth?.toIso8601String() ?? '',
    ),
    MapEntry('${prefix}AadhaarNumber', nominee.aadhaarNumber.trim()),
    MapEntry('${prefix}PanCardNumber', nominee.panCardNumber.trim()),
    MapEntry('${prefix}PhoneNumber', nominee.phoneNumber.trim()),
  ]);

  final profileKey = _registerNomineeProfilePhotoKey(index);
  final aadhaarKey = _registerNomineeAadhaarPhotoKey(index);
  final panKey = _registerNomineePanPhotoKey(index);

  if (nominee.profilePhoto != null) {
    formData.files.add(MapEntry(profileKey, nominee.profilePhoto!));
  }
  if (nominee.aadhaarCardImage != null) {
    formData.files.add(MapEntry(aadhaarKey, nominee.aadhaarCardImage!));
  }
  if (nominee.panCardImage != null) {
    formData.files.add(MapEntry(panKey, nominee.panCardImage!));
  }
}

String _registerNomineeFieldPrefix(int index) {
  switch (index) {
    case 0:
      return 'Nominee';
    case 1:
      return 'Nominee2';
    case 2:
      return 'Nominee3';
    default:
      return 'Nominee3';
  }
}

String _registerNomineeProfilePhotoKey(int index) {
  switch (index) {
    case 0:
      return 'NomineeProfilePhoto';
    case 1:
      return 'Nominee2ProfilePhoto';
    case 2:
      return 'Nominee3ProfilePhoto';
    default:
      return 'Nominee3ProfilePhoto';
  }
}

String _registerNomineeAadhaarPhotoKey(int index) {
  switch (index) {
    case 0:
      return 'NomineeAadhaarPhoto';
    case 1:
      return 'Nominee2AadhaarPhoto';
    case 2:
      return 'Nominee3AadhaarPhoto';
    default:
      return 'Nominee3AadhaarPhoto';
  }
}

String _registerNomineePanPhotoKey(int index) {
  switch (index) {
    case 0:
      return 'NomineePanCardPhoto';
    case 1:
      return 'Nominee2PanCardPhoto';
    case 2:
      return 'Nominee3PanCardPhoto';
    default:
      return 'Nominee3PanCardPhoto';
  }
}

/// UpdateInvestor API (indexed nominee array — unchanged for edit flow).
void appendNomineesToFormData(
  FormData formData,
  List<InvestorNomineeSubmitData> nominees, {
  bool legacyPrimaryFields = true,
}) {
  for (var i = 0; i < nominees.length; i++) {
    _appendNomineeAtIndex(formData, i, nominees[i]);
  }

  if (!legacyPrimaryFields || nominees.isEmpty) return;

  final primary = nominees.first;
  _appendLegacyNomineeFields(formData, primary);
}

void _appendNomineeAtIndex(
  FormData formData,
  int index,
  InvestorNomineeSubmitData nominee,
) {
  final prefix = 'Nominees[$index]';

  formData.fields.addAll([
    MapEntry('$prefix.NomineeName', nominee.name),
    MapEntry('$prefix.NomineeRelationship', nominee.relationship),
    MapEntry('$prefix.NomineeAddress', nominee.address),
    MapEntry('$prefix.NomineeAadhaarNumber', nominee.aadhaarNumber),
    MapEntry('$prefix.NomineePanCardNumber', nominee.panCardNumber),
    MapEntry('$prefix.NomineePhoneNumber', nominee.phoneNumber),
    if (nominee.dateOfBirth != null)
      MapEntry(
        '$prefix.NomineeDateOfBirth',
        nominee.dateOfBirth!.toIso8601String(),
      ),
  ]);

  if (nominee.profilePhoto != null) {
    formData.files.add(
      MapEntry('$prefix.NomineeProfilePhoto', nominee.profilePhoto!),
    );
  }
  if (nominee.aadhaarCardImage != null) {
    formData.files.add(
      MapEntry('$prefix.NomineeAadhaarCardImage', nominee.aadhaarCardImage!),
    );
  }
  if (nominee.panCardImage != null) {
    formData.files.add(
      MapEntry('$prefix.NomineePanCardImage', nominee.panCardImage!),
    );
  }
}

void _appendLegacyNomineeFields(
  FormData formData,
  InvestorNomineeSubmitData nominee,
) {
  formData.fields.addAll([
    MapEntry('NomineeName', nominee.name),
    MapEntry('NomineeRelationship', nominee.relationship),
    MapEntry('NomineeAddress', nominee.address),
    MapEntry('NomineeAadhaarNumber', nominee.aadhaarNumber),
    MapEntry('NomineePanCardNumber', nominee.panCardNumber),
    MapEntry('NomineePhoneNumber', nominee.phoneNumber),
    if (nominee.dateOfBirth != null)
      MapEntry(
        'NomineeDateOfBirth',
        nominee.dateOfBirth!.toIso8601String(),
      ),
  ]);

  if (nominee.profilePhoto != null) {
    formData.files.add(
      MapEntry('NomineeProfilePhoto', nominee.profilePhoto!),
    );
  }
  if (nominee.aadhaarCardImage != null) {
    formData.files.add(
      MapEntry('NomineeAadhaarCardImage', nominee.aadhaarCardImage!),
    );
  }
  if (nominee.panCardImage != null) {
    formData.files.add(
      MapEntry('NomineePanCardImage', nominee.panCardImage!),
    );
  }
}
