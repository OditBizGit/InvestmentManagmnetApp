import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

/// Nominee data from API (flat or list item).
class InvestorNomineeRecord {
  const InvestorNomineeRecord({
    this.nomineeId,
    this.name,
    this.relationship,
    this.address,
    this.dateOfBirth,
    this.aadhaarNumber,
    this.panCardNumber,
    this.phoneNumber,
    this.profilePhoto,
    this.aadhaarCardImage,
    this.panCardImage,
  });

  final int? nomineeId;
  final String? name;
  final String? relationship;
  final String? address;
  final DateTime? dateOfBirth;
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? phoneNumber;
  final String? profilePhoto;
  final String? aadhaarCardImage;
  final String? panCardImage;

  String? get profilePhotoUrl => resolveMediaUrl(profilePhoto);
  String? get aadhaarCardImageUrl => resolveMediaUrl(aadhaarCardImage);
  String? get panCardImageUrl => resolveMediaUrl(panCardImage);

  bool get isEmpty {
    return (name?.trim().isEmpty ?? true) &&
        (relationship?.trim().isEmpty ?? true) &&
        (address?.trim().isEmpty ?? true) &&
        dateOfBirth == null &&
        (aadhaarNumber?.trim().isEmpty ?? true) &&
        (panCardNumber?.trim().isEmpty ?? true) &&
        (phoneNumber?.trim().isEmpty ?? true) &&
        (profilePhoto?.trim().isEmpty ?? true) &&
        (aadhaarCardImage?.trim().isEmpty ?? true) &&
        (panCardImage?.trim().isEmpty ?? true);
  }

  factory InvestorNomineeRecord.fromJson(Map<String, dynamic> json) {
    return InvestorNomineeRecord(
      nomineeId: _readInt(
        json['nomineeId'] ??
            json['NomineeId'] ??
            json['id'] ??
            json['Id'],
      ),
      name: _readString(
        json['nomineeName'] ??
            json['NomineeName'] ??
            json['name'] ??
            json['Name'],
      ),
      relationship: _readString(
        json['nomineeRelationship'] ??
            json['NomineeRelationship'] ??
            json['relationship'] ??
            json['Relationship'],
      ),
      address: _readString(
        json['nomineeAddress'] ??
            json['NomineeAddress'] ??
            json['address'] ??
            json['Address'],
      ),
      dateOfBirth: _readDate(
        json['nomineeDateOfBirth'] ??
            json['NomineeDateOfBirth'] ??
            json['dateOfBirth'] ??
            json['DateOfBirth'],
      ),
      aadhaarNumber: _readString(
        json['nomineeAadhaarNumber'] ??
            json['NomineeAadhaarNumber'] ??
            json['aadhaarNumber'] ??
            json['AadhaarNumber'],
      ),
      panCardNumber: _readString(
        json['nomineePanCardNumber'] ??
            json['NomineePanCardNumber'] ??
            json['panCardNumber'] ??
            json['PanCardNumber'],
      ),
      phoneNumber: _readString(
        json['nomineePhoneNumber'] ??
            json['NomineePhoneNumber'] ??
            json['phoneNumber'] ??
            json['PhoneNumber'],
      ),
      profilePhoto: _readString(
        json['nomineeProfilePhoto'] ??
            json['NomineeProfilePhoto'] ??
            json['profilePhoto'] ??
            json['ProfilePhoto'],
      ),
      aadhaarCardImage: _readString(
        json['nomineeAadhaarPhoto'] ??
            json['NomineeAadhaarPhoto'] ??
            json['nomineeAadhaarCardImage'] ??
            json['NomineeAadhaarCardImage'] ??
            json['aadhaarCardImage'] ??
            json['AadhaarCardImage'],
      ),
      panCardImage: _readString(
        json['nomineePanCardPhoto'] ??
            json['NomineePanCardPhoto'] ??
            json['nomineePanCardImage'] ??
            json['NomineePanCardImage'] ??
            json['panCardImage'] ??
            json['PanCardImage'],
      ),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is num) {
      final parsed = value.toInt();
      return parsed > 0 ? parsed : null;
    }
    final parsed = int.tryParse(value.toString().trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
