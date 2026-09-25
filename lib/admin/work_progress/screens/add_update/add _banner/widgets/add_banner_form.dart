import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

import '../cubit/add_banner_cubit.dart';
import 'banner_common_widgets.dart';

class AddBannerForm extends StatefulWidget {
  const AddBannerForm({
    super.key,
    this.onUploadSuccess,
  });

  final VoidCallback? onUploadSuccess;

  @override
  State<AddBannerForm> createState() => _AddBannerFormState();
}

class _AddBannerFormState extends State<AddBannerForm> {
  static const int _maxBytes = 5 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  final List<PickedPhoto> _selectedBanners = [];
  bool _picking = false;

  Future<void> _pickBanners() async {
    if (_picking) return;
    setState(() => _picking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final added = <PickedPhoto>[];
      for (final file in result.files) {
        final extension = file.extension?.toLowerCase();
        if (extension == null || !_allowedExtensions.contains(extension)) {
          AppToast.error('Please select JPEG, PNG, or WEBP images.');
          continue;
        }

        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          AppToast.error('Could not read "${file.name}". Please try again.');
          continue;
        }

        if (bytes.lengthInBytes > _maxBytes) {
          AppToast.error('"${file.name}" must be 5 MB or smaller.');
          continue;
        }

        added.add(
          PickedPhoto(
            bytes: bytes,
            name: file.name,
            extension: extension,
          ),
        );
      }

      if (added.isEmpty || !mounted) return;

      setState(() => _selectedBanners.addAll(added));
      AppToast.success(
        added.length == 1
            ? 'Banner image selected'
            : '${added.length} banner images selected',
        context: context,
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _removeSelectedBanner(int index) {
    setState(() => _selectedBanners.removeAt(index));
    AppToast.success('Banner removed', context: context);
  }

  void _viewLocalBanner(PickedPhoto photo) {
    showBannerPreviewDialog(
      context: context,
      image: Image.memory(photo.bytes, fit: BoxFit.contain),
    );
  }

  void _uploadBanners() {
    if (_selectedBanners.isEmpty) {
      AppToast.error(
        'Please select at least one banner image.',
        context: context,
      );
      return;
    }

    final images = _selectedBanners.map((photo) {
      final extension = (photo.extension ?? 'jpg').toLowerCase();
      final mimeSubtype = extension == 'jpg' ? 'jpeg' : extension;
      return MultipartFile.fromBytes(
        photo.bytes,
        filename: photo.name,
        contentType: DioMediaType('image', mimeSubtype),
      );
    }).toList();

    log(
      'AddBannerForm: uploading ${images.length} file(s) '
      '→ ${_selectedBanners.map((e) => '${e.name} (${e.sizeInBytes} bytes)').join(', ')}',
    );

    context.read<AddBannerCubit>().addBanners(images: images);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddBannerCubit, AddBannerState>(
      listenWhen: (previous, current) =>
          current is AddBannerSuccess || current is AddBannerFailure,
      listener: (context, state) {
        if (state is AddBannerSuccess) {
          AppToast.success(state.message, context: context);
          setState(_selectedBanners.clear);
          widget.onUploadSuccess?.call();
        } else if (state is AddBannerFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is AddBannerLoading ||
          current is AddBannerSuccess ||
          current is AddBannerFailure ||
          current is AddBannerInitial,
      builder: (context, state) {
        final isUploading = state is AddBannerLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BannerUploadZone(
              picking: _picking,
              enabled: !isUploading,
              onTap: _pickBanners,
            ),
            if (_selectedBanners.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Selected Banners',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  BannerCountChip(count: _selectedBanners.length),
                ],
              ),
              const SizedBox(height: 12),
              BannerGrid(
                itemCount: _selectedBanners.length,
                itemBuilder: (context, index, itemWidth) {
                  return SizedBox(
                    width: itemWidth,
                    child: _LocalBannerPreviewCard(
                      photo: _selectedBanners[index],
                      enabled: !isUploading,
                      onView: () => _viewLocalBanner(_selectedBanners[index]),
                      onDelete: () => _removeSelectedBanner(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: _UploadButton(
                  loading: isUploading,
                  onTap: _uploadBanners,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerUploadZone extends StatelessWidget {
  const _BannerUploadZone({
    required this.picking,
    required this.enabled,
    required this.onTap,
  });

  final bool picking;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final busy = picking || !enabled;

    return Material(
      color: AppColors.screenBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: picking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE89A3C),
                        ),
                      )
                    : SvgPicture.asset(
                        ImageConstants.uploadPhoto,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFE89A3C),
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                picking ? 'Opening picker…' : 'Upload Banner Images',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PNG, JPG, WEBP up to 5MB · multiple files allowed',
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
        ),
      ),
    );
  }
}

class _LocalBannerPreviewCard extends StatelessWidget {
  const _LocalBannerPreviewCard({
    required this.photo,
    required this.enabled,
    required this.onView,
    required this.onDelete,
  });

  final PickedPhoto photo;
  final bool enabled;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  photo.bytes,
                  fit: BoxFit.cover,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: enabled ? onView : null),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      onTap: enabled ? onDelete : null,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: AppColors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: enabled ? onView : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Text(
              photo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.loading,
    required this.onTap,
  });

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              else
                const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                loading ? 'Uploading…' : 'Upload',
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
