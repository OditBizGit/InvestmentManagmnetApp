import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_section_header.dart';

import 'team_overview_test_harness.dart';

void main() {
  group('TC-4 TeamSectionHeader', () {
    testWidgets('shows title, svg icon, accent fill and radius 8', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        const Scaffold(
          body: TeamSectionHeader(
            iconPath: ImageConstants.teamBoardMembersIcon,
            title: 'Board Members',
          ),
        ),
      );
      expect(find.text('Board Members'), findsOneWidget);
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        (svg.bytesLoader as SvgAssetLoader).assetName,
        ImageConstants.teamBoardMembersIcon,
      );
      expect(svg.colorFilter, isNull, reason: 'icons are white, not tinted');

      final deco = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color == AppColors.accent);
      final radius = (deco.borderRadius! as BorderRadius).topLeft.x;
      expect(radius, closeTo(8, 0.2));

      final text = tester.widget<Text>(find.text('Board Members'));
      expect(text.style!.color, Colors.white);
      expect(text.style!.fontWeight, FontWeight.w600);
      expect(text.maxLines, isNull);

      final pill = tester.getRect(find.byType(TeamSectionHeader));
      expect(pill.width, closeTo(402, 0.01), reason: 'full width');
      // Figma pill is ~34 px high at 402; title is ~12 px (14.sp, quadratic).
      expect(pill.height, closeTo(34, 1.5));
      expect(text.style!.fontSize, closeTo(12.1, 0.3));
    });

    testWidgets('title sits in an Expanded so long titles wrap', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        const Scaffold(
          body: TeamSectionHeader(
            iconPath: ImageConstants.teamAdvisoryCommitteeIcon,
            title: 'Advisory Committee Membership',
          ),
        ),
        size: const Size(320, 640),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      expect(
        find.ancestor(
          of: find.text('Advisory Committee Membership'),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });
  });
}
