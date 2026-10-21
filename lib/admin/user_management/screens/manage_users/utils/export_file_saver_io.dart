import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'export_file_saver.dart';

Future<ExportSaveResult> saveExportFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  final directory = await _resolveSaveDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(file.path, type: mimeType);
  return ExportSaveResult(message: file.path);
}

Future<Directory> _resolveSaveDirectory() async {
  if (Platform.isAndroid) {
    final downloads = Directory('/storage/emulated/0/Download');
    try {
      if (await downloads.exists()) {
        final probe = File('${downloads.path}/.maribel_export_probe');
        await probe.writeAsString('ok');
        await probe.delete();
        return downloads;
      }
    } catch (_) {
      // Fall through to app documents.
    }
  }

  return getApplicationDocumentsDirectory();
}
