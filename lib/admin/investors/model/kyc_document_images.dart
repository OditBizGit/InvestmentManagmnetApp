import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';

/// KYC document types that take a front and a back image.
enum KycDocument { aadhaar, pan }

/// Which side of a KYC document an image belongs to.
enum KycSide { front, back }

/// Form state for one KYC document (Aadhaar or PAN): a newly picked photo and
/// the stored image URL for each side. Sides never affect each other.
class KycDocumentImages {
  PickedPhoto? frontPhoto;
  PickedPhoto? backPhoto;
  String? existingFrontUrl;
  String? existingBackUrl;

  PickedPhoto? pickedFor(KycSide side) =>
      side == KycSide.front ? frontPhoto : backPhoto;

  String? existingFor(KycSide side) =>
      side == KycSide.front ? existingFrontUrl : existingBackUrl;

  void setPicked(KycSide side, PickedPhoto? photo) {
    if (side == KycSide.front) {
      frontPhoto = photo;
    } else {
      backPhoto = photo;
    }
  }

  void setExisting(KycSide side, String? url) {
    if (side == KycSide.front) {
      existingFrontUrl = url;
    } else {
      existingBackUrl = url;
    }
  }

  /// Cancels a newly picked photo only. The stored URL is kept, so the stored
  /// image shows again. Nothing is sent to the server.
  void cancelPicked(KycSide side) => setPicked(side, null);

  bool get hasAnyData =>
      frontPhoto != null ||
      backPhoto != null ||
      (existingFrontUrl?.trim().isNotEmpty ?? false) ||
      (existingBackUrl?.trim().isNotEmpty ?? false);

  void reset() {
    frontPhoto = null;
    backPhoto = null;
    existingFrontUrl = null;
    existingBackUrl = null;
  }
}
