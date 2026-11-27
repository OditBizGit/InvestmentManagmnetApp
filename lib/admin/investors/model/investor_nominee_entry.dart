import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_record.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/kyc_document_images.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';

/// One nominee row in the add/edit investor form (UI state + controllers).
class InvestorNomineeEntry {
  InvestorNomineeEntry();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController panController = TextEditingController();

  int? nomineeId;
  String? relationship;
  DateTime? dateOfBirth;

  PickedPhoto? profilePhoto;
  String? existingProfileImageUrl;

  /// Aadhaar and PAN, each with a front and a back image.
  final KycDocumentImages aadhaar = KycDocumentImages();
  final KycDocumentImages pan = KycDocumentImages();

  KycDocumentImages kycImages(KycDocument document) =>
      document == KycDocument.aadhaar ? aadhaar : pan;

  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    aadhaarController.dispose();
    panController.dispose();
  }

  bool get hasAnyData {
    if (nameController.text.trim().isNotEmpty) return true;
    if (addressController.text.trim().isNotEmpty) return true;
    if (phoneController.text.trim().isNotEmpty) return true;
    if (aadhaarController.text.trim().isNotEmpty) return true;
    if (panController.text.trim().isNotEmpty) return true;
    if (relationship != null && relationship!.trim().isNotEmpty) return true;
    if (dateOfBirth != null) return true;
    if (profilePhoto != null ||
        (existingProfileImageUrl?.trim().isNotEmpty ?? false)) {
      return true;
    }
    if (aadhaar.hasAnyData || pan.hasAnyData) return true;
    return false;
  }

  void applyFromRecord(InvestorNomineeRecord record) {
    nameController.text = record.name ?? '';
    addressController.text = record.address ?? '';
    phoneController.text = record.phoneNumber ?? '';
    aadhaarController.text = record.aadhaarNumber ?? '';
    panController.text = record.panCardNumber ?? '';
    nomineeId = record.nomineeId;
    relationship = record.relationship;
    dateOfBirth = record.dateOfBirth;
    existingProfileImageUrl = record.profilePhotoUrl;
    aadhaar
      ..setExisting(KycSide.front, record.aadhaarCardImageUrl)
      ..setExisting(KycSide.back, record.aadhaarCardBackImageUrl);
    pan
      ..setExisting(KycSide.front, record.panCardImageUrl)
      ..setExisting(KycSide.back, record.panCardBackImageUrl);
  }
}

List<InvestorNomineeRecord> nomineeRecordsFromInvestor(InvestorModel investor) {
  if (investor.nominees.isNotEmpty) {
    return investor.nominees;
  }
  final single = InvestorNomineeRecord(
    nomineeId: investor.nomineeId,
    name: investor.nomineeName,
    relationship: investor.nomineeRelationship,
    address: investor.nomineeAddress,
    dateOfBirth: investor.nomineeDateOfBirth,
    aadhaarNumber: investor.nomineeAadhaarNumber,
    panCardNumber: investor.nomineePanCardNumber,
    phoneNumber: investor.nomineePhoneNumber,
    profilePhoto: investor.nomineeProfilePhoto,
    aadhaarCardImage: investor.nomineeAadhaarCardImage,
    aadhaarCardBackImage: investor.nomineeAadhaarCardBackImage,
    panCardImage: investor.nomineePanCardImage,
    panCardBackImage: investor.nomineePanCardBackImage,
  );
  if (single.isEmpty) return const [];
  return [single];
}
