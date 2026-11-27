import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/payment_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_details_section.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:sizer/sizer.dart';

Map<String, dynamic> _investorJson(Map<String, dynamic> extra) => {
      'userId': 3,
      'username': 'jane',
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
      'isActive': true,
      'userRole': 'Investor',
      ...extra,
    };

InvestorDetailsModel _details([Map<String, dynamic> extra = const {}]) =>
    InvestorDetailsModel.fromJson(_investorJson(extra));

String _abs(String path) {
  final base = kBaseUrl.endsWith('/')
      ? kBaseUrl.substring(0, kBaseUrl.length - 1)
      : kBaseUrl;
  return '$base$path';
}

PendingRequestModel _request() => PendingRequestModel.fromPaymentRequest(
      PaymentRequestDataModel.fromJson({
        'requestId': 7,
        'userId': 3,
        'investorCode': 'INV-1',
        'fullName': 'Jane Doe',
        'email': 'jane@example.com',
        'phoneNumber': '9999',
        'paidAmount': 1000,
        'paymentMethod': 'Cash',
        'status': 'Pending',
      }),
    );

Future<void> _pump(
  WidgetTester tester,
  InvestorDetailsModel details, {
  double width = 1200,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 2400);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewRequestDetailsSection(
              request: _request(),
              investorDetails: details,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('funding InvestorDetailsModel KYC back images', () {
    test('old response without back keys parses, backs empty and URL null', () {
      final model = _details({
        'aadhaarPhoto': '/a.jpg',
        'panCardPhoto': '/p.jpg',
        'nominees': [
          {
            'nomineeId': 1,
            'nomineeName': 'Amma',
            'nomineeAadhaarPhoto': '/na.jpg',
            'nomineePanCardPhoto': '/np.jpg',
          },
        ],
      });

      expect(model.aadhaarPhotoUrl, _abs('/a.jpg'));
      expect(model.aadhaarBackPhoto, isEmpty);
      expect(model.panCardBackPhoto, isEmpty);
      expect(model.aadhaarBackPhotoUrl, isNull);
      expect(model.panCardBackPhotoUrl, isNull);
      final nominee = model.nominees.single;
      expect(nominee.nomineeAadhaarPhotoUrl, _abs('/na.jpg'));
      expect(nominee.nomineeAadhaarBackPhotoUrl, isNull);
      expect(nominee.nomineePanCardBackPhotoUrl, isNull);
    });

    test('new response, PascalCase and card-image fallbacks', () {
      final camel = _details({
        'aadhaarBackPhoto': '/ab.jpg',
        'panCardBackPhoto': '/pb.jpg',
        'nominees': [
          {
            'nomineeId': 1,
            'nomineeAadhaarBackPhoto': '/nab.jpg',
            'nomineePanCardBackPhoto': '/npb.jpg',
          },
        ],
      });
      expect(camel.aadhaarBackPhotoUrl, _abs('/ab.jpg'));
      expect(camel.panCardBackPhotoUrl, _abs('/pb.jpg'));
      expect(camel.nominees.single.nomineeAadhaarBackPhotoUrl, _abs('/nab.jpg'));
      expect(camel.nominees.single.nomineePanCardBackPhotoUrl, _abs('/npb.jpg'));

      final pascal = _details({
        'AadhaarBackPhoto': '/ab2.jpg',
        'PanCardBackPhoto': '/pb2.jpg',
        'nominees': [
          {
            'NomineeAadhaarBackPhoto': '/nab2.jpg',
            'NomineePanCardBackPhoto': '/npb2.jpg',
          },
        ],
      });
      expect(pascal.aadhaarBackPhotoUrl, _abs('/ab2.jpg'));
      expect(pascal.panCardBackPhotoUrl, _abs('/pb2.jpg'));
      expect(
        pascal.nominees.single.nomineeAadhaarBackPhotoUrl,
        _abs('/nab2.jpg'),
      );
      expect(
        pascal.nominees.single.nomineePanCardBackPhotoUrl,
        _abs('/npb2.jpg'),
      );

      final cardImage = _details({
        'aadhaarCardBackImage': '/ab3.jpg',
        'panCardBackImage': '/pb3.jpg',
        'nominees': [
          {
            'nomineeAadhaarCardBackImage': '/nab3.jpg',
            'nomineePanCardBackImage': '/npb3.jpg',
          },
        ],
      });
      expect(cardImage.aadhaarBackPhotoUrl, _abs('/ab3.jpg'));
      expect(cardImage.panCardBackPhotoUrl, _abs('/pb3.jpg'));
      expect(
        cardImage.nominees.single.nomineeAadhaarBackPhotoUrl,
        _abs('/nab3.jpg'),
      );
      expect(
        cardImage.nominees.single.nomineePanCardBackPhotoUrl,
        _abs('/npb3.jpg'),
      );
    });

    test('legacy flat nominee fields carry back images', () {
      final model = _details({
        'nomineeName': 'Amma',
        'nomineeAadhaarBackPhoto': '/nab.jpg',
        'nomineePanCardBackPhoto': '/npb.jpg',
      });
      expect(model.nominees.single.nomineeAadhaarBackPhotoUrl, _abs('/nab.jpg'));
      expect(model.nominees.single.nomineePanCardBackPhotoUrl, _abs('/npb.jpg'));
    });

    test('copyWith keeps back images', () {
      final model = _details({
        'aadhaarBackPhoto': '/ab.jpg',
        'panCardBackPhoto': '/pb.jpg',
      }).copyWith(dueDates: const []);
      expect(model.aadhaarBackPhotoUrl, _abs('/ab.jpg'));
      expect(model.panCardBackPhotoUrl, _abs('/pb.jpg'));
    });
  });

  group('ReviewRequestDetailsSection investor KYC tiles', () {
    testWidgets('legacy single images are labelled Front', (tester) async {
      await _pump(
        tester,
        _details({'aadhaarPhoto': '/a.jpg', 'panCardPhoto': '/p.jpg'}),
      );
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('PAN Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsNothing);
      expect(find.text('PAN Back'), findsNothing);
      expect(find.byType(Image), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('front and back of both documents', (tester) async {
      await _pump(
        tester,
        _details({
          'aadhaarPhoto': '/a.jpg',
          'aadhaarBackPhoto': '/ab.jpg',
          'panCardPhoto': '/p.jpg',
          'panCardBackPhoto': '/pb.jpg',
        }),
      );
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsOneWidget);
      expect(find.text('PAN Front'), findsOneWidget);
      expect(find.text('PAN Back'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('back only shows only the back tile', (tester) async {
      await _pump(tester, _details({'aadhaarBackPhoto': '/ab.jpg'}));
      expect(find.text('Aadhaar Back'), findsOneWidget);
      expect(find.text('Aadhaar Front'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('no images keeps the existing placeholders, no Front/Back',
        (tester) async {
      await _pump(tester, _details());
      expect(find.text('PAN card photo'), findsOneWidget);
      expect(find.text('Aadhaar photo'), findsOneWidget);
      expect(find.textContaining('Front'), findsNothing);
      expect(find.textContaining('Back'), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow width renders both tiles without overflow',
        (tester) async {
      await _pump(
        tester,
        _details({
          'aadhaarPhoto': '/a.jpg',
          'aadhaarBackPhoto': '/ab.jpg',
          'panCardPhoto': '/p.jpg',
          'panCardBackPhoto': '/pb.jpg',
        }),
        width: 420,
      );
      expect(find.byType(Image), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a Back tile opens the preview dialog', (tester) async {
      await _pump(
        tester,
        _details({'aadhaarPhoto': '/a.jpg', 'aadhaarBackPhoto': '/ab.jpg'}),
      );
      await tester.tap(find.text('Aadhaar Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsWidgets);
    });
  });

  group('ReviewRequestDetailsSection nominee KYC tiles', () {
    testWidgets('legacy nominee images are labelled Front', (tester) async {
      await _pump(
        tester,
        _details({
          'nominees': [
            {
              'nomineeId': 1,
              'nomineeName': 'Amma',
              'nomineeAadhaarPhoto': '/na.jpg',
              'nomineePanCardPhoto': '/np.jpg',
            },
          ],
        }),
      );
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('PAN Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsNothing);
      expect(find.text('PAN Back'), findsNothing);
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('each nominee shows only the sides it has', (tester) async {
      await _pump(
        tester,
        _details({
          'nominees': [
            {
              'nomineeId': 1,
              'nomineeName': 'Amma',
              'nomineeAadhaarPhoto': '/na.jpg',
              'nomineeAadhaarBackPhoto': '/nab.jpg',
            },
            {
              'nomineeId': 2,
              'nomineeName': 'Appa',
              'nomineePanCardBackPhoto': '/npb.jpg',
            },
          ],
        }),
      );
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsOneWidget);
      expect(find.text('PAN Front'), findsNothing);
      expect(find.text('PAN Back'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('nominee with no images renders without Front/Back tiles',
        (tester) async {
      await _pump(
        tester,
        _details({
          'nominees': [
            {'nomineeId': 1, 'nomineeName': 'Amma'},
          ],
        }),
      );
      expect(find.textContaining('Front'), findsNothing);
      expect(find.textContaining('Back'), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
