import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_member_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_section_header.dart';

import 'team_overview_test_harness.dart';

Finder _cardWithName(String upperName, {int index = 0}) => find
    .ancestor(
      of: find.text(upperName).at(index),
      matching: find.byType(TeamMemberCard),
    )
    .first;

void main() {
  group('TC-6 screen content', () {
    testWidgets('3 headers in order with the right icons, 16 cards/photos', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());

      final headers = find.byType(TeamSectionHeader);
      expect(headers, findsNWidgets(3));
      final titles = [
        'Board Members',
        'Doctors Panel',
        'Advisory Committee Membership',
      ];
      final icons = [
        ImageConstants.teamBoardMembersIcon,
        ImageConstants.teamDoctorsPanelIcon,
        ImageConstants.teamAdvisoryCommitteeIcon,
      ];
      double lastTop = -1;
      for (var i = 0; i < 3; i++) {
        final header = headers.at(i);
        expect(
          find.descendant(of: header, matching: find.text(titles[i])),
          findsOneWidget,
        );
        final svg = tester.widget<SvgPicture>(
          find.descendant(of: header, matching: find.byType(SvgPicture)),
        );
        expect((svg.bytesLoader as SvgAssetLoader).assetName, icons[i]);
        final top = tester.getTopLeft(header).dy;
        expect(top, greaterThan(lastTop));
        lastTop = top;
      }

      expect(find.byType(TeamMemberCard), findsNWidgets(16));
      expect(find.byType(Image), findsNWidgets(16));
    });

    testWidgets('every name and role is reachable by scrolling', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());
      final scrollable = find.byType(Scrollable).first;
      const texts = [
        'SHAMEER',
        'Founder & MD',
        'AZARUDHEEN',
        'MOHAMMED ALI',
        'MOIDEEN',
        'MUSTHAFA',
        'DR. ANJALI J',
        'BAMS, Ayu. Cosmetology & Yoga Specialist',
        'RANJITH PALLYATH',
        'MOHAMED BAVA ERANHIKKAL',
        'Chief Administrative Officer',
      ];
      for (final t in texts) {
        await tester.scrollUntilVisible(
          find.text(t),
          300,
          scrollable: scrollable,
        );
        expect(find.text(t), findsOneWidget, reason: t);
      }
      // People shown in two sections appear twice.
      expect(find.text('DR. NAEEMA'), findsNWidgets(2));
      expect(find.text('DR. ANANDHA KISHORE'), findsNWidgets(2));
      expect(find.text('DR. SURABHILA'), findsNWidgets(2));
      expect(find.text('DR. FIDHA FATHIMA'), findsNWidgets(2));
    });

    testWidgets('each card shows its own photo (no swapped photos)', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());
      const expected = {
        'SHAMEER': ImageConstants.teamShameer,
        'AZARUDHEEN': ImageConstants.teamAzarudheen,
        'MOHAMMED ALI': ImageConstants.teamMohammedAli,
        'MOIDEEN': ImageConstants.teamMoideen,
        'MUSTHAFA': ImageConstants.teamMusthafa,
        'DR. ANJALI J': ImageConstants.teamAnjaliJ,
        'RANJITH PALLYATH': ImageConstants.teamRanjithPallyath,
        'MOHAMED BAVA ERANHIKKAL': ImageConstants.teamMohamedBavaEranhikkal,
      };
      for (final entry in expected.entries) {
        final image = tester.widget<Image>(
          find.descendant(
            of: _cardWithName(entry.key),
            matching: find.byType(Image),
          ),
        );
        final provider = (image.image as ResizeImage).imageProvider;
        expect(
          (provider as AssetImage).assetName,
          entry.value,
          reason: entry.key,
        );
      }
    });
  });

  group('TC-7 layout geometry', () {
    testWidgets('pairs: two equal columns with 5.w gap, tops aligned', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());
      final left = tester.getRect(_cardWithName('SHAMEER'));
      final right = tester.getRect(_cardWithName('AZARUDHEEN'));
      expect(left.width, closeTo(right.width, 0.01));
      expect(left.width, closeTo((402 * 0.9 - 402 * 0.05) / 2, 0.05));
      expect(right.left - left.right, closeTo(402 * 0.05, 0.05));
      expect(left.top, closeTo(right.top, 0.01));
      expect(left.left, closeTo(402 * 0.05, 0.05));
      expect(right.right, closeTo(402 * 0.95, 0.05));
    });

    testWidgets('single cards: one-column width, horizontally centered', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());
      final pairWidth = tester.getRect(_cardWithName('SHAMEER')).width;
      final scrollable = find.byType(Scrollable).first;
      for (final name in ['DR. ANJALI J', 'MOHAMED BAVA ERANHIKKAL']) {
        await tester.scrollUntilVisible(
          find.text(name),
          300,
          scrollable: scrollable,
        );
        final card = tester.getRect(_cardWithName(name));
        expect(card.width, closeTo(pairWidth, 0.05), reason: name);
        expect(card.center.dx, closeTo(201, 0.1), reason: name);
      }
    });
  });

  group('TC-8 no overflow or exceptions', () {
    const sizes = [
      Size(320, 640),
      Size(360, 800),
      Size(402, 874),
      Size(430, 932),
    ];
    for (final size in sizes) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets(
          '${size.width.toInt()}x${size.height.toInt()} scale $scale',
          (tester) async {
            await pumpTeamApp(
              tester,
              const TeamOverviewScreen(),
              size: size,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            // Scroll through the whole body: any layout exception surfaces.
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -20000),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('TC-9 header', () {
    testWidgets('shows title and back arrow pops the route', (tester) async {
      await pumpTeamApp(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TeamOverviewScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Team Overview'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Team Overview'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('title uses sibling header style (w600, textPrimary)', (
      tester,
    ) async {
      await pumpTeamApp(tester, const TeamOverviewScreen());
      final title = tester.widget<Text>(find.text('Team Overview'));
      expect(title.style!.fontWeight, FontWeight.w600);
    });
  });

  group('TC-14 bottom safe area', () {
    testWidgets(
      'last card fully visible above a 34px bottom inset at 320x640',
      (tester) async {
        await pumpTeamApp(
          tester,
          const TeamOverviewScreen(),
          size: const Size(320, 640),
          bottomInset: 34,
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -20000),
        );
        await tester.pump();
        final card = tester.getRect(_cardWithName('MOHAMED BAVA ERANHIKKAL'));
        expect(card.bottom, lessThanOrEqualTo(640 - 34 + 0.01));
        expect(card.top, greaterThanOrEqualTo(0));
      },
    );
  });
}
