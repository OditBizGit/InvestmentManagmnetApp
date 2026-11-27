import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/payment_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_request_card.dart';
import 'package:sizer/sizer.dart';

Map<String, dynamic> _json({Object? staffName = _absent}) => {
      'requestId': 7,
      'userId': 3,
      'investorCode': 'INV-1',
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
      'phoneNumber': '9999',
      'paidAmount': 1000,
      'paymentMethod': 'Cash',
      'status': 'Pending',
      if (staffName != _absent) 'staffName': staffName,
    };

const Object _absent = Object();

Future<void> _pumpCard(
  WidgetTester tester,
  PendingRequestModel request,
  double width,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PendingRequestCard(
              request: request,
              onReview: () {},
              canReview: true,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('PaymentRequestDataModel.fromJson staffName', () {
    test('parses staffName when present', () {
      final data = PaymentRequestDataModel.fromJson(
        _json(staffName: 'Asha, Ravi'),
      );
      expect(data.staffName, 'Asha, Ravi');
    });

    test('defaults to empty when the field is missing (old API)', () {
      final data = PaymentRequestDataModel.fromJson(_json());
      expect(data.staffName, '');
    });

    test('defaults to empty when the field is null', () {
      final data = PaymentRequestDataModel.fromJson(_json(staffName: null));
      expect(data.staffName, '');
    });
  });

  group('PendingRequestModel staffName', () {
    test('fromPaymentRequest maps staffName trimmed', () {
      final model = PendingRequestModel.fromPaymentRequest(
        PaymentRequestDataModel.fromJson(_json(staffName: '  Asha, Ravi ')),
      );
      expect(model.staffName, 'Asha, Ravi');
    });

    test('copyWith keeps staffName', () {
      final model = PendingRequestModel.fromPaymentRequest(
        PaymentRequestDataModel.fromJson(_json(staffName: 'Asha')),
      );
      final copy = model.copyWith(status: PendingRequestStatus.approved);
      expect(copy.staffName, 'Asha');
      expect(copy.status, PendingRequestStatus.approved);
    });
  });

  group('PendingRequestCard staff line', () {
    PendingRequestModel build(String staffName) =>
        PendingRequestModel.fromPaymentRequest(
          PaymentRequestDataModel.fromJson(_json(staffName: staffName)),
        );

    for (final width in [1200.0, 500.0]) {
      testWidgets('shows staff name at width $width', (tester) async {
        await _pumpCard(tester, build('Asha, Ravi'), width);
        expect(find.text('Asha, Ravi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows dash when staff name empty at width $width',
          (tester) async {
        await _pumpCard(tester, build(''), width);
        expect(find.text('—'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
