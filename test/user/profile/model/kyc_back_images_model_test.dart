import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_nominee_model.dart';

Map<String, dynamic> _investor(Map<String, dynamic> extra) => {
      'userId': 5,
      'username': 'jane',
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
      'isActive': true,
      'userRole': 'Investor',
      ...extra,
    };

String _abs(String path) {
  final base = kBaseUrl.endsWith('/')
      ? kBaseUrl.substring(0, kBaseUrl.length - 1)
      : kBaseUrl;
  return '$base$path';
}

void main() {
  group('user InvestorDetailsModel KYC back images', () {
    test('old response without back keys parses, backs are null', () {
      final model = InvestorDetailsModel.fromJson(
        _investor({
          'aadhaarPhoto': '/investordocuments/aadhaar/a.jpg',
          'panCardPhoto': '/investordocuments/pan/p.jpg',
        }),
      );

      expect(model.aadhaarPhoto, '/investordocuments/aadhaar/a.jpg');
      expect(model.panCardPhoto, '/investordocuments/pan/p.jpg');
      expect(model.aadhaarBackPhoto, isNull);
      expect(model.panCardBackPhoto, isNull);
      expect(model.aadhaarBackPhotoUrl, isNull);
      expect(model.panCardBackPhotoUrl, isNull);
      expect(model.aadhaarPhotoUrl, _abs('/investordocuments/aadhaar/a.jpg'));
    });

    test('new response with camelCase back keys', () {
      final model = InvestorDetailsModel.fromJson(
        _investor({
          'aadhaarPhoto': '/investordocuments/aadhaar/a.jpg',
          'aadhaarBackPhoto': '/investordocuments/aadhaar/ab.jpg',
          'panCardPhoto': '/investordocuments/pan/p.jpg',
          'panCardBackPhoto': '/investordocuments/pan/pb.jpg',
        }),
      );

      expect(
        model.aadhaarBackPhotoUrl,
        _abs('/investordocuments/aadhaar/ab.jpg'),
      );
      expect(model.panCardBackPhotoUrl, _abs('/investordocuments/pan/pb.jpg'));
    });

    test('PascalCase and legacy card-image back keys', () {
      final pascal = InvestorDetailsModel.fromJson(
        _investor({
          'AadhaarBackPhoto': '/x/ab.jpg',
          'PanCardBackPhoto': '/x/pb.jpg',
        }),
      );
      expect(pascal.aadhaarBackPhotoUrl, _abs('/x/ab.jpg'));
      expect(pascal.panCardBackPhotoUrl, _abs('/x/pb.jpg'));

      final cardImage = InvestorDetailsModel.fromJson(
        _investor({
          'aadhaarCardBackImage': '/x/ab2.jpg',
          'panCardBackImage': '/x/pb2.jpg',
        }),
      );
      expect(cardImage.aadhaarBackPhotoUrl, _abs('/x/ab2.jpg'));
      expect(cardImage.panCardBackPhotoUrl, _abs('/x/pb2.jpg'));
    });

    test('null and blank back values stay null; back only works', () {
      final model = InvestorDetailsModel.fromJson(
        _investor({
          'aadhaarPhoto': null,
          'aadhaarBackPhoto': '/x/ab.jpg',
          'panCardPhoto': null,
          'panCardBackPhoto': '   ',
        }),
      );

      expect(model.aadhaarPhotoUrl, isNull);
      expect(model.aadhaarBackPhotoUrl, _abs('/x/ab.jpg'));
      expect(model.panCardBackPhoto, isNull);
      expect(model.panCardBackPhotoUrl, isNull);
    });

    test('nested nominees carry back images, old nominees have null backs', () {
      final model = InvestorDetailsModel.fromJson(
        _investor({
          'nominees': [
            {
              'nomineeId': 1,
              'nomineeName': 'amma',
              'nomineeAadhaarPhoto': '/n/a.jpg',
              'nomineeAadhaarBackPhoto': '/n/ab.jpg',
              'nomineePanCardPhoto': '/n/p.jpg',
              'nomineePanCardBackPhoto': '/n/pb.jpg',
            },
            {
              'nomineeId': 2,
              'nomineeName': 'appa',
              'nomineeAadhaarPhoto': '/n/a2.jpg',
            },
          ],
        }),
      );

      expect(model.nominees, hasLength(2));
      expect(model.nominees[0].nomineeAadhaarBackPhotoUrl, _abs('/n/ab.jpg'));
      expect(model.nominees[0].nomineePanCardBackPhotoUrl, _abs('/n/pb.jpg'));
      expect(model.nominees[1].nomineeAadhaarPhotoUrl, _abs('/n/a2.jpg'));
      expect(model.nominees[1].nomineeAadhaarBackPhotoUrl, isNull);
      expect(model.nominees[1].nomineePanCardBackPhotoUrl, isNull);
    });
  });

  group('user InvestorNomineeModel KYC back images', () {
    test('old shape parses, backs are null', () {
      final nominee = InvestorNomineeModel.fromJson({
        'nomineeName': 'amma',
        'nomineeAadhaarPhoto': '/n/a.jpg',
        'nomineePanCardPhoto': '/n/p.jpg',
      });

      expect(nominee.nomineeAadhaarBackPhoto, isNull);
      expect(nominee.nomineePanCardBackPhoto, isNull);
      expect(nominee.nomineeAadhaarBackPhotoUrl, isNull);
      expect(nominee.nomineePanCardBackPhotoUrl, isNull);
    });

    test('new shape, PascalCase and card-image fallbacks', () {
      final camel = InvestorNomineeModel.fromJson({
        'nomineeAadhaarBackPhoto': '/n/ab.jpg',
        'nomineePanCardBackPhoto': '/n/pb.jpg',
      });
      expect(camel.nomineeAadhaarBackPhotoUrl, _abs('/n/ab.jpg'));
      expect(camel.nomineePanCardBackPhotoUrl, _abs('/n/pb.jpg'));

      final pascal = InvestorNomineeModel.fromJson({
        'NomineeAadhaarBackPhoto': '/n/ab2.jpg',
        'NomineePanCardBackPhoto': '/n/pb2.jpg',
      });
      expect(pascal.nomineeAadhaarBackPhotoUrl, _abs('/n/ab2.jpg'));
      expect(pascal.nomineePanCardBackPhotoUrl, _abs('/n/pb2.jpg'));

      final cardImage = InvestorNomineeModel.fromJson({
        'nomineeAadhaarCardBackImage': '/n/ab3.jpg',
        'nomineePanCardBackImage': '/n/pb3.jpg',
      });
      expect(cardImage.nomineeAadhaarBackPhotoUrl, _abs('/n/ab3.jpg'));
      expect(cardImage.nomineePanCardBackPhotoUrl, _abs('/n/pb3.jpg'));
    });

    test('flat investor fallback reads back keys', () {
      final nominee = InvestorNomineeModel.fromFlatInvestor({
        'nomineeName': 'amma',
        'nomineeAadhaarBackPhoto': '/n/ab.jpg',
        'NomineePanCardBackPhoto': '/n/pb.jpg',
      });
      expect(nominee.nomineeAadhaarBackPhotoUrl, _abs('/n/ab.jpg'));
      expect(nominee.nomineePanCardBackPhotoUrl, _abs('/n/pb.jpg'));
    });

    test('a nominee with only a back image is not empty', () {
      expect(
        const InvestorNomineeModel(nomineeAadhaarBackPhoto: '/n/ab.jpg')
            .isEmpty,
        isFalse,
      );
      expect(
        const InvestorNomineeModel(nomineePanCardBackPhoto: '/n/pb.jpg').isEmpty,
        isFalse,
      );
      expect(const InvestorNomineeModel().isEmpty, isTrue);
    });
  });
}
