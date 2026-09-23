import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

class CreateProjectFormCard extends StatelessWidget {
  const CreateProjectFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.totalFundController,
    required this.projectImage,
    required this.onPickImage,
    required this.onClearImage,
    this.existingImageUrl,
    this.isEditing = false,
    this.hasExistingProject = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController totalFundController;
  final PickedPhoto? projectImage;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final String? existingImageUrl;
  final bool isEditing;
  final bool hasExistingProject;

  @override
  Widget build(BuildContext context) {
    final subtitle = isEditing
        ? 'Edit the selected project details and save your changes.'
        : hasExistingProject
            ? 'A project is already live. You can only update the existing project.'
            : 'Enter the project name, description, funding goal, and image.';

    return Form(
      key: formKey,
      child: AddInvestorSectionCard(
        title: isEditing ? 'Update Project' : 'Project Details',
        subtitle: subtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasExistingProject && !isEditing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFFB8C00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only one live project is allowed. Open View and select the project to update it.',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFB8C00),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            AddInvestorLabeledField(
              label: 'Project Image',
              isRequired: !isEditing,
              child: _ProjectImagePicker(
                photo: projectImage,
                existingImageUrl: existingImageUrl,
                onPick: onPickImage,
                onClear: onClearImage,
              ),
            ),
            const SizedBox(height: 18),
            AddInvestorLabeledField(
              label: 'Name',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: nameController,
                hint: 'Enter project name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            AddInvestorLabeledField(
              label: 'Description',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: descriptionController,
                hint: 'Enter project description',
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            AddInvestorLabeledField(
              label: 'Total Fund',
              isRequired: true,
              child: AddInvestorTextInput(
                controller: totalFundController,
                hint: 'Enter total fund amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  final raw = value?.trim().replaceAll(',', '') ?? '';
                  if (raw.isEmpty) return 'Total fund is required';
                  final amount = double.tryParse(raw);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid fund amount';
                  }
                  return null;
                },
              ),
            ),
            if (projectImage == null &&
                (existingImageUrl == null || existingImageUrl!.isEmpty)) ...[
              const SizedBox(height: 10),
              Text(
                'Tip: JPEG or PNG up to 2 MB works best for project thumbnails.',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectImagePicker extends StatelessWidget {
  const _ProjectImagePicker({
    required this.photo,
    required this.onPick,
    required this.onClear,
    this.existingImageUrl,
  });

  final PickedPhoto? photo;
  final String? existingImageUrl;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasPicked = photo != null;
    final hasExisting =
        existingImageUrl != null && existingImageUrl!.trim().isNotEmpty;
    final hasImage = hasPicked || hasExisting;

    DecorationImage? image;
    if (hasPicked) {
      image = DecorationImage(
        image: MemoryImage(photo!.bytes),
        fit: BoxFit.cover,
      );
    } else if (hasExisting) {
      image = DecorationImage(
        image: NetworkImage(existingImageUrl!),
        fit: BoxFit.cover,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 10.h,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1F5),
                    borderRadius: BorderRadius.circular(24),
                    image: image,
                  ),
                  alignment: Alignment.center,
                  child: hasImage
                      ? null
                      : SvgPicture.asset(
                          ImageConstants.camera,
                          width: 4.h,
                          height: 4.h,
                        ),
                ),
                if (hasPicked)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Material(
                      color: AppColors.white,
                      shape: const CircleBorder(),
                      elevation: 1,
                      child: InkWell(
                        onTap: onClear,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasImage
                        ? 'Change Project Image'
                        : 'Upload Project Image',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasPicked
                        ? photo!.name
                        : hasExisting
                            ? 'Current project image'
                            : 'JPEG, PNG (Max 2MB)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
