import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_record.dart';
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
  PickedPhoto? aadhaarCardPhoto;
  String? existingAadhaarCardImageUrl;
  PickedPhoto? panCardPhoto;
  String? existingPanCardImageUrl;

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
    if (aadhaarCardPhoto != null ||
        (existingAadhaarCardImageUrl?.trim().isNotEmpty ?? false)) {
      return true;
    }
    if (panCardPhoto != null ||
        (existingPanCardImageUrl?.trim().isNotEmpty ?? false)) {
      return true;
    }
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
    existingAadhaarCardImageUrl = record.aadhaarCardImageUrl;
    existingPanCardImageUrl = record.panCardImageUrl;
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
    panCardImage: investor.nomineePanCardImage,
  );
  if (single.isEmpty) return const [];
  return [single];
}
