import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';

const _naeemaRole = 'MBBS, MD (PMR), 10 Years Exp – Alshifa and Aster MIMS';
const _anandhaRole =
    'Sr. Chief Ayurvedic Physician, 26 Years in Kottakkal Arya Vaidya Sala, - Ex Chief Medical Officer';

void main() {
  final sections = TeamOverviewData.sections;

  List<(String, String)> pairs(int i) =>
      sections[i].members.map((m) => (m.name, m.role)).toList();

  group('TC-2 team overview data', () {
    test('three sections with exact titles in order', () {
      expect(sections.map((s) => s.title).toList(), [
        'Board Members',
        'Doctors Panel',
        'Advisory Committee Membership',
      ]);
    });

    test('member counts are 6 / 5 / 5', () {
      expect(sections.map((s) => s.members.length).toList(), [6, 5, 5]);
    });

    test('board members: exact names and roles', () {
      expect(pairs(0), [
        ('Shameer', 'Founder & MD'),
        ('AZARUDHEEN', 'Co-Founder & Director'),
        ('MOHAMMED ALI', 'Director'),
        ('MOIDEEN', 'Director'),
        ('Dr. FIDHA FATHIMA', 'Director'),
        ('MUSTHAFA', 'Director'),
      ]);
    });

    test('doctors panel: exact names and roles (incl. en dash)', () {
      expect(pairs(1), [
        ('Dr. NAEEMA', _naeemaRole),
        ('Dr. ANANDHA KISHORE', _anandhaRole),
        ('Dr. FIDHA FATHIMA', 'MBBS, POCERT in Medical Education'),
        ('Dr. SURABHILA', 'Sr. Ayurveda & Postnatal Consultant'),
        ('Dr. ANJALI J', 'BAMS, Ayu. Cosmetology & Yoga Specialist'),
      ]);
    });

    test('advisory committee: exact names and roles', () {
      expect(pairs(2), [
        ('Dr. NAEEMA', _naeemaRole),
        ('Dr. ANANDHA KISHORE', _anandhaRole),
        (
          'RANJITH PALLYATH',
          'Hospitality Consultant, 25 Years Exp in Ritz Carlton and Marriott, Saudi',
        ),
        ('Dr. SURABHILA', 'Sr. Ayurveda & Postnatal Consultant'),
        ('MOHAMED BAVA ERANHIKKAL', 'Chief Administrative Officer'),
      ]);
    });

    test('each member carries its own photo constant', () {
      String photo(int s, int i) => sections[s].members[i].photoAsset;
      expect(photo(0, 0), ImageConstants.teamShameer);
      expect(photo(0, 1), ImageConstants.teamAzarudheen);
      expect(photo(0, 2), ImageConstants.teamMohammedAli);
      expect(photo(0, 3), ImageConstants.teamMoideen);
      expect(photo(0, 4), ImageConstants.teamFidhaFathima);
      expect(photo(0, 5), ImageConstants.teamMusthafa);
      expect(photo(1, 0), ImageConstants.teamNaeema);
      expect(photo(1, 1), ImageConstants.teamAnandhaKishore);
      expect(photo(1, 2), ImageConstants.teamFidhaFathima);
      expect(photo(1, 3), ImageConstants.teamSurabhila);
      expect(photo(1, 4), ImageConstants.teamAnjaliJ);
      expect(photo(2, 0), ImageConstants.teamNaeema);
      expect(photo(2, 1), ImageConstants.teamAnandhaKishore);
      expect(photo(2, 2), ImageConstants.teamRanjithPallyath);
      expect(photo(2, 3), ImageConstants.teamSurabhila);
      expect(photo(2, 4), ImageConstants.teamMohamedBavaEranhikkal);
    });
  });
}
