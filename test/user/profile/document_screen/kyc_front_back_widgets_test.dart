import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_nominee_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/additional_information_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/document_fullscreen_image.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/nominee_details_card.dart';

import '../team_overview/team_overview_test_harness.dart';

InvestorDetailsModel _details({
  String? aadhaar,
  String? aadhaarBack,
  String? pan,
  String? panBack,
}) {
  return InvestorDetailsModel(
    userId: 1,
    username: 'jane',
    fullName: 'Jane Doe',
    email: 'jane@example.com',
    isActive: true,
    userRole: 'Investor',
    aadhaarPhoto: aadhaar,
    aadhaarBackPhoto: aadhaarBack,
    panCardPhoto: pan,
    panCardBackPhoto: panBack,
  );
}

// The test font (Ahem) is much wider than Montserrat, so a smaller text scale
// keeps the card headers inside the 402 px phone width.
Future<void> _pumpCard(WidgetTester tester, Widget card) {
  return pumpTeamApp(
    tester,
    Scaffold(body: SingleChildScrollView(child: card)),
    size: const Size(402, 1600),
    textScale: 0.5,
  );
}

void _expectLabels(
  Set<String> shown, {
  Set<String> all = const {
    'Aadhaar Front',
    'Aadhaar Back',
    'PAN Front',
    'PAN Back',
  },
}) {
  for (final label in all) {
    expect(
      find.text(label),
      shown.contains(label) ? findsOneWidget : findsNothing,
      reason: label,
    );
  }
  // Old single-image labels are gone.
  expect(find.text('Aadhaar Photo'), findsNothing);
  expect(find.text('PAN Photo'), findsNothing);
}

void main() {
  group('AdditionalInformationCard Front/Back tiles', () {
    testWidgets('legacy single images are labelled Front', (tester) async {
      await _pumpCard(
        tester,
        AdditionalInformationCard(
          details: _details(aadhaar: '/a.jpg', pan: '/p.jpg'),
        ),
      );
      _expectLabels({'Aadhaar Front', 'PAN Front'});
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('front and back of both documents', (tester) async {
      await _pumpCard(
        tester,
        AdditionalInformationCard(
          details: _details(
            aadhaar: '/a.jpg',
            aadhaarBack: '/ab.jpg',
            pan: '/p.jpg',
            panBack: '/pb.jpg',
          ),
        ),
      );
      _expectLabels({'Aadhaar Front', 'Aadhaar Back', 'PAN Front', 'PAN Back'});
      expect(find.byType(Image), findsNWidgets(4));
    });

    testWidgets('back only renders without front tile', (tester) async {
      await _pumpCard(
        tester,
        AdditionalInformationCard(
          details: _details(aadhaarBack: '/ab.jpg'),
        ),
      );
      _expectLabels({'Aadhaar Back'});
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('no images renders no tiles and no error', (tester) async {
      await _pumpCard(
        tester,
        AdditionalInformationCard(details: _details()),
      );
      _expectLabels({});
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping Back opens the fullscreen viewer with its title',
        (tester) async {
      await _pumpCard(
        tester,
        AdditionalInformationCard(
          details: _details(aadhaar: '/a.jpg', aadhaarBack: '/ab.jpg'),
        ),
      );
      // Tiles are in order: Aadhaar Front, Aadhaar Back.
      await tester.tap(find.byType(Image).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DocumentFullscreenImage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DocumentFullscreenImage),
          matching: find.text('Aadhaar Back'),
        ),
        findsOneWidget,
      );
    });
  });

  group('NomineeDetailsCard Front/Back tiles', () {
    testWidgets('legacy nominee images are labelled Front', (tester) async {
      await _pumpCard(
        tester,
        const NomineeDetailsCard(
          nominees: [
            InvestorNomineeModel(
              nomineeName: 'Amma',
              nomineeAadhaarPhoto: '/a.jpg',
              nomineePanCardPhoto: '/p.jpg',
            ),
          ],
        ),
      );
      _expectLabels({'Aadhaar Front', 'PAN Front'});
    });

    testWidgets('each nominee shows only the sides it has', (tester) async {
      await _pumpCard(
        tester,
        const NomineeDetailsCard(
          nominees: [
            InvestorNomineeModel(
              nomineeName: 'Amma',
              nomineeAadhaarPhoto: '/a.jpg',
              nomineeAadhaarBackPhoto: '/ab.jpg',
            ),
            InvestorNomineeModel(
              nomineeName: 'Appa',
              nomineePanCardBackPhoto: '/pb.jpg',
            ),
          ],
        ),
      );
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsOneWidget);
      expect(find.text('PAN Front'), findsNothing);
      expect(find.text('PAN Back'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3));
    });

    testWidgets('nominee with no images renders without tiles', (tester) async {
      await _pumpCard(
        tester,
        const NomineeDetailsCard(
          nominees: [InvestorNomineeModel(nomineeName: 'Amma')],
        ),
      );
      _expectLabels({});
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
