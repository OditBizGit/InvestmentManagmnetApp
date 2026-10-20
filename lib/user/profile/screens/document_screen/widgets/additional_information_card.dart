import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/document_fullscreen_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class AdditionalInformationCard extends StatelessWidget {
  const AdditionalInformationCard({
    super.key,
    this.details,
    this.isLoading = false,
  });

  final InvestorDetailsModel? details;
  final bool isLoading;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return _DocumentCardShell(
      iconPath: ImageConstants.username,
      title: 'Additional information',
      child: isLoading
          ? const _AdditionalInformationShimmer(
              baseColor: _shimmerBase,
              highlightColor: _shimmerHighlight,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.6.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _PhotoAvatar(imageUrl: details?.profileImageUrl),
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
                      (
                        label: 'Aadhaar Photo',
                        imageUrl: details!.aadhaarPhotoUrl!,
                      ),
                    if (_hasValue(details?.panCardPhotoUrl))
                      (
                        label: 'PAN Photo',
                        imageUrl: details!.panCardPhotoUrl!,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _AdditionalInformationShimmer extends StatelessWidget {
  const _AdditionalInformationShimmer({
    required this.baseColor,
    required this.highlightColor,
  });

  final Color baseColor;
  final Color highlightColor;

  static const _fields = [
    ('Aadhaar Card', '0000 0000 0000'),
    ('Pan Card', 'Not Provided'),
    ('Email Address', 'Not Provided'),
  ];

  static const _photos = ['Aadhaar Photo', 'PAN Photo'];

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.6.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 7.w,
                backgroundColor: baseColor,
              ),
            ),
          ),
          for (final field in _fields)
            _ShimmerVerifiedField(
              label: field.$1,
              value: field.$2,
              color: baseColor,
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0.6.h, 4.w, 1.6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _photos.length; i++) ...[
                  if (i > 0) SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerTextBar(
                          text: _photos[i],
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: baseColor,
                        ),
                        SizedBox(height: 0.6.h),
                        Container(
                          width: double.infinity,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerVerifiedField extends StatelessWidget {
  const _ShimmerVerifiedField({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

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
                _ShimmerTextBar(
                  text: label,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
                SizedBox(height: 0.3.h),
                _ShimmerTextBar(
                  text: value,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.8.h),
            child: Container(
              width: 5.5.w,
              height: 5.5.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTextBar extends StatelessWidget {
  const _ShimmerTextBar({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

String _displayValue(String? value) =>
    _hasValue(value) ? value!.trim() : 'Not Provided';

String _formatAadhaar(String? value) {
  if (!_hasValue(value)) return 'Not Provided';
  final digits = value!.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12) {
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
  }
  return value.trim();
}

class _DocumentCardShell extends StatelessWidget {
  const _DocumentCardShell({
    required this.title,
    required this.child,
    required this.iconPath,
  });

  final String title;
  final Widget child;
  final String iconPath;

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
                SvgPicture.asset(
                  iconPath,
                  width: 5.w,
                  height: 5.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
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
            child: Icon(
              isVerified ? Icons.check_circle : Icons.cancel,
              size: 5.5.w,
              color: isVerified ? AppColors.green : AppColors.error,
            ),
          ),
        ],
      ),
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

class _DocumentPhotoRow extends StatelessWidget {
  const _DocumentPhotoRow({required this.photos});

  final List<({String label, String imageUrl})> photos;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photos[i].label,
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
                      imageUrl: photos[i].imageUrl,
                      title: photos[i].label,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: Image.network(
                        photos[i].imageUrl,
                        width: double.infinity,
                        height: 12.h,
                        fit: BoxFit.fill,
                        errorBuilder: (_, _, _) => Container(
                          width: double.infinity,
                          height: 12.h,
                          color: AppColors.cardBg,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            ImageConstants.imageError,
                            width: 10.w,
                            height: 10.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
