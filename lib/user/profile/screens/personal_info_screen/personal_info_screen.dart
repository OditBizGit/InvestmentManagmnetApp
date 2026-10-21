import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/personal_info_screen/widgets/personal_info_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/personal_info_screen/widgets/relationship_manager_card.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key, this.details});

  final InvestorDetailsModel? details;

  static String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not Provided';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: Column(
                  children: [
                    PersonalInfoCard(details: details),
                    SizedBox(height: 1.8.h),
                    RelationshipManagerCard(
                      name: _displayValue(details?.staffName),
                      phoneNumber: _displayValue(details?.staffPhoneNumber),
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.5.h),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: OutlinedButton(
            //       onPressed: () {
            //         Navigator.of(context).push(
            //           MaterialPageRoute<void>(
            //             builder: (_) => const ChangeRequestScreen(),
            //           ),
            //         );
            //       },
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: AppColors.accent,
            //         side: const BorderSide(color: AppColors.border),
            //         padding: EdgeInsets.symmetric(vertical: 1.8.h),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(3.w),
            //         ),
            //       ),
            //       child: Text(
            //         'Change Request?',
            //         style: TextStyle(
            //           fontSize: 15.sp,
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.accent,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
