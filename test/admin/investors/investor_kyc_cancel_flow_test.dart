import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_entry.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_submit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/kyc_document_images.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/register_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/update_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

// 1x1 PNG so MemoryImage can decode in the widget test.
const _onePixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

PickedPhoto _photo(String name) =>
    PickedPhoto(bytes: Uint8List.fromList(_onePixelPng), name: name);

// Same conversion the screen uses (_multipartFromPhoto).
MultipartFile? _multipart(PickedPhoto? photo) => photo == null
    ? null
    : MultipartFile.fromBytes(photo.bytes, filename: photo.name);

// Same mapping the screen uses (_nomineeSubmitPayload).
List<InvestorNomineeSubmitData> _payload(List<InvestorNomineeEntry> nominees) =>
    nominees
        .where((e) => e.hasAnyData)
        .take(3)
        .map(
          (e) => InvestorNomineeSubmitData(
            nomineeId: e.nomineeId,
            name: e.nameController.text.trim(),
            aadhaarCardImage: _multipart(e.aadhaar.frontPhoto),
            aadhaarCardBackImage: _multipart(e.aadhaar.backPhoto),
            panCardImage: _multipart(e.pan.frontPhoto),
            panCardBackImage: _multipart(e.pan.backPhoto),
          ),
        )
        .toList();

UpdateInvestorRequestModel _updateFrom(
  KycDocumentImages aadhaar,
  KycDocumentImages pan,
  List<InvestorNomineeEntry> nominees,
) =>
    UpdateInvestorRequestModel(
      userId: 7,
      fullName: 'Full Name',
      nominees: _payload(nominees),
      aadhaarPhoto: _multipart(aadhaar.frontPhoto),
      aadhaarBackPhoto: _multipart(aadhaar.backPhoto),
      panCardPhoto: _multipart(pan.frontPhoto),
      panCardBackPhoto: _multipart(pan.backPhoto),
    );

RegisterInvestorRequestModel _registerFrom(KycDocumentImages aadhaar) =>
    RegisterInvestorRequestModel(
      username: 'user',
      password: 'secret1',
      fullName: 'Full Name',
      email: 'a@b.com',
      phoneNumber: '9999999999',
      alternativeNumber: '',
      investorType: 'Type',
      staffId: 1,
      organization: '',
      address: 'Somewhere',
      investmentDate: DateTime(2026, 1, 1),
      investmentSplitMonths: 12,
      investmentSplitType: 'Month',
      investmentSplitGap: 1,
      investmentAdvanceAmount: 0,
      paymentMethod: 'Cash',
      aadhaarNumber: '',
      panCardNumber: '',
      accountNumber: '',
      ifscCode: '',
      bankName: '',
      aadhaarCardImage: _multipart(aadhaar.frontPhoto),
      aadhaarCardBackImage: _multipart(aadhaar.backPhoto),
    );

InvestorNomineeEntry _storedNominee(int id, String tag) {
  final entry = InvestorNomineeEntry()
    ..nomineeId = id
    ..nameController.text = 'Nominee $tag';
  entry.aadhaar
    ..setExisting(KycSide.front, 'https://x/$tag-af.jpg')
    ..setExisting(KycSide.back, 'https://x/$tag-ab.jpg');
  entry.pan
    ..setExisting(KycSide.front, 'https://x/$tag-pf.jpg')
    ..setExisting(KycSide.back, 'https://x/$tag-pb.jpg');
  return entry;
}

/// All 16 box states of a nominee as comparable strings.
List<String> _snapshot(InvestorNomineeEntry e) => [
      for (final doc in [e.aadhaar, e.pan])
        for (final side in KycSide.values)
          '${doc.pickedFor(side)?.name}|${doc.existingFor(side)}',
    ];

void main() {
  test('T17: cancelled picked front sends no file; stored URL kept; back key '
      'absent too', () async {
    final aadhaar = KycDocumentImages()
      ..setExisting(KycSide.front, 'https://x/front.jpg')
      ..setPicked(KycSide.front, _photo('new-front.jpg'));

    aadhaar.cancelPicked(KycSide.front);

    final form = await _updateFrom(aadhaar, KycDocumentImages(), const [])
        .toFormData();
    expect(form.files.map((e) => e.key), isNot(contains('AadhaarPhoto')));
    expect(form.files.map((e) => e.key), isNot(contains('AadhaarBackPhoto')));
    expect(form.files, isEmpty);
    expect(aadhaar.existingFor(KycSide.front), 'https://x/front.jpg');
  });

  test('T18: register with a picked back image then cancelled has no '
      'AadhaarBackPhoto entry', () async {
    final aadhaar = KycDocumentImages()
      ..setPicked(KycSide.back, _photo('back.jpg'));
    expect(
      (await _registerFrom(aadhaar).toFormData()).files.map((e) => e.key),
      contains('AadhaarBackPhoto'),
    );

    aadhaar.cancelPicked(KycSide.back);

    final form = await _registerFrom(aadhaar).toFormData();
    expect(form.files.map((e) => e.key), isNot(contains('AadhaarBackPhoto')));
    expect(form.files, isEmpty);
  });

  test('T19 state: cancelling nominee 2 PAN back changes only that box; update '
      'form data has no file keys', () async {
    final nominees = [
      _storedNominee(11, 'n1'),
      _storedNominee(12, 'n2'),
      _storedNominee(13, 'n3'),
    ];
    addTearDown(() {
      for (final n in nominees) {
        n.dispose();
      }
    });
    final stored = nominees.map(_snapshot).toList();

    nominees[1].kycImages(KycDocument.pan).setPicked(
          KycSide.back,
          _photo('new-pan-back.jpg'),
        );
    final picked = nominees.map(_snapshot).toList();
    expect(picked[0], stored[0]);
    expect(picked[2], stored[2]);
    expect(picked[1], isNot(stored[1]));
    final withPick = await _updateFrom(
      KycDocumentImages(),
      KycDocumentImages(),
      nominees,
    ).toFormData();
    expect(withPick.files.map((e) => e.key), ['NomineePanCardBackPhoto2']);

    nominees[1].kycImages(KycDocument.pan).cancelPicked(KycSide.back);

    expect(nominees.map(_snapshot).toList(), stored);
    final form = await _updateFrom(
      KycDocumentImages(),
      KycDocumentImages(),
      nominees,
    ).toFormData();
    expect(form.files, isEmpty);
    expect(
      form.fields.where((e) => e.key.startsWith('NomineeId')).map((e) => e.value),
      ['11', '12', '13'],
    );
  });

  testWidgets('T19 widget: x on nominee 2 PAN back leaves the other pairs '
      'unchanged', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1000, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final nominees = [_storedNominee(11, 'n1'), _storedNominee(12, 'n2')];
    addTearDown(() {
      for (final n in nominees) {
        n.dispose();
      }
    });
    final before = _snapshot(nominees[0]);
    final n2Before = _snapshot(nominees[1]);

    final original = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exception is NetworkImageLoadException) return;
      original?.call(d);
    };
    try {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < nominees.length; i++)
                        for (final doc in KycDocument.values)
                          AddInvestorKycPhotoPair(
                            images: nominees[i].kycImages(doc),
                            documentLabel: 'N$i ${doc.name}',
                            twoCol: true,
                            onPick: (side) => setState(() => nominees[i]
                                .kycImages(doc)
                                .setPicked(side, _photo('picked.jpg'))),
                            onClear: (side) => setState(
                              () => nominees[i].kycImages(doc).cancelPicked(side),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
      await tester.tap(find.text('Change N1 pan Back'));
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(_snapshot(nominees[0]), before);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(_snapshot(nominees[0]), before);
      expect(_snapshot(nominees[1]), n2Before);
      expect(find.text('Current back image'), findsNWidgets(4));
      expect(find.text('Current front image'), findsNWidgets(4));
    } finally {
      FlutterError.onError = original;
    }
  });
}
