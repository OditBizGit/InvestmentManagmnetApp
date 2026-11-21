import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';

void main() {
  final photos = <String>[
    ImageConstants.teamShameer,
    ImageConstants.teamAzarudheen,
    ImageConstants.teamMohammedAli,
    ImageConstants.teamMoideen,
    ImageConstants.teamFidhaFathima,
    ImageConstants.teamMusthafa,
    ImageConstants.teamNaeema,
    ImageConstants.teamAnandhaKishore,
    ImageConstants.teamSurabhila,
    ImageConstants.teamAnjaliJ,
    ImageConstants.teamRanjithPallyath,
    ImageConstants.teamMohamedBavaEranhikkal,
  ];
  final icons = <String>[
    ImageConstants.teamBoardMembersIcon,
    ImageConstants.teamDoctorsPanelIcon,
    ImageConstants.teamAdvisoryCommitteeIcon,
  ];

  group('TC-1 team assets', () {
    test('12 distinct photo constants, all under assets/team/ and .png', () {
      expect(photos.toSet().length, 12);
      for (final p in photos) {
        expect(p, startsWith('assets/team/'));
        expect(p, endsWith('.png'));
      }
    });

    test('every photo exists, is non-empty and is 1080x1080', () {
      for (final p in photos) {
        final file = File(p);
        expect(file.existsSync(), isTrue, reason: '$p missing');
        final bytes = file.readAsBytesSync();
        expect(bytes.length, greaterThan(0), reason: p);
        // PNG signature + IHDR width/height (big endian at byte 16 / 20).
        expect(bytes.sublist(1, 4), [0x50, 0x4E, 0x47], reason: '$p not PNG');
        final data = ByteData.sublistView(bytes);
        expect(data.getUint32(16), 1080, reason: '$p width');
        expect(data.getUint32(20), 1080, reason: '$p height');
      }
    });

    test('every icon exists and uses only white colours (no var())', () {
      for (final p in icons) {
        final file = File(p);
        expect(file.existsSync(), isTrue, reason: '$p missing');
        final svg = file.readAsStringSync();
        expect(svg, isNotEmpty);
        expect(svg.contains('var('), isFalse, reason: p);
        final colors = RegExp(
          r'(?:fill|stroke)="([^"]+)"',
        ).allMatches(svg).map((m) => m.group(1)!.toLowerCase()).toSet();
        expect(colors, isNotEmpty, reason: p);
        for (final c in colors) {
          expect(
            ['white', '#fff', '#ffffff', 'none'].contains(c),
            isTrue,
            reason: '$p has non-white colour $c',
          );
        }
      }
    });

    test('all 12 photos are used by the data and all resolve to files', () {
      final used = TeamOverviewData.sections
          .expand((s) => s.members)
          .map((m) => m.photoAsset)
          .toSet();
      expect(used, photos.toSet());
      for (final p in used) {
        expect(File(p).existsSync(), isTrue, reason: p);
      }
    });

    test('section icons in data are the three team icon constants', () {
      expect(TeamOverviewData.sections.map((s) => s.iconPath).toList(), icons);
    });

    test('pubspec.yaml declares assets/team/', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/team/'));
    });
  });
}
