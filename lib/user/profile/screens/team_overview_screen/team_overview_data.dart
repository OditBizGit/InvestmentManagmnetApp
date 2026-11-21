import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';

/// One person card on the Team Overview screen.
///
/// Hardcoded, PM-approved static content (not an API model).
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.photoAsset,
  });

  /// Source casing; the card renders it uppercase.
  final String name;
  final String role;
  final String photoAsset;
}

/// One titled group of members (section pill + cards).
class TeamSection {
  const TeamSection({
    required this.title,
    required this.iconPath,
    required this.members,
  });

  final String title;
  final String iconPath;
  final List<TeamMember> members;
}

const TeamMember _naeema = TeamMember(
  name: 'Dr. NAEEMA',
  role: 'MBBS, MD (PMR), 10 Years Exp – Alshifa and Aster MIMS',
  photoAsset: ImageConstants.teamNaeema,
);

const TeamMember _anandhaKishore = TeamMember(
  name: 'Dr. ANANDHA KISHORE',
  role:
      'Sr. Chief Ayurvedic Physician, 26 Years in Kottakkal Arya Vaidya Sala, - Ex Chief Medical Officer',
  photoAsset: ImageConstants.teamAnandhaKishore,
);

const TeamMember _surabhila = TeamMember(
  name: 'Dr. SURABHILA',
  role: 'Sr. Ayurveda & Postnatal Consultant',
  photoAsset: ImageConstants.teamSurabhila,
);

abstract final class TeamOverviewData {
  static const List<TeamSection> sections = [
    TeamSection(
      title: 'Board Members',
      iconPath: ImageConstants.teamBoardMembersIcon,
      members: [
        TeamMember(
          name: 'Shameer',
          role: 'Founder & MD',
          photoAsset: ImageConstants.teamShameer,
        ),
        TeamMember(
          name: 'AZARUDHEEN',
          role: 'Co-Founder & Director',
          photoAsset: ImageConstants.teamAzarudheen,
        ),
        TeamMember(
          name: 'MOHAMMED ALI',
          role: 'Director',
          photoAsset: ImageConstants.teamMohammedAli,
        ),
        TeamMember(
          name: 'MOIDEEN',
          role: 'Director',
          photoAsset: ImageConstants.teamMoideen,
        ),
        TeamMember(
          name: 'Dr. FIDHA FATHIMA',
          role: 'Director',
          photoAsset: ImageConstants.teamFidhaFathima,
        ),
        TeamMember(
          name: 'MUSTHAFA',
          role: 'Director',
          photoAsset: ImageConstants.teamMusthafa,
        ),
      ],
    ),
    TeamSection(
      title: 'Doctors Panel',
      iconPath: ImageConstants.teamDoctorsPanelIcon,
      members: [
        _naeema,
        _anandhaKishore,
        TeamMember(
          name: 'Dr. FIDHA FATHIMA',
          role: 'MBBS, POCERT in Medical Education',
          photoAsset: ImageConstants.teamFidhaFathima,
        ),
        _surabhila,
        TeamMember(
          name: 'Dr. ANJALI J',
          role: 'BAMS, Ayu. Cosmetology & Yoga Specialist',
          photoAsset: ImageConstants.teamAnjaliJ,
        ),
      ],
    ),
    TeamSection(
      title: 'Advisory Committee Membership',
      iconPath: ImageConstants.teamAdvisoryCommitteeIcon,
      members: [
        _naeema,
        _anandhaKishore,
        TeamMember(
          name: 'RANJITH PALLYATH',
          role:
              'Hospitality Consultant, 25 Years Exp in Ritz Carlton and Marriott, Saudi',
          photoAsset: ImageConstants.teamRanjithPallyath,
        ),
        _surabhila,
        TeamMember(
          name: 'MOHAMED BAVA ERANHIKKAL',
          role: 'Chief Administrative Officer',
          photoAsset: ImageConstants.teamMohamedBavaEranhikkal,
        ),
      ],
    ),
  ];
}
