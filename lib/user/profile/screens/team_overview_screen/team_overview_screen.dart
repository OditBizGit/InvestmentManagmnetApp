import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_member_row.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/widgets/team_section_header.dart';
import 'package:sizer/sizer.dart';

/// Static Team Overview screen (hardcoded content, local photos).
class TeamOverviewScreen extends StatelessWidget {
  const TeamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Vertical gap between blocks: Figma 12 of 402.
    final blockGap = 3.w;
    final blocks = <Widget>[];
    for (final section in TeamOverviewData.sections) {
      blocks.add(
        TeamSectionHeader(iconPath: section.iconPath, title: section.title),
      );
      final members = section.members;
      for (var i = 0; i < members.length; i += 2) {
        final end = i + 2 <= members.length ? i + 2 : members.length;
        blocks.add(TeamMemberRow(members: members.sublist(i, end)));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      // Flexible only so a very large text scale wraps instead
                      // of overflowing; looks identical to the sibling header.
                      Flexible(
                        child: Text(
                          'Team Overview',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 3.w, 5.w, 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < blocks.length; i++) ...[
                      if (i > 0) SizedBox(height: blockGap),
                      blocks[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
