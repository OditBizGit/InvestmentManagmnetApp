import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum AddUpdateOptionType {
  projectPhase,
  statusStories,
  constructionMedia,
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
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 560
                ? 2
                : 1;

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(height: spacing),
                _OptionCard(
                  data: _options[i],
                  selected: selectedOption == _options[i].type,
                  onTap: () => onOptionSelected(_options[i].type),
                ),
              ],
            ],
          );
        }

        if (columns == 3) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(
                  child: _OptionCard(
                    data: _options[i],
                    selected: selectedOption == _options[i].type,
                    onTap: () => onOptionSelected(_options[i].type),
                  ),
                ),
              ],
            ],
          );
        }

        final cardWidth = (width - spacing) / 2;
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
  });

  final _OptionData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      data.icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        data.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.accent : AppColors.white,
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.description,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
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
