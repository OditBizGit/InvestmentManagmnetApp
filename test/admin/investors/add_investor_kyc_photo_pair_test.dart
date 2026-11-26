import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/kyc_document_images.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

const _closeIcon = Icons.close_rounded;

PickedPhoto _photo(String name) =>
    PickedPhoto(bytes: Uint8List.fromList(_onePixelPng), name: name);

// 1x1 transparent PNG so MemoryImage can decode in tests.
const _onePixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// Stored images are NetworkImages; the test HTTP client answers 400, so the
/// load error is expected and ignored here.
Future<void> _ignoringImageLoadErrors(Future<void> Function() body) async {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is NetworkImageLoadException) return;
    original?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = original;
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required Widget child,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pump();
}

/// Wires the pair to a [KycDocumentImages] like the screen does.
class _Host extends StatefulWidget {
  const _Host({
    required this.images,
    required this.twoCol,
    this.picked = const [],
  });

  final KycDocumentImages images;
  final bool twoCol;
  final List<PickedPhoto> picked;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  var _next = 0;
  final List<KycSide> pickLog = [];
  final List<KycSide> clearLog = [];

  @override
  Widget build(BuildContext context) {
    return AddInvestorKycPhotoPair(
      images: widget.images,
      documentLabel: 'Aadhaar',
      twoCol: widget.twoCol,
      onPick: (side) {
        pickLog.add(side);
        setState(() => widget.images.setPicked(side, widget.picked[_next++]));
      },
      onClear: (side) {
        clearLog.add(side);
        setState(() => widget.images.cancelPicked(side));
      },
    );
  }
}

void main() {
  group('AddInvestorKycPhotoPair layout', () {
    testWidgets('empty pair shows Front and Back upload labels, no x',
        (tester) async {
      await _pump(
        tester,
        width: 1000,
        child: _Host(images: KycDocumentImages(), twoCol: true),
      );

      expect(find.text('Upload Aadhaar Front'), findsOneWidget);
      expect(find.text('Upload Aadhaar Back'), findsOneWidget);
      expect(find.byIcon(_closeIcon), findsNothing);
    });

    testWidgets('twoCol places Front and Back side by side', (tester) async {
      await _pump(
        tester,
        width: 1000,
        child: _Host(images: KycDocumentImages(), twoCol: true),
      );

      final front = tester.getTopLeft(find.text('Upload Aadhaar Front'));
      final back = tester.getTopLeft(find.text('Upload Aadhaar Back'));
      expect(back.dx, greaterThan(front.dx));
      expect((back.dy - front.dy).abs(), lessThan(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow layout stacks Back below Front without overflow',
        (tester) async {
      await _pump(
        tester,
        width: 360,
        child: _Host(images: KycDocumentImages(), twoCol: false),
      );

      final front = tester.getTopLeft(find.text('Upload Aadhaar Front'));
      final back = tester.getTopLeft(find.text('Upload Aadhaar Back'));
      expect(back.dy, greaterThan(front.dy));
      expect((back.dx - front.dx).abs(), lessThan(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('AddInvestorKycPhotoPair x rule', () {
    testWidgets('stored image with nothing picked: no x, current subtitle, '
        'tap still opens the picker', (tester) async {
      await _ignoringImageLoadErrors(() async {
        final images = KycDocumentImages()
          ..setExisting(KycSide.front, 'https://example.test/front.jpg');
        await _pump(
          tester,
          width: 1000,
          child: _Host(
            images: images,
            twoCol: true,
            picked: [_photo('new-front.png')],
          ),
        );

        expect(find.byIcon(_closeIcon), findsNothing);
        expect(find.text('Change Aadhaar Front'), findsOneWidget);
        expect(find.text('Current front image'), findsOneWidget);
        expect(find.text('Upload Aadhaar Back'), findsOneWidget);

        await tester.tap(find.text('Change Aadhaar Front'));
        await tester.pump();

        final state = tester.state<_HostState>(find.byType(_Host));
        expect(state.pickLog, [KycSide.front]);
        // Picking replaced nothing yet on the server side: the stored URL is
        // still held, and now an x is offered for the picked image.
        expect(images.existingFor(KycSide.front),
            'https://example.test/front.jpg');
        expect(find.byIcon(_closeIcon), findsOneWidget);
      });
    });

    testWidgets('x only on a picked image; pressing it restores the stored one',
        (tester) async {
      await _ignoringImageLoadErrors(() async {
        final images = KycDocumentImages()
          ..setExisting(KycSide.front, 'https://example.test/front.jpg')
          ..setExisting(KycSide.back, 'https://example.test/back.jpg');
        await _pump(
          tester,
          width: 1000,
          child: _Host(
            images: images,
            twoCol: true,
            picked: [_photo('new-front.png')],
          ),
        );

        await tester.tap(find.text('Change Aadhaar Front'));
        await tester.pump();

        expect(find.text('new-front.png'), findsOneWidget);
        expect(find.byIcon(_closeIcon), findsOneWidget);
        // Back is untouched: still the stored subtitle, no x of its own.
        expect(find.text('Current back image'), findsOneWidget);

        await tester.tap(find.byIcon(_closeIcon));
        await tester.pump();

        final state = tester.state<_HostState>(find.byType(_Host));
        expect(state.clearLog, [KycSide.front]);
        expect(images.pickedFor(KycSide.front), isNull);
        expect(images.existingFor(KycSide.front),
            'https://example.test/front.jpg');
        expect(images.existingFor(KycSide.back),
            'https://example.test/back.jpg');
        expect(find.byIcon(_closeIcon), findsNothing);
        expect(find.text('Current front image'), findsOneWidget);
        expect(find.text('Current back image'), findsOneWidget);
      });
    });

    testWidgets('picked image with no stored image: x returns the box to empty',
        (tester) async {
      final images = KycDocumentImages();
      await _pump(
        tester,
        width: 1000,
        child: _Host(
          images: images,
          twoCol: true,
          picked: [_photo('back.png')],
        ),
      );

      await tester.tap(find.text('Upload Aadhaar Back'));
      await tester.pump();
      expect(find.byIcon(_closeIcon), findsOneWidget);

      await tester.tap(find.byIcon(_closeIcon));
      await tester.pump();

      expect(images.pickedFor(KycSide.back), isNull);
      expect(find.byIcon(_closeIcon), findsNothing);
      expect(find.text('Upload Aadhaar Back'), findsOneWidget);
    });
  });

  group('AddInvestorPhotoUploadBox defaults (profile photo)', () {
    testWidgets('stored profile photo keeps its x and subtitle',
        (tester) async {
      await _ignoringImageLoadErrors(() async {
        await _pump(
          tester,
          width: 600,
          child: AddInvestorPhotoUploadBox(
            existingImageUrl: 'https://example.test/me.jpg',
            onPick: () {},
            onClear: () {},
          ),
        );

        expect(find.byIcon(_closeIcon), findsOneWidget);
        expect(find.text('Current profile photo'), findsOneWidget);
        expect(find.text('Change Profile Photo'), findsOneWidget);
      });
    });
  });
}
