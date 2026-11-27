import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_entry.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_record.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_submit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/kyc_document_images.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';

PickedPhoto _photo(String name) =>
    PickedPhoto(bytes: Uint8List.fromList([1, 2, 3]), name: name);

MultipartFile _file(String name) =>
    MultipartFile.fromBytes([1, 2, 3], filename: name);

void main() {
  group('InvestorNomineeRecord.fromJson', () {
    test('old shape (no back keys): back is null, front kept', () {
      final record = InvestorNomineeRecord.fromJson({
        'nomineeId': 4,
        'nomineeName': 'Asha',
        'nomineeAadhaarPhoto': '/a/front.jpg',
        'nomineePanCardPhoto': '/p/front.jpg',
      });

      expect(record.aadhaarCardImage, '/a/front.jpg');
      expect(record.panCardImage, '/p/front.jpg');
      expect(record.aadhaarCardBackImage, isNull);
      expect(record.panCardBackImage, isNull);
    });

    test('new shape, camelCase', () {
      final record = InvestorNomineeRecord.fromJson({
        'nomineeId': 4,
        'nomineeAadhaarPhoto': '/a/front.jpg',
        'nomineeAadhaarBackPhoto': '/a/back.jpg',
        'nomineePanCardPhoto': '/p/front.jpg',
        'nomineePanCardBackPhoto': '/p/back.jpg',
      });

      expect(record.aadhaarCardImage, '/a/front.jpg');
      expect(record.aadhaarCardBackImage, '/a/back.jpg');
      expect(record.panCardImage, '/p/front.jpg');
      expect(record.panCardBackImage, '/p/back.jpg');
    });

    test('new shape, PascalCase', () {
      final record = InvestorNomineeRecord.fromJson({
        'NomineeId': 4,
        'NomineeAadhaarPhoto': '/a/front.jpg',
        'NomineeAadhaarBackPhoto': '/a/back.jpg',
        'NomineePanCardPhoto': '/p/front.jpg',
        'NomineePanCardBackPhoto': '/p/back.jpg',
      });

      expect(record.aadhaarCardBackImage, '/a/back.jpg');
      expect(record.panCardBackImage, '/p/back.jpg');
      expect(record.aadhaarCardImage, '/a/front.jpg');
    });

    test('explicit null and blank back values stay null', () {
      final record = InvestorNomineeRecord.fromJson({
        'nomineeId': 4,
        'nomineeAadhaarPhoto': '/a/front.jpg',
        'nomineeAadhaarBackPhoto': null,
        'nomineePanCardBackPhoto': '  ',
      });

      expect(record.aadhaarCardBackImage, isNull);
      expect(record.panCardBackImage, isNull);
    });

    test('a nominee with only a back image is not empty', () {
      final record = InvestorNomineeRecord.fromJson({
        'nomineePanCardBackPhoto': '/p/back.jpg',
      });
      expect(record.isEmpty, isFalse);
    });
  });

  group('InvestorModel.fromJson', () {
    test('old shape (no back keys): back is null, front kept', () {
      final investor = InvestorModel.fromJson({
        'userId': 1,
        'aadhaarPhoto': '/a/front.jpg',
        'panCardPhoto': '/p/front.jpg',
        'nominees': [
          {'nomineeId': 2, 'nomineeAadhaarPhoto': '/na/front.jpg'},
        ],
      });

      expect(investor.aadhaarCardImage, '/a/front.jpg');
      expect(investor.panCardImage, '/p/front.jpg');
      expect(investor.aadhaarCardBackImage, isNull);
      expect(investor.panCardBackImage, isNull);
      expect(investor.aadhaarCardBackImageUrl, isNull);
      expect(investor.panCardBackImageUrl, isNull);
      expect(investor.nominees.single.aadhaarCardImage, '/na/front.jpg');
      expect(investor.nominees.single.aadhaarCardBackImage, isNull);
    });

    test('new shape, camelCase, with nominees', () {
      final investor = InvestorModel.fromJson({
        'userId': 1,
        'aadhaarPhoto': '/a/front.jpg',
        'aadhaarBackPhoto': '/a/back.jpg',
        'panCardPhoto': '/p/front.jpg',
        'panCardBackPhoto': '/p/back.jpg',
        'nominees': [
          {
            'nomineeId': 2,
            'nomineeAadhaarPhoto': '/na/front.jpg',
            'nomineeAadhaarBackPhoto': '/na/back.jpg',
            'nomineePanCardPhoto': '/np/front.jpg',
            'nomineePanCardBackPhoto': '/np/back.jpg',
          },
        ],
      });

      expect(investor.aadhaarCardBackImage, '/a/back.jpg');
      expect(investor.panCardBackImage, '/p/back.jpg');
      expect(investor.aadhaarCardBackImageUrl, endsWith('/a/back.jpg'));
      expect(investor.panCardBackImageUrl, endsWith('/p/back.jpg'));
      final nominee = investor.nominees.single;
      expect(nominee.aadhaarCardBackImage, '/na/back.jpg');
      expect(nominee.panCardBackImage, '/np/back.jpg');
    });

    test('new shape, PascalCase, with nominees', () {
      final investor = InvestorModel.fromJson({
        'UserId': 1,
        'AadhaarPhoto': '/a/front.jpg',
        'AadhaarBackPhoto': '/a/back.jpg',
        'PanCardPhoto': '/p/front.jpg',
        'PanCardBackPhoto': '/p/back.jpg',
        'Nominees': [
          {
            'NomineeId': 2,
            'NomineeAadhaarPhoto': '/na/front.jpg',
            'NomineeAadhaarBackPhoto': '/na/back.jpg',
            'NomineePanCardPhoto': '/np/front.jpg',
            'NomineePanCardBackPhoto': '/np/back.jpg',
          },
        ],
      });

      expect(investor.aadhaarCardImage, '/a/front.jpg');
      expect(investor.aadhaarCardBackImage, '/a/back.jpg');
      expect(investor.panCardBackImage, '/p/back.jpg');
      expect(investor.nominees.single.aadhaarCardBackImage, '/na/back.jpg');
      expect(investor.nominees.single.panCardBackImage, '/np/back.jpg');
    });

    test('legacy flat nominee back fields feed the single nominee record', () {
      final investor = InvestorModel.fromJson({
        'userId': 1,
        'nomineeId': 9,
        'nomineeName': 'Legacy',
        'nomineeAadhaarBackPhoto': '/na/back.jpg',
        'nomineePanCardBackPhoto': '/np/back.jpg',
      });

      final records = nomineeRecordsFromInvestor(investor);
      expect(records, hasLength(1));
      expect(records.single.aadhaarCardBackImage, '/na/back.jpg');
      expect(records.single.panCardBackImage, '/np/back.jpg');
    });
  });

  group('InvestorNomineeSubmitData.isEmpty', () {
    test('is true when nothing is set', () {
      expect(const InvestorNomineeSubmitData().isEmpty, isTrue);
    });

    test('is false when only a back image is set', () {
      expect(
        InvestorNomineeSubmitData(aadhaarCardBackImage: _file('a.jpg')).isEmpty,
        isFalse,
      );
      expect(
        InvestorNomineeSubmitData(panCardBackImage: _file('p.jpg')).isEmpty,
        isFalse,
      );
    });
  });

  group('InvestorNomineeEntry.hasAnyData', () {
    test('is false for a blank entry', () {
      final entry = InvestorNomineeEntry();
      addTearDown(entry.dispose);
      expect(entry.hasAnyData, isFalse);
    });

    test('is true for a picked back image only', () {
      final entry = InvestorNomineeEntry();
      addTearDown(entry.dispose);
      entry.aadhaar.setPicked(KycSide.back, _photo('b.jpg'));
      expect(entry.hasAnyData, isTrue);
    });

    test('is true for a stored back image only', () {
      final entry = InvestorNomineeEntry();
      addTearDown(entry.dispose);
      entry.pan.setExisting(KycSide.back, 'https://x/y.jpg');
      expect(entry.hasAnyData, isTrue);
    });

    test('applyFromRecord fills both stored sides per document', () {
      final entry = InvestorNomineeEntry();
      addTearDown(entry.dispose);
      entry.applyFromRecord(
        InvestorNomineeRecord.fromJson({
          'nomineeId': 3,
          'nomineeAadhaarPhoto': 'https://x/af.jpg',
          'nomineeAadhaarBackPhoto': 'https://x/ab.jpg',
          'nomineePanCardPhoto': 'https://x/pf.jpg',
        }),
      );

      expect(entry.aadhaar.existingFrontUrl, 'https://x/af.jpg');
      expect(entry.aadhaar.existingBackUrl, 'https://x/ab.jpg');
      expect(entry.pan.existingFrontUrl, 'https://x/pf.jpg');
      expect(entry.pan.existingBackUrl, isNull);
    });
  });

  group('KycDocumentImages state', () {
    test('cancelling a picked image keeps the stored URL', () {
      final images = KycDocumentImages()
        ..setExisting(KycSide.front, 'https://x/front.jpg')
        ..setPicked(KycSide.front, _photo('new.jpg'));

      images.cancelPicked(KycSide.front);

      expect(images.pickedFor(KycSide.front), isNull);
      expect(images.existingFor(KycSide.front), 'https://x/front.jpg');
    });

    test('cancelling one side never changes the other side', () {
      final images = KycDocumentImages()
        ..setExisting(KycSide.front, 'https://x/front.jpg')
        ..setExisting(KycSide.back, 'https://x/back.jpg')
        ..setPicked(KycSide.front, _photo('f.jpg'))
        ..setPicked(KycSide.back, _photo('b.jpg'));

      images.cancelPicked(KycSide.front);

      expect(images.pickedFor(KycSide.back)?.name, 'b.jpg');
      expect(images.existingFor(KycSide.back), 'https://x/back.jpg');
      expect(images.existingFor(KycSide.front), 'https://x/front.jpg');
    });

    test('cancelling with no stored image leaves the side empty', () {
      final images = KycDocumentImages()
        ..setPicked(KycSide.back, _photo('b.jpg'));

      images.cancelPicked(KycSide.back);

      expect(images.pickedFor(KycSide.back), isNull);
      expect(images.existingFor(KycSide.back), isNull);
      expect(images.hasAnyData, isFalse);
    });

    test('a nominee entry routes documents to separate state', () {
      final entry = InvestorNomineeEntry();
      addTearDown(entry.dispose);
      entry.kycImages(KycDocument.aadhaar).setPicked(KycSide.back, _photo('a'));

      expect(entry.aadhaar.backPhoto?.name, 'a');
      expect(entry.pan.backPhoto, isNull);
    });
  });
}
