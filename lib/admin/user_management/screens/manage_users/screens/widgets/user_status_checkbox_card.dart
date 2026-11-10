import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/url_scheme_guard.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

typedef DocumentUploadCallback = Future<void> Function(
  Uint8List bytes,
  String fileName,
);

class UserStatusCheckboxCard extends StatefulWidget {
  const UserStatusCheckboxCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.documentLabel,
    required this.selected,
    required this.onChanged,
    this.issuedAt,
    this.completedAt,
    this.isLoading = false,
    this.documentPath,
    this.documentUpdatedAt,
    this.onUploadDocument,
    this.onRemoveDocument,
  });

  final String title;
  final String subtitle;
  final String documentLabel;
  final DocumentProcessStatus selected;
  final ValueChanged<DocumentProcessStatus> onChanged;
  final DateTime? issuedAt;
  final DateTime? completedAt;
  final bool isLoading;
  final String? documentPath;
  final DateTime? documentUpdatedAt;
  final DocumentUploadCallback? onUploadDocument;
  final VoidCallback? onRemoveDocument;

  @override
  State<UserStatusCheckboxCard> createState() =>
      _UserStatusCheckboxCardState();
}

class _UserStatusCheckboxCardState extends State<UserStatusCheckboxCard> {
  static const _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  /// Local pick kept until server path is available / removed.
  _LocalDocumentFile? _localFile;

  bool get _hasServerDocument {
    final path = widget.documentPath?.trim();
    return path != null && path.isNotEmpty;
  }

  bool get _hasPendingLocal => _localFile != null;

  bool get _hasDocument => _hasServerDocument || _hasPendingLocal;

  /// Pending pick awaiting explicit upload (not yet on server).
  bool get _isPendingUpload => _hasPendingLocal && !_hasServerDocument;

  @override
  void didUpdateWidget(covariant UserStatusCheckboxCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPath = widget.documentPath?.trim();
    final oldPath = oldWidget.documentPath?.trim();
    if (newPath != null &&
        newPath.isNotEmpty &&
        newPath != oldPath &&
        _localFile != null) {
      setState(() => _localFile = null);
    }

    if ((newPath == null || newPath.isEmpty) &&
        oldPath != null &&
        oldPath.isNotEmpty &&
        _localFile != null) {
      // Parent cleared server doc; keep local only if still uploading.
    }
  }

  bool _canSelect(DocumentProcessStatus status) {
    if (widget.selected == DocumentProcessStatus.completed) {
      return status == DocumentProcessStatus.completed;
    }
    if (status == DocumentProcessStatus.pending &&
        widget.selected == DocumentProcessStatus.issued) {
      return false;
    }
    return true;
  }

  String? _timestampLabel(DocumentProcessStatus status) {
    switch (status) {
      case DocumentProcessStatus.issued:
        final formatted = _formatDateTime(widget.issuedAt);
        return formatted == null ? null : 'Issued on: $formatted';
      case DocumentProcessStatus.completed:
        final formatted = _formatDateTime(widget.completedAt);
        return formatted == null ? null : 'Completed on: $formatted';
      case DocumentProcessStatus.pending:
        return null;
    }
  }

  Future<void> _handleStatusTap(DocumentProcessStatus status) async {
    if (widget.isLoading || widget.selected == status) return;

    if (!_canSelect(status)) {
      final message = widget.selected == DocumentProcessStatus.completed
          ? 'Once marked as Completed, status cannot be changed.'
          : 'Once marked as Issued, status cannot be set back to Pending.';
      AppToast.error(
        message,
        title: '${widget.documentLabel} Status Locked',
        context: context,
      );
      return;
    }

    if (status == DocumentProcessStatus.completed) {
      final confirmed = await showUserManagementConfirmDialog(
        context: context,
        title: 'Mark ${widget.documentLabel} as Completed?',
        message:
            'Are you sure you want to mark this ${widget.documentLabel} status as Completed? This action confirms the process is finished.',
        confirmLabel: 'Confirm',
        confirmColor: AppColors.accent,
      );
      if (!confirmed) return;
    }

    widget.onChanged(status);
  }

  Future<void> _pickFile() async {
    if (widget.isLoading) return;

    if (_hasDocument) {
      AppToast.error(
        _hasServerDocument
            ? 'Only one file can be selected. A document is already uploaded.'
            : 'Only one file can be selected. Remove the selected file to choose another.',
        title: '${widget.documentLabel} Document',
        context: context,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final name = file.name.trim();
    if (name.isEmpty) {
      AppToast.error('Could not read the selected file.', context: context);
      return;
    }

    final extension = file.extension?.toLowerCase();
    if (extension == null || !_allowedExtensions.contains(extension)) {
      AppToast.error(
        'Please select a PDF, DOC, DOCX, JPG, or PNG file.',
        context: context,
      );
      return;
    }

    final path = file.path?.trim();
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      AppToast.error('Could not read the selected file.', context: context);
      return;
    }

    setState(() {
      _localFile = _LocalDocumentFile(
        name: name,
        path: path,
        bytes: bytes,
        extension: extension,
        uploadedAt: DateTime.now(),
      );
    });
  }

  Future<void> _uploadSelectedFile() async {
    if (widget.isLoading) return;

    final local = _localFile;
    if (local == null) return;

    final upload = widget.onUploadDocument;
    if (upload == null) return;

    await upload(local.bytes, local.name);
  }

  Future<void> _viewFile() async {
    final local = _localFile;
    if (local != null) {
      final path = local.path;
      if (path != null && path.isNotEmpty) {
        final result = await OpenFilex.open(path);
        if (!mounted) return;
        if (result.type != ResultType.done) {
          AppToast.error(
            result.message.isEmpty
                ? 'Unable to open this file.'
                : result.message,
            title: '${widget.documentLabel} Document',
            context: context,
          );
        }
        return;
      }

      if (_isImageExtension(local.extension)) {
        await _showImagePreview(local.name, local.bytes);
        return;
      }
    }

    final remoteUrl = resolveMediaUrl(widget.documentPath);
    if (remoteUrl == null || remoteUrl.isEmpty) {
      if (!mounted) return;
      AppToast.error(
        'Unable to open this file for viewing.',
        title: '${widget.documentLabel} Document',
        context: context,
      );
      return;
    }

    final uri = Uri.tryParse(remoteUrl);
    if (uri == null || !isHttpOrHttpsUrl(uri)) {
      if (!mounted) return;
      AppToast.error(
        'Invalid document URL.',
        title: '${widget.documentLabel} Document',
        context: context,
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (!launched) {
      AppToast.error(
        'Unable to open this file for viewing.',
        title: '${widget.documentLabel} Document',
        context: context,
      );
    }
  }

  Future<void> _showImagePreview(String name, Uint8List bytes) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearPendingFile() {
    if (widget.isLoading || !_isPendingUpload) return;

    setState(() => _localFile = null);
    AppToast.success(
      'Selected file removed. You can choose another file now.',
      title: '${widget.documentLabel} Document',
      context: context,
    );
  }

  bool _isImageExtension(String? extension) {
    final value = extension?.toLowerCase();
    return value == 'jpg' || value == 'jpeg' || value == 'png';
  }

  String get _displayFileName {
    final local = _localFile;
    if (local != null) return local.name;

    final path = widget.documentPath?.trim() ?? '';
    if (path.isEmpty) return 'Document';
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final name = parts.isEmpty ? path : parts.last;
    return name.trim().isEmpty ? 'Document' : name.trim();
  }

  DateTime? get _displayUploadedAt =>
      _localFile?.uploadedAt ?? widget.documentUpdatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _UploadIconButton(
                enabled: !widget.isLoading,
                onTap: _pickFile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.isLoading) ...[
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.accent,
              backgroundColor: AppColors.border,
            ),
            const SizedBox(height: 10),
          ],
          for (final status in DocumentProcessStatus.values) ...[
            _StatusCheckboxTile(
              label: status.label,
              checked: widget.selected == status,
              updatedAt: _timestampLabel(status),
              enabled: !widget.isLoading,
              locked: !_canSelect(status),
              onTap: () => _handleStatusTap(status),
            ),
            if (status != DocumentProcessStatus.values.last)
              const SizedBox(height: 8),
          ],
          if (_hasDocument) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            Text(
              _isPendingUpload
                  ? 'Selected Document (1)'
                  : 'Uploaded Documents (1)',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _UploadedDocumentRow(
              fileName: _displayFileName,
              uploadedAtLabel: _isPendingUpload
                  ? 'Selected on ${_formatDateTime(_displayUploadedAt) ?? '—'}'
                  : 'Uploaded on ${_formatDateTime(_displayUploadedAt) ?? '—'}',
              onView: _viewFile,
              onUpload: _isPendingUpload ? _uploadSelectedFile : null,
              onRemove: _isPendingUpload ? _clearPendingFile : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _LocalDocumentFile {
  const _LocalDocumentFile({
    required this.name,
    required this.bytes,
    required this.uploadedAt,
    this.path,
    this.extension,
  });

  final String name;
  final String? path;
  final Uint8List bytes;
  final String? extension;
  final DateTime uploadedAt;
}

class _UploadIconButton extends StatelessWidget {
  const _UploadIconButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.add,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadedDocumentRow extends StatelessWidget {
  const _UploadedDocumentRow({
    required this.fileName,
    required this.uploadedAtLabel,
    required this.onView,
    this.onUpload,
    this.onRemove,
  });

  final String fileName;
  final String uploadedAtLabel;
  final VoidCallback onView;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  uploadedAtLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onView,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.accentDark,
                  size: 18,
                ),
              ),
            ),
          ),
          if (onUpload != null) ...[
            const SizedBox(width: 8),
            Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onUpload,
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCheckboxTile extends StatelessWidget {
  const _StatusCheckboxTile({
    required this.label,
    required this.checked,
    required this.onTap,
    required this.enabled,
    this.locked = false,
    this.updatedAt,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final bool enabled;
  final bool locked;
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled;
    final labelColor =
        locked && !checked ? AppColors.hint : AppColors.textPrimary;

    return Material(
      color: checked ? AppColors.cardBg : AppColors.screenBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: interactive ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: locked && !checked ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: checked,
                    onChanged: interactive ? (_) => onTap() : null,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.accent;
                      }
                      return AppColors.white;
                    }),
                    checkColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(color: AppColors.border, width: 1.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                ),
                if (updatedAt != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      updatedAt!,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _formatDateTime(DateTime? value) {
  if (value == null) return null;

  final local = value.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour:$minute $period';
}
