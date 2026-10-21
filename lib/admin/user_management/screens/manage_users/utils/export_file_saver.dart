import 'dart:typed_data';

import 'export_file_saver_io.dart'
    if (dart.library.html) 'export_file_saver_web.dart' as saver;

class ExportSaveResult {
  const ExportSaveResult({required this.message});

  final String message;
}

Future<ExportSaveResult> saveExportFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) {
  return saver.saveExportFile(
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}
