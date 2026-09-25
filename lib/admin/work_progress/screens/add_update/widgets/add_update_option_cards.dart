import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum AddUpdateOptionType {
  projectPhase,
  statusStories,
  constructionMedia,
  banner,
}

class AddUpdateOptionCards extends StatelessWidget {
  const AddUpdateOptionCards({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  final AddUpdateOptionType? selectedOption;
  final ValueChanged<AddUpdateOptionType> onOptionSelected;

  static const List<_OptionData> _options = [
    _OptionData(
      type: AddUpdateOptionType.projectPhase,
      title: 'Update Project Phase',
      description:
          'Update construction stages, progress percentage, assigned team, and status for the project timeline.',
      icon: ImageConstants.workProgress,
      iconColor: Color(0xFF9B7EBF),
      iconBg: Color(0xFFF0EBF6),
    ),
    _OptionData(
      type: AddUpdateOptionType.statusStories,
      title: 'Status & Stories Media',
      description:
          'Upload photos and videos for status and stories to share project highlights on social media.',
      icon: ImageConstants.createUpdates,
      iconColor: Color(0xFF2CB5A8),
      iconBg: Color(0xFFE6F7F5),
    ),
    _OptionData(
      type: AddUpdateOptionType.constructionMedia,
      title: 'Construction Photos & Videos',
      description:
          'Add construction site photos and videos to document ongoing work and site progress.',
      icon: ImageConstants.photosVideos,
      iconColor: Color(0xFF5B8DEF),
      iconBg: Color(0xFFEAF1FC),
    ),
    _OptionData(
      type: AddUpdateOptionType.banner,
      title: 'Add Banner',
      description:
          'Upload banner images for the app home screen. Preview added banners and remove any you no longer need.',
      icon: ImageConstants.uploadPhoto,
      iconColor: Color(0xFFE89A3C),
      iconBg: Color(0xFFFFF3E8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;
        // Prefer a single row of 4 whenever there is room.
        final columns = width >= 720
            ? 4
            : width >= 480
                ? 2
                : 1;
        final compact = columns == 4;

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(height: spacing),
                _OptionCard(
                  data: _options[i],
                  selected: selectedOption == _options[i].type,
                  compact: compact,
                  onTap: () => onOptionSelected(_options[i].type),
                ),
              ],
            ],
          );
        }

        if (columns == 4) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(
                  child: _OptionCard(
                    data: _options[i],
                    selected: selectedOption == _options[i].type,
                    compact: compact,
                    onTap: () => onOptionSelected(_options[i].type),
                  ),
                ),
              ],
            ],
          );
        }

        final cardWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final option in _options)
              SizedBox(
                width: cardWidth,
                child: _OptionCard(
                  data: option,
                  selected: selectedOption == option.type,
                  compact: compact,
                  onTap: () => onOptionSelected(option.type),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OptionData {
  const _OptionData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final AddUpdateOptionType type;
  final String title;
  final String description;
  final String icon;
  final Color iconColor;
  final Color iconBg;
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.data,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final _OptionData data;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 12.0 : 14.0;
    final padding = compact ? 14.0 : 20.0;
    final iconSize = compact ? 36.0 : 48.0;
    final iconAssetSize = compact ? 18.0 : 24.0;
    final checkSize = compact ? 18.0 : 22.0;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: compact ? 8 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(compact ? 10 : 12),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      data.icon,
                      width: iconAssetSize,
                      height: iconAssetSize,
                      colorFilter: ColorFilter.mode(
                        data.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: checkSize,
                    height: checkSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.accent : AppColors.white,
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: compact ? 12 : 14,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                data.title,
                maxLines: compact ? 2 : null,
                overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
                style: TextStyle(
                  fontSize: compact ? 10.sp : 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                data.description,
                maxLines: compact ? 3 : null,
                overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
                style: TextStyle(
                  fontSize: compact ? 8.5.sp : 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              SizedBox(height: compact ? 12 : 18),
              Row(
                children: [
                  Text(
                    'Select',
                    style: TextStyle(
                      fontSize: compact ? 9.sp : 10.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: compact ? 14 : 16,
                    color: selected ? AppColors.accent : AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
