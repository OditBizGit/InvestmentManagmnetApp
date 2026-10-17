import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_nominee_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/widgets/document_fullscreen_image.dart';
import 'package:sizer/sizer.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key, this.details});

  final InvestorDetailsModel? details;

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String _displayValue(String? value) =>
      _hasValue(value) ? value!.trim() : 'Not Provided';

  static String _formatAadhaar(String? value) {
    if (!_hasValue(value)) return 'Not Provided';
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
    }
    return value.trim();
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not Provided';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
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
                        'Documents',
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
                    // _SectionCard(
                    //   iconPath: ImageConstants.deliveredDocuments,
                    //   title: 'Delivered documents',
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       Padding(
                    //         padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.h),
                    //         child: Row(
                    //           children: [
                    //             Expanded(
                    //               child: _ReceiptStat(
                    //                 label: 'Generate Receipt',
                    //                 value: '05',
                    //                 valueColor: AppColors.green,
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: _ReceiptStat(
                    //                 label: 'Delivered Receipt',
                    //                 value: '03',
                    //                 valueColor: AppColors.accent,
                    //                 alignment: CrossAxisAlignment.end,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       _StatusRow(label: 'MOU', isVerified: true),
                    //       _StatusRow(
                    //         label: 'Contribution Agreement',
                    //         isVerified: false,
                    //       ),
                    //       _StatusRow(
                    //         label: 'Share Certificate',
                    //         isVerified: false,
                    //       ),
                    //       SizedBox(height: 0.6.h),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 1.8.h),
                    _SectionCard(
                      iconPath: ImageConstants.username,
                      title: 'Additional information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.6.h),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _PhotoAvatar(
                                imageUrl: details?.profileImageUrl,
                              ),
                            ),
                          ),
                          _VerifiedField(
                            label: 'Aadhaar Card',
                            value: _formatAadhaar(details?.aadhaarNumber),
                            isVerified: _hasValue(details?.aadhaarNumber),
                          ),
                          _VerifiedField(
                            label: 'Pan Card',
                            value: _displayValue(details?.panCardNumber),
                            isVerified: _hasValue(details?.panCardNumber),
                          ),
                          _VerifiedField(
                            label: 'Email Address',
                            value: _displayValue(details?.email),
                            isVerified: _hasValue(details?.email),
                          ),
                          _DocumentPhotoRow(
                            photos: [
                              if (_hasValue(details?.aadhaarPhotoUrl))
                                _DocumentPhotoData(
                                  label: 'Aadhaar Photo',
                                  imageUrl: details!.aadhaarPhotoUrl!,
                                ),
                              if (_hasValue(details?.panCardPhotoUrl))
                                _DocumentPhotoData(
                                  label: 'PAN Photo',
                                  imageUrl: details!.panCardPhotoUrl!,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.8.h),
                    _SectionCard(
                      iconPath: ImageConstants.bankDetails,
                      title: 'Bank Details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.4.h),
                            child: Text(
                              _displayValue(details?.bankName),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _VerifiedField(
                            label: 'Account No',
                            value: _displayValue(details?.accountNumber),
                            isVerified: _hasValue(details?.accountNumber),
                          ),
                          _VerifiedField(
                            label: 'IFSC Code',
                            value: _displayValue(details?.ifscCode),
                            isVerified: _hasValue(details?.ifscCode),
                          ),
                          SizedBox(height: 0.6.h),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.8.h),
                    _SectionCard(
                      iconPath: ImageConstants.nomineeDetails,
                      title: 'Nominee Details',
                      child: _NomineeDetails(nominees: details?.nominees ?? const []),
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
            //             builder: (_) => const RegisterComplaintScreen(),
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
            //         'Complaint Register?',
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

class _NomineeDetails extends StatelessWidget {
  const _NomineeDetails({required this.nominees});

  final List<InvestorNomineeModel> nominees;

  @override
  Widget build(BuildContext context) {
    final items = nominees.isEmpty
        ? const [InvestorNomineeModel()]
        : nominees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
              indent: 4.w,
              endIndent: 4.w,
            ),
          if (items.length > 1)
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 0),
              child: Text(
                'Nominee ${i + 1}',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          _NomineeBlock(nominee: items[i]),
        ],
        SizedBox(height: 0.6.h),
      ],
    );
  }
}

class _NomineeBlock extends StatelessWidget {
  const _NomineeBlock({required this.nominee});

  final InvestorNomineeModel nominee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.6.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _PhotoAvatar(imageUrl: nominee.nomineeProfilePhotoUrl),
          ),
        ),
        _VerifiedField(
          label: 'Nominee Full Name',
          value: DocumentsScreen._displayValue(nominee.nomineeName),
          isVerified: DocumentsScreen._hasValue(nominee.nomineeName),
        ),
        _VerifiedField(
          label: 'Relationship',
          value: DocumentsScreen._displayValue(nominee.nomineeRelationship),
          isVerified: DocumentsScreen._hasValue(nominee.nomineeRelationship),
        ),
        _VerifiedField(
          label: 'Phone Number',
          value: DocumentsScreen._displayValue(nominee.nomineePhoneNumber),
          isVerified: DocumentsScreen._hasValue(nominee.nomineePhoneNumber),
        ),
        _VerifiedField(
          label: 'Address',
          value: DocumentsScreen._displayValue(nominee.nomineeAddress),
          isVerified: DocumentsScreen._hasValue(nominee.nomineeAddress),
        ),
        _VerifiedField(
          label: 'Aadhaar Card',
          value: DocumentsScreen._formatAadhaar(nominee.nomineeAadhaarNumber),
          isVerified: DocumentsScreen._hasValue(nominee.nomineeAadhaarNumber),
        ),
        _VerifiedField(
          label: 'Pan Card',
          value: DocumentsScreen._displayValue(nominee.nomineePanCardNumber),
          isVerified: DocumentsScreen._hasValue(nominee.nomineePanCardNumber),
        ),
        _DocumentPhotoRow(
          photos: [
            if (DocumentsScreen._hasValue(nominee.nomineeAadhaarPhotoUrl))
              _DocumentPhotoData(
                label: 'Aadhaar Photo',
                imageUrl: nominee.nomineeAadhaarPhotoUrl!,
              ),
            if (DocumentsScreen._hasValue(nominee.nomineePanCardPhotoUrl))
              _DocumentPhotoData(
                label: 'PAN Photo',
                imageUrl: nominee.nomineePanCardPhotoUrl!,
              ),
          ],
        ),
      ],
    );
  }
}

class _DocumentPhotoData {
  const _DocumentPhotoData({
    required this.label,
    required this.imageUrl,
  });

  final String label;
  final String imageUrl;
}

class _DocumentPhotoRow extends StatelessWidget {
  const _DocumentPhotoRow({required this.photos});

  final List<_DocumentPhotoData> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.6.h, 4.w, 1.6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < photos.length; i++) ...[
            if (i > 0) SizedBox(width: 3.w),
            Expanded(
              child: _DocumentPhoto(
                label: photos[i].label,
                imageUrl: photos[i].imageUrl,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentPhoto extends StatelessWidget {
  const _DocumentPhoto({
    required this.label,
    required this.imageUrl,
  });

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 0.6.h),
        GestureDetector(
          onTap: () => DocumentFullscreenImage.open(
            context,
            imageUrl: imageUrl,
            title: label,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.w),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 12.h,
              fit: BoxFit.fill,
              errorBuilder: (_, _, _) => Container(
                width: double.infinity,
                height: 16.h,
                color: AppColors.cardBg,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.hint,
                  size: 6.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoAvatar extends StatelessWidget {
  const _PhotoAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 7.w,
      backgroundColor: AppColors.cardBg,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Icon(
              Icons.person_rounded,
              size: 7.w,
              color: AppColors.accent,
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.iconPath,
    this.icon,
  });

  final String title;
  final Widget child;
  final String? iconPath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.4.h),
            child: Row(
              children: [
                if (iconPath != null)
                  SvgPicture.asset(
                    iconPath!,
                    width: 5.w,
                    height: 5.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 5.w, color: AppColors.accent),
                SizedBox(width: 2.5.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
            indent: 4.w,
            endIndent: 4.w,
          ),
          child,
        ],
      ),
    );
  }
}

class _ReceiptStat extends StatelessWidget {
  const _ReceiptStat({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.isVerified,
  });

  final String label;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StatusIcon(isVerified: isVerified),
        ],
      ),
    );
  }
}

class _VerifiedField extends StatelessWidget {
  const _VerifiedField({
    required this.label,
    required this.value,
    required this.isVerified,
  });

  final String label;
  final String value;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.8.h),
            child: _StatusIcon(isVerified: isVerified),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Icon(
        Icons.check_circle,
        size: 5.5.w,
        color: AppColors.green,
      );
    }

    return Icon(
      Icons.cancel,
      size: 5.5.w,
      color: AppColors.error,
    );
  }
}
