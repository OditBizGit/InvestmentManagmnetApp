import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_member_card.dart';

import 'team_overview_test_harness.dart';

Widget _host(Widget card, {double width = 171}) => Scaffold(
  body: SingleChildScrollView(
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: card),
    ),
  ),
);

Image _imageOf(WidgetTester tester) =>
    tester.widget<Image>(find.byType(Image).first);

void main() {
  const member = TeamMember(
    name: 'Dr. NAEEMA',
    role: 'MBBS, MD (PMR)',
    photoAsset: ImageConstants.teamNaeema,
  );

  group('TC-3 TeamMemberCard content', () {
    testWidgets('shows name (uppercase) and role', (tester) async {
      await pumpTeamApp(tester, _host(const TeamMemberCard(member: member)));
      expect(find.text('DR. NAEEMA'), findsOneWidget);
      expect(find.text('MBBS, MD (PMR)'), findsOneWidget);
      final name = tester.widget<Text>(find.text('DR. NAEEMA'));
      expect(name.style!.fontWeight, FontWeight.w600);
      expect(name.style!.color, AppColors.textPrimary);
      expect(name.textAlign, TextAlign.center);
      expect(name.style!.fontSize, closeTo(12.1, 0.3)); // 14.sp at 402
      expect(name.maxLines, isNull);
      expect(name.overflow, isNot(TextOverflow.ellipsis));
      final role = tester.widget<Text>(find.text('MBBS, MD (PMR)'));
      expect(role.style!.fontWeight, FontWeight.w400);
      expect(role.style!.color, AppColors.textMuted);
      expect(role.textAlign, TextAlign.center);
      expect(role.style!.fontSize, closeTo(10.0, 0.3)); // 12.7.sp at 402
      expect(role.maxLines, isNull);
    });

    testWidgets('mixed-case source name is rendered uppercase', (tester) async {
      await pumpTeamApp(
        tester,
        _host(
          const TeamMemberCard(
            member: TeamMember(
              name: 'Shameer',
              role: 'Founder & MD',
              photoAsset: ImageConstants.teamShameer,
            ),
          ),
        ),
      );
      expect(find.text('SHAMEER'), findsOneWidget);
    });

    testWidgets('uses an Image.asset with the member\'s own photo', (
      tester,
    ) async {
      await pumpTeamApp(tester, _host(const TeamMemberCard(member: member)));
      final image = _imageOf(tester);
      expect(image.image, isA<ResizeImage>());
      final resize = image.image as ResizeImage;
      expect(resize.imageProvider, isA<AssetImage>());
      expect(
        (resize.imageProvider as AssetImage).assetName,
        ImageConstants.teamNaeema,
      );
      expect(image.fit, BoxFit.cover);
      expect(image.errorBuilder, isNotNull);
    });

    testWidgets('cacheWidth is set (> 0), capped at 1080, width only', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        _host(const TeamMemberCard(member: member)),
        devicePixelRatio: 3,
      );
      final resize = _imageOf(tester).image as ResizeImage;
      expect(resize.width, isNotNull);
      expect(resize.width!, greaterThan(0));
      expect(resize.width!, lessThanOrEqualTo(1080));
      expect(resize.height, isNull);
      // 1.4925 * 171 * 3 = 765.6 -> ~766
      expect(resize.width!, closeTo(1.4925 * 171 * 3, 3));
    });

    testWidgets('cacheWidth never exceeds the 1080 source width', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        _host(const TeamMemberCard(member: member), width: 400),
        devicePixelRatio: 3,
      );
      expect((_imageOf(tester).image as ResizeImage).width, 1080);
    });

    testWidgets('missing asset shows nothing and throws nothing', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        _host(
          const TeamMemberCard(
            member: TeamMember(
              name: 'Ghost',
              role: 'Missing photo',
              photoAsset: 'assets/team/does_not_exist.png',
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('GHOST'), findsOneWidget);
    });

    test('feature folder has no network, url_launcher or state-mgmt code', () {
      final dir = Directory('lib/user/profile/screens/team_overview_screen');
      expect(dir.existsSync(), isTrue);
      final forbidden = [
        'Image.network',
        'NetworkImage',
        'url_launcher',
        'Cubit',
        'BlocProvider',
        'BlocBuilder',
        'getIt',
        'Dio',
        'http',
      ];
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      expect(files, isNotEmpty);
      for (final f in files) {
        final src = f.readAsStringSync();
        for (final token in forbidden) {
          expect(src.contains(token), isFalse, reason: '${f.path}: $token');
        }
      }
    });
  });

  group('TC-5 photo crop geometry', () {
    testWidgets('block ratio, photo box fractions, arch fractions', (
      tester,
    ) async {
      await pumpTeamApp(tester, _host(const TeamMemberCard(member: member)));
      final blockFinder = find.byKey(TeamMemberCard.photoBlockKey);
      final photoFinder = find.byKey(TeamMemberCard.photoBoxKey);
      final archFinder = find.byKey(TeamMemberCard.archKey);
      expect(blockFinder, findsOneWidget);
      expect(photoFinder, findsOneWidget);
      expect(archFinder, findsOneWidget);

      final block = tester.getRect(blockFinder);
      final w = block.width;
      final h = block.height;
      expect(w, closeTo(171, 0.01));
      expect(w / h, closeTo(171 / 158.1, 0.001));

      final photo = tester.getRect(photoFinder);
      expect(photo.width / w, closeTo(1.4925, 0.001));
      expect(photo.height / h, closeTo(1.6073, 0.001));
      expect((photo.left - block.left) / w, closeTo(-0.2463, 0.001));
      expect((photo.top - block.top) / h, closeTo(-0.2331, 0.001));

      final arch = tester.getRect(archFinder);
      expect(arch.width / w, closeTo(0.946, 0.001));
      expect(arch.height / h, closeTo(0.819, 0.001));
      expect((arch.left - block.left) / w, closeTo(0.027, 0.001));
      expect((arch.top - block.top) / h, closeTo(0.181, 0.001));
    });

    testWidgets('photo is clipped to the block', (tester) async {
      await pumpTeamApp(tester, _host(const TeamMemberCard(member: member)));
      final clip = find.descendant(
        of: find.byKey(TeamMemberCard.photoBlockKey),
        matching: find.byType(ClipRect),
      );
      expect(clip, findsOneWidget);
      final stack = tester.widget<Stack>(
        find.descendant(of: clip, matching: find.byType(Stack)).first,
      );
      expect(stack.clipBehavior, Clip.hardEdge);
    });

    testWidgets('arch is accent at 12% opacity with round top corners', (
      tester,
    ) async {
      await pumpTeamApp(tester, _host(const TeamMemberCard(member: member)));
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(TeamMemberCard.archKey),
          matching: find.byType(DecoratedBox),
        ),
      );
      final deco = box.decoration as BoxDecoration;
      expect(deco.color, isNotNull);
      expect(deco.color!.toARGB32() & 0x00FFFFFF, 0xA28CC1);
      expect(deco.color!.a, closeTo(0.12, 0.005));
      final radius = deco.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 99);
      expect(radius.topRight.x, 99);
      expect(radius.bottomLeft, Radius.zero);
      expect(radius.bottomRight, Radius.zero);
    });

    testWidgets('card width scales with its parent (no literal 171)', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        _host(const TeamMemberCard(member: member), width: 140),
      );
      final block = tester.getRect(find.byKey(TeamMemberCard.photoBlockKey));
      expect(block.width, closeTo(140, 0.01));
      expect(block.width / block.height, closeTo(171 / 158.1, 0.001));
    });
  });

  group('TC-8 card stress', () {
    testWidgets('very long role and unbreakable long name at 320, scale 2', (
      tester,
    ) async {
      await pumpTeamApp(
        tester,
        _host(
          TeamMemberCard(
            member: TeamMember(
              name: 'A' * 60,
              role: 'Very long role text ' * 20,
              photoAsset: ImageConstants.teamShameer,
            ),
          ),
          width: 140,
        ),
        size: const Size(320, 640),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
