import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

/// Result of a successful profile-photo pick (works on web, Windows, Android).
class PickedPhoto {
  const PickedPhoto({
    required this.bytes,
    required this.name,
    this.extension,
  });

  final Uint8List bytes;
  final String name;
  final String? extension;

  int get sizeInBytes => bytes.lengthInBytes;
}

/// Cross-platform image picker for web, Windows desktop, and Android APK.
class PhotoPickerHelper {
  PhotoPickerHelper._();

  static const int maxBytes = 2 * 1024 * 1024; // 2 MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  /// Opens the platform file/photo picker and returns image bytes.
  ///
  /// Returns `null` when the user cancels. Shows an error toast when the
  /// file type or size is invalid.
  static Future<PickedPhoto?> pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final extension = file.extension?.toLowerCase();

    if (extension == null || !allowedExtensions.contains(extension)) {
      AppToast.error('Please select a JPEG or PNG image.');
      return null;
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      AppToast.error('Could not read the selected image. Please try again.');
      return null;
    }

    if (bytes.lengthInBytes > maxBytes) {
      AppToast.error('Image must be 2 MB or smaller.');
      return null;
    }

    return PickedPhoto(
      bytes: bytes,
      name: file.name,
      extension: extension,
    );
  }
}
