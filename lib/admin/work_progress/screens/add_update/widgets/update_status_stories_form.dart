import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/add_update_option_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class UpdateStatusStoriesForm extends StatefulWidget {
  const UpdateStatusStoriesForm({
    super.key,
    this.initial,
    required this.onSave,
  });

  final MediaUpdate? initial;
  final ValueChanged<MediaUpdate> onSave;

  @override
  State<UpdateStatusStoriesForm> createState() =>
      _UpdateStatusStoriesFormState();
}

class _UpdateStatusStoriesFormState extends State<UpdateStatusStoriesForm> {
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _descriptionController.text = widget.initial!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleUpload() {
    final description = _descriptionController.text.trim();
    final existing = widget.initial;

    widget.onSave(
      MediaUpdate(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: AddUpdateOptionType.statusStories,
        description: description,
        updatedAt: DateTime.now(),
      ),
    );

    if (existing == null) {
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Status & Stories Media' : 'Status & Stories Media',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEditing
                ? 'Update the description and media details, then save your changes'
                : 'Upload photos and videos with a description for social media status and stories',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 560;

              final photoZone = _DummyUploadZone(
                title: 'Upload Photo',
                subtitle: 'PNG, JPG up to 10MB',
                icon: ImageConstants.uploadPhoto,
                iconColor: const Color(0xFF2CB5A8),
                iconBg: const Color(0xFFE6F7F5),
              );
              final videoZone = _DummyUploadZone(
                title: 'Upload Video',
                subtitle: 'MP4, MOV up to 50MB',
                icon: ImageConstants.uploadVideo,
                iconColor: const Color(0xFF5B8DEF),
                iconBg: const Color(0xFFEAF1FC),
              );

              if (!twoCol) {
                return Column(
                  children: [
                    photoZone,
                    const SizedBox(height: 14),
                    videoZone,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: photoZone),
                  const SizedBox(width: 14),
                  Expanded(child: videoZone),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Add a short description for status or stories',
              hintStyle: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
              ),
              contentPadding: const EdgeInsets.all(14),
              filled: true,
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: _ActionButton(
              label: isEditing ? 'Update' : 'Upload',
              onTap: _handleUpload,
            ),
          ),
        ],
      ),
    );
  }
}

class _DummyUploadZone extends StatelessWidget {
  const _DummyUploadZone({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              icon,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Browse files',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                label == 'Update'
                    ? Icons.save_outlined
                    : Icons.cloud_upload_outlined,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
