import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_member_card.dart';
import 'package:sizer/sizer.dart';

/// One or two cards. Two cards share the width equally; a single card gets the
/// same one-column width and is centered.
class TeamMemberRow extends StatelessWidget {
  const TeamMemberRow({super.key, required this.members})
    : assert(members.length == 1 || members.length == 2);

  final List<TeamMember> members;

  @override
  Widget build(BuildContext context) {
    final gap = 5.w;
    if (members.length == 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: cardWidth,
              child: TeamMemberCard(member: members.first),
            ),
          );
        },
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: TeamMemberCard(member: members[0])),
        SizedBox(width: gap),
        Expanded(child: TeamMemberCard(member: members[1])),
      ],
    );
  }
}
