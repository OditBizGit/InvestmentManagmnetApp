import 'package:dio/dio.dart';

class InvestorNomineeSubmitData {
  const InvestorNomineeSubmitData({
    this.nomineeId,
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

  final int? nomineeId;
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

  /// Existing nominees keep their API id; new nominees are sent as 0.
  int get resolvedNomineeId {
    final id = nomineeId;
    if (id == null || id <= 0) return 0;
    return id;
  }

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
    MapEntry(
      _registerNomineeIdKey(index),
      nominee.resolvedNomineeId.toString(),
    ),
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

  _addMultipartFile(formData, profileKey, nominee.profilePhoto);
  _addMultipartFile(formData, aadhaarKey, nominee.aadhaarCardImage);
  _addMultipartFile(formData, panKey, nominee.panCardImage);
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

String _registerNomineeIdKey(int index) {
  switch (index) {
    case 0:
      return 'NomineeId';
    case 1:
      return 'Nominee2Id';
    case 2:
      return 'Nominee3Id';
    default:
      return 'Nominee3Id';
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

/// UpdateInvestor: always send 3 nominee slots in API field names.
/// Empty slots use empty strings and NomineeId 0.
void appendUpdateInvestorNomineesToFormData(
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
    _appendUpdateNomineeSlot(formData, index, slots[index]);
  }
}

void _appendUpdateNomineeSlot(
  FormData formData,
  int index,
  InvestorNomineeSubmitData nominee,
) {
  final suffix = '${index + 1}';
  final idKey = index == 0 ? 'NomineeId' : 'NomineeId$suffix';

  formData.fields.addAll([
    MapEntry(idKey, nominee.resolvedNomineeId.toString()),
    MapEntry('NomineeName$suffix', nominee.name.trim()),
    MapEntry('NomineeRelationship$suffix', nominee.relationship.trim()),
    MapEntry('NomineeAddress$suffix', nominee.address.trim()),
    MapEntry(
      'NomineeDateOfBirth$suffix',
      nominee.dateOfBirth?.toIso8601String() ?? '',
    ),
    MapEntry('NomineeAadhaarNumber$suffix', nominee.aadhaarNumber.trim()),
    MapEntry('NomineePanCardNumber$suffix', nominee.panCardNumber.trim()),
    MapEntry('NomineePhoneNumber$suffix', nominee.phoneNumber.trim()),
  ]);

  _addMultipartFile(
    formData,
    'NomineeProfilePhoto$suffix',
    nominee.profilePhoto,
  );
  _addMultipartFile(
    formData,
    'NomineeAadhaarPhoto$suffix',
    nominee.aadhaarCardImage,
  );
  _addMultipartFile(
    formData,
    'NomineePanCardPhoto$suffix',
    nominee.panCardImage,
  );
}

void _addMultipartFile(
  FormData formData,
  String key,
  MultipartFile? file,
) {
  if (file == null) return;
  formData.files.add(MapEntry(key, file.clone()));
}
