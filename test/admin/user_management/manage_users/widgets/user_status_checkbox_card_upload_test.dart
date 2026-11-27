import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_status_checkbox_card.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sizer/sizer.dart';

/// Simulates file_picker on web: `path` throws, bytes are provided.
class _WebLikePlatformFile extends PlatformFile {
  _WebLikePlatformFile({required super.name, required Uint8List bytes})
      : super(size: bytes.length, bytes: bytes);

  @override
  String? get path => throw 'On web path is unavailable and accessing it causes this exception.';
}

class _FakeFilePicker extends FilePicker
    with MockPlatformInterfaceMixin {
  _FakeFilePicker(this.file);

  final PlatformFile file;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool? allowCompression,
    int? compressionQuality,
    bool allowMultiple = false,
    bool? withData = false,
    bool? withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([file]);
  }
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required String label,
  required DocumentUploadCallback onUpload,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UserStatusCheckboxCard(
              title: '$label Status',
              subtitle: 'Track the $label document',
              documentLabel: label,
              selected: DocumentProcessStatus.pending,
              onChanged: (_) {},
              onUploadDocument: onUpload,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  final bytes = Uint8List.fromList([1, 2, 3, 4]);
  for (final label in const ['MOU', 'LLP']) {
    testWidgets('$label: web-picked file (path throws) is staged and uploaded',
        (tester) async {
      FilePicker.platform = _FakeFilePicker(
        _WebLikePlatformFile(name: '$label-agreement.pdf', bytes: bytes),
      );
      final calls = <(Uint8List, String)>[];
      await _pumpCard(
        tester,
        label: label,
        onUpload: (b, n) async => calls.add((b, n)),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('$label-agreement.pdf'), findsOneWidget);
      expect(find.text('Selected Document (1)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single.$1, bytes);
      expect(calls.single.$2, '$label-agreement.pdf');
    });
  }

  testWidgets('file with a normal path is still staged (non-web unchanged)',
      (tester) async {
    FilePicker.platform = _FakeFilePicker(
      PlatformFile(
        name: 'mou.pdf',
        size: bytes.length,
        bytes: bytes,
        path: '/tmp/mou.pdf',
      ),
    );
    final calls = <(Uint8List, String)>[];
    await _pumpCard(
      tester,
      label: 'MOU',
      onUpload: (b, n) async => calls.add((b, n)),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('mou.pdf'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pump();

    expect(calls, hasLength(1));
    expect(calls.single.$1, bytes);
    expect(calls.single.$2, 'mou.pdf');
  });
}
