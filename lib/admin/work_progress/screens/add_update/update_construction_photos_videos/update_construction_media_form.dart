import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/cubit/update_construction_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/add_update_option_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

enum _MediaKind { photo, video }

class _PickedMedia {
  const _PickedMedia({
    this.bytes,
    this.path,
    required this.name,
    required this.extension,
    required this.kind,
    required this.sizeInBytes,
  });

  final Uint8List? bytes;
  final String? path;
  final String name;
  final String extension;
  final _MediaKind kind;
  final int sizeInBytes;

  bool get hasUploadSource =>
      (path != null && path!.isNotEmpty) ||
      (bytes != null && bytes!.isNotEmpty);
}

class UpdateConstructionMediaForm extends StatefulWidget {
  const UpdateConstructionMediaForm({
    super.key,
    this.initial,
    required this.onSave,
  });

  final MediaUpdate? initial;
  final ValueChanged<MediaUpdate> onSave;

  @override
  State<UpdateConstructionMediaForm> createState() =>
      _UpdateConstructionMediaFormState();
}

class _UpdateConstructionMediaFormState
    extends State<UpdateConstructionMediaForm> {
  static const int _maxPhotoBytes = 10 * 1024 * 1024;
  static const int _maxVideoBytes = 50 * 1024 * 1024;
  static const List<String> _photoExtensions = ['png', 'jpg', 'jpeg'];
  static const List<String> _videoExtensions = ['mp4', 'mov'];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  _PickedMedia? _selectedMedia;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _descriptionController.text = widget.initial!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickMedia(_MediaKind kind) async {
    if (_picking) return;

    // Only one file allowed — block switching type while one is selected.
    final existing = _selectedMedia;
    if (existing != null && existing.kind != kind) {
      AppToast.error(
        'Only one file can be selected. Remove the current file first.',
        context: context,
      );
      return;
    }

    setState(() => _picking = true);

    try {
      final allowed =
          kind == _MediaKind.photo ? _photoExtensions : _videoExtensions;
      final maxBytes =
          kind == _MediaKind.photo ? _maxPhotoBytes : _maxVideoBytes;
      final maxLabel = kind == _MediaKind.photo ? '10 MB' : '50 MB';
      final typeLabel = kind == _MediaKind.photo
          ? 'PNG or JPG image'
          : 'MP4 or MOV video';

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
        allowMultiple: false,
        withData: kIsWeb || kind == _MediaKind.photo,
        allowCompression: false,
        compressionQuality: 0,
      );

      // User cancelled the picker — no toast needed.
      if (result == null || result.files.isEmpty) return;
      if (!mounted) return;

      final file = result.files.single;
      final extension = (file.extension ??
              (file.name.contains('.')
                  ? file.name.split('.').last
                  : null))
          ?.toLowerCase();

      if (extension == null || !allowed.contains(extension)) {
        AppToast.error(
          'Unsupported file type. Please select a $typeLabel.',
          context: context,
        );
        return;
      }

      // On web, PlatformFile.path throws. Never read it in the browser.
      final path = kIsWeb ? null : file.path;
      var bytes = file.bytes;

      if ((bytes == null || bytes.isEmpty) &&
          !kIsWeb &&
          path != null &&
          path.isNotEmpty &&
          kind == _MediaKind.photo) {
        bytes = await _readFileBytes(path);
      }

      final sizeInBytes = file.size > 0
          ? file.size
          : (bytes?.lengthInBytes ?? 0);

      if (sizeInBytes <= 0 &&
          (bytes == null || bytes.isEmpty) &&
          (path == null || path.isEmpty)) {
        AppToast.error(
          'Could not read "${file.name}". Please try again.',
          context: context,
        );
        return;
      }

      if (sizeInBytes > maxBytes) {
        AppToast.error(
          '"${file.name}" must be $maxLabel or smaller.',
          context: context,
        );
        return;
      }

      if (kind == _MediaKind.photo && (bytes == null || bytes.isEmpty)) {
        AppToast.error(
          'Could not read "${file.name}". Please try again.',
          context: context,
        );
        return;
      }

      if (kind == _MediaKind.video &&
          (path == null || path.isEmpty) &&
          (bytes == null || bytes.isEmpty)) {
        AppToast.error(
          'Could not read "${file.name}". Please try again.',
          context: context,
        );
        return;
      }

      setState(() {
        _selectedMedia = _PickedMedia(
          bytes: bytes,
          path: path,
          name: file.name,
          extension: extension,
          kind: kind,
          sizeInBytes: sizeInBytes,
        );
      });
    } catch (error, stackTrace) {
      log('Construction media file pick failed: $error', stackTrace: stackTrace);
      if (!mounted) return;
      AppToast.error(
        'Could not complete the file selection. Please try again.',
        context: context,
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<Uint8List?> _readFileBytes(String path) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await File(path).readAsBytes();
      } catch (error) {
        lastError = error;
        await Future<void>.delayed(
          Duration(milliseconds: 150 * (attempt + 1)),
        );
      }
    }
    log('Could not read picked file at $path: $lastError');
    return null;
  }

  void _clearSelectedMedia() {
    setState(() => _selectedMedia = null);
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedMedia = null;
  }

  Future<MultipartFile> _toMultipartFile(_PickedMedia media) async {
    final extension = media.extension.toLowerCase();
    final DioMediaType contentType;

    if (media.kind == _MediaKind.photo) {
      final subtype = extension == 'jpg' ? 'jpeg' : extension;
      contentType = DioMediaType('image', subtype);
    } else {
      contentType = extension == 'mov'
          ? DioMediaType('video', 'quicktime')
          : DioMediaType('video', 'mp4');
    }

    final path = media.path;
    if (path != null && path.isNotEmpty && !kIsWeb) {
      return MultipartFile.fromFile(
        path,
        filename: media.name,
        contentType: contentType,
      );
    }

    final bytes = media.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return MultipartFile.fromBytes(
        bytes,
        filename: media.name,
        contentType: contentType,
      );
    }

    throw StateError('Selected media has no readable file data');
  }

  Future<void> _handleUpload() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final media = _selectedMedia;

    if (title.isEmpty) {
      AppToast.error('Please enter a title.', context: context);
      return;
    }

    if (description.isEmpty) {
      AppToast.error('Please enter a description.', context: context);
      return;
    }

    if (media == null || !media.hasUploadSource) {
      AppToast.error(
        'Please select a photo or video to upload.',
        context: context,
      );
      return;
    }

    try {
      final file = await _toMultipartFile(media);
      if (!mounted) return;

      context.read<UpdateConstructionCubit>().addWorkUpdate(
        title: title,
        description: description,
        file: file,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.error(
        'Could not prepare the selected file for upload. Please try again.',
        context: context,
      );
    }
  }

  void _onUploadSuccess(String message) {
    final existing = widget.initial;
    final description = _descriptionController.text.trim();

    widget.onSave(
      MediaUpdate(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: AddUpdateOptionType.constructionMedia,
        description: description,
        updatedAt: DateTime.now(),
      ),
    );

    setState(_resetForm);
    AppToast.success(
      message.isNotEmpty ? message : 'Construction media uploaded successfully',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return BlocConsumer<UpdateConstructionCubit, UpdateConstructionState>(
      listenWhen: (previous, current) =>
          current is UpdateConstructionSuccess ||
          current is UpdateConstructionError,
      listener: (context, state) {
        if (state is UpdateConstructionSuccess) {
          _onUploadSuccess(state.response.message);
        } else if (state is UpdateConstructionError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is UpdateConstructionLoading ||
          current is UpdateConstructionSuccess ||
          current is UpdateConstructionError ||
          current is UpdateConstructionInitial,
      builder: (context, state) {
        final isUploading = state is UpdateConstructionLoading;
        final canInteract = !isUploading && !_picking;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 560;

                final photoZone = _UploadZone(
                  title: 'Upload Photos',
                  subtitle: 'PNG, JPG up to 10MB',
                  icon: ImageConstants.uploadPhoto,
                  iconColor: const Color(0xFF9B7EBF),
                  iconBg: const Color(0xFFF0EBF6),
                  picking: _picking,
                  enabled: canInteract,
                  selectedMedia: _selectedMedia?.kind == _MediaKind.photo
                      ? _selectedMedia
                      : null,
                  fileSizeLabel: _selectedMedia?.kind == _MediaKind.photo
                      ? _formatFileSize(_selectedMedia!.sizeInBytes)
                      : null,
                  onTap: () => _pickMedia(_MediaKind.photo),
                  onClear: _selectedMedia?.kind == _MediaKind.photo
                      ? _clearSelectedMedia
                      : null,
                );
                final videoZone = _UploadZone(
                  title: 'Upload Videos',
                  subtitle: 'MP4, MOV up to 50MB',
                  icon: ImageConstants.uploadVideo,
                  iconColor: const Color(0xFFE89A3C),
                  iconBg: const Color(0xFFFFF3E8),
                  picking: _picking,
                  enabled: canInteract,
                  selectedMedia: _selectedMedia?.kind == _MediaKind.video
                      ? _selectedMedia
                      : null,
                  fileSizeLabel: _selectedMedia?.kind == _MediaKind.video
                      ? _formatFileSize(_selectedMedia!.sizeInBytes)
                      : null,
                  onTap: () => _pickMedia(_MediaKind.video),
                  onClear: _selectedMedia?.kind == _MediaKind.video
                      ? _clearSelectedMedia
                      : null,
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
              'Title',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: canInteract,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter a short title for this update',
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
                disabledBorder: OutlineInputBorder(
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
              enabled: canInteract,
              maxLines: 4,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Describe the construction update or site progress',
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
                disabledBorder: OutlineInputBorder(
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
                loading: isUploading,
                onTap: canInteract ? _handleUpload : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.picking,
    required this.enabled,
    required this.onTap,
    this.selectedMedia,
    this.fileSizeLabel,
    this.onClear,
  });

  static const double cardHeight = 168;

  final String title;
  final String subtitle;
  final String icon;
  final Color iconColor;
  final Color iconBg;
  final bool picking;
  final bool enabled;
  final VoidCallback onTap;
  final _PickedMedia? selectedMedia;
  final String? fileSizeLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final busy = picking || !enabled;
    final hasSelection = selectedMedia != null;

    return Material(
      color: AppColors.screenBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: busy || hasSelection ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSelection ? AppColors.accent : AppColors.border,
              width: hasSelection ? 1.4 : 1,
            ),
          ),
          child: hasSelection
              ? _ZoneSelectedPreview(
                  media: selectedMedia!,
                  fileSizeLabel: fileSizeLabel ?? '',
                  iconColor: iconColor,
                  iconBg: iconBg,
                  icon: icon,
                  enabled: enabled,
                  onClear: onClear,
                  onChange: onTap,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: picking
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: iconColor,
                              ),
                            )
                          : SvgPicture.asset(
                              icon,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      picking ? 'Opening picker…' : title,
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
                    const SizedBox(height: 8),
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

class _ZoneSelectedPreview extends StatelessWidget {
  const _ZoneSelectedPreview({
    required this.media,
    required this.fileSizeLabel,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
    required this.enabled,
    required this.onChange,
    this.onClear,
  });

  final _PickedMedia media;
  final String fileSizeLabel;
  final Color iconColor;
  final Color iconBg;
  final String icon;
  final bool enabled;
  final VoidCallback onChange;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: media.kind == _MediaKind.photo && media.bytes != null
                    ? Image.memory(
                        media.bytes!,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: iconBg,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              icon,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppColors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileSizeLabel,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onChange,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

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
                Icon(
                  label == 'Update'
                      ? Icons.save_outlined
                      : Icons.cloud_upload_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                loading ? 'Uploading…' : label,
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
