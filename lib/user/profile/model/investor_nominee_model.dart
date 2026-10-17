import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/core/utils/string_extensions.dart';

class InvestorNomineeModel {
  const InvestorNomineeModel({
    this.nomineeId,
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineeAddress,
    this.nomineeDateOfBirth,
    this.nomineeAadhaarNumber,
    this.nomineePanCardNumber,
    this.nomineePhoneNumber,
    this.nomineeProfilePhoto,
    this.nomineeAadhaarPhoto,
    this.nomineePanCardPhoto,
  });

  final int? nomineeId;
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineeAddress;
  final DateTime? nomineeDateOfBirth;
  final String? nomineeAadhaarNumber;
  final String? nomineePanCardNumber;
  final String? nomineePhoneNumber;
  final String? nomineeProfilePhoto;
  final String? nomineeAadhaarPhoto;
  final String? nomineePanCardPhoto;

  String? get nomineeProfilePhotoUrl => resolveMediaUrl(nomineeProfilePhoto);

  String? get nomineeAadhaarPhotoUrl => resolveMediaUrl(nomineeAadhaarPhoto);

  String? get nomineePanCardPhotoUrl => resolveMediaUrl(nomineePanCardPhoto);

  bool get isEmpty {
    return (nomineeName?.trim().isEmpty ?? true) &&
        (nomineeRelationship?.trim().isEmpty ?? true) &&
        (nomineeAddress?.trim().isEmpty ?? true) &&
        nomineeDateOfBirth == null &&
        (nomineeAadhaarNumber?.trim().isEmpty ?? true) &&
        (nomineePanCardNumber?.trim().isEmpty ?? true) &&
        (nomineePhoneNumber?.trim().isEmpty ?? true) &&
        (nomineeProfilePhoto?.trim().isEmpty ?? true) &&
        (nomineeAadhaarPhoto?.trim().isEmpty ?? true) &&
        (nomineePanCardPhoto?.trim().isEmpty ?? true);
  }

  factory InvestorNomineeModel.fromJson(Map<String, dynamic> json) {
    return InvestorNomineeModel(
      nomineeId: _readNullableInt(json['nomineeId'] ?? json['NomineeId']),
      nomineeName: _readName(
        json['nomineeName'] ?? json['NomineeName'] ?? json['name'] ?? json['Name'],
      ),
      nomineeRelationship: _readString(
        json['nomineeRelationship'] ??
            json['NomineeRelationship'] ??
            json['relationship'] ??
            json['Relationship'],
      ),
      nomineeAddress: _readString(
        json['nomineeAddress'] ??
            json['NomineeAddress'] ??
            json['address'] ??
            json['Address'],
      ),
      nomineeDateOfBirth: _readDate(
        json['nomineeDateOfBirth'] ??
            json['NomineeDateOfBirth'] ??
            json['dateOfBirth'] ??
            json['DateOfBirth'],
      ),
      nomineeAadhaarNumber: _readString(
        json['nomineeAadhaarNumber'] ??
            json['NomineeAadhaarNumber'] ??
            json['aadhaarNumber'] ??
            json['AadhaarNumber'],
      ),
      nomineePanCardNumber: _readString(
        json['nomineePanCardNumber'] ??
            json['NomineePanCardNumber'] ??
            json['panCardNumber'] ??
            json['PanCardNumber'],
      ),
      nomineePhoneNumber: _readString(
        json['nomineePhoneNumber'] ??
            json['NomineePhoneNumber'] ??
            json['phoneNumber'] ??
            json['PhoneNumber'],
      ),
      nomineeProfilePhoto: _readString(
        json['nomineeProfilePhoto'] ??
            json['NomineeProfilePhoto'] ??
            json['profilePhoto'] ??
            json['ProfilePhoto'],
      ),
      nomineeAadhaarPhoto: _readString(
        json['nomineeAadhaarPhoto'] ??
            json['NomineeAadhaarPhoto'] ??
            json['nomineeAadhaarCardImage'] ??
            json['NomineeAadhaarCardImage'],
      ),
      nomineePanCardPhoto: _readString(
        json['nomineePanCardPhoto'] ??
            json['NomineePanCardPhoto'] ??
            json['nomineePanCardImage'] ??
            json['NomineePanCardImage'],
      ),
    );
  }

  /// Older responses kept one nominee as flat fields on the investor object.
  factory InvestorNomineeModel.fromFlatInvestor(Map<String, dynamic> json) {
    return InvestorNomineeModel(
      nomineeName: _readName(json['nomineeName'] ?? json['NomineeName']),
      nomineeRelationship: _readString(
        json['nomineeRelationship'] ?? json['NomineeRelationship'],
      ),
      nomineeAddress: _readString(
        json['nomineeAddress'] ?? json['NomineeAddress'],
      ),
      nomineeDateOfBirth: _readDate(
        json['nomineeDateOfBirth'] ?? json['NomineeDateOfBirth'],
      ),
      nomineeAadhaarNumber: _readString(
        json['nomineeAadhaarNumber'] ?? json['NomineeAadhaarNumber'],
      ),
      nomineePanCardNumber: _readString(
        json['nomineePanCardNumber'] ?? json['NomineePanCardNumber'],
      ),
      nomineePhoneNumber: _readString(
        json['nomineePhoneNumber'] ?? json['NomineePhoneNumber'],
      ),
      nomineeProfilePhoto: _readString(
        json['nomineeProfilePhoto'] ?? json['NomineeProfilePhoto'],
      ),
      nomineeAadhaarPhoto: _readString(
        json['nomineeAadhaarPhoto'] ??
            json['NomineeAadhaarPhoto'] ??
            json['nomineeAadhaarCardImage'] ??
            json['NomineeAadhaarCardImage'],
      ),
      nomineePanCardPhoto: _readString(
        json['nomineePanCardPhoto'] ??
            json['NomineePanCardPhoto'] ??
            json['nomineePanCardImage'] ??
            json['NomineePanCardImage'],
      ),
    );
  }

  static String? _readName(dynamic value) {
    final text = _readString(value);
    return text?.toTitleCase;
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
