import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import 'kyc_image_preview_dialog.dart';

class ReviewRequestDetailsSection extends StatelessWidget {
  const ReviewRequestDetailsSection({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
  });

  final PendingRequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaymentRequestSummaryCard(
          request: request,
          onAccept: onAccept,
          onReject: onReject,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 980;
            final personal = _PersonalAndRequestCard(request: request);
            final documents = _KycDocumentsColumn(request: request);

            if (stacked) {
              return Column(
                children: [
                  personal,
                  const SizedBox(height: 14),
                  documents,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: personal),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: documents),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _BankDetailsCard(request: request),
        const SizedBox(height: 14),
        _NomineeDetailsSection(nominees: request.nominees),
      ],
    );
  }
}

class _PaymentRequestSummaryCard extends StatelessWidget {
  const _PaymentRequestSummaryCard({
    required this.request,
    this.onAccept,
    this.onReject,
  });

  final PendingRequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final canAct = request.isAwaitingReview &&
        onAccept != null &&
        onReject != null;

    return _SectionCard(
      title: 'Payment request details',
      subtitle: request.requestId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              final tiles = [
                _PaymentMetricTile(
                  label: 'Investment amount',
                  value: CurrencyFormatter.format(request.amount),
                ),
                _PaymentMetricTile(
                  label: 'Paying now',
                  value: CurrencyFormatter.format(request.amountPayingNow),
                ),
                _PaymentMetricTile(
                  label: 'Pending',
                  value: CurrencyFormatter.format(request.pendingAmount),
                ),
              ];

              if (stacked) {
                return Column(
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      tiles[i],
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: tiles[i]),
                  ],
                ],
              );
            },
          ),
          if (canAct) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 420;
                final accept = SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
                final reject = SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );

                if (stacked) {
                  return Column(
                    children: [
                      accept,
                      const SizedBox(height: 10),
                      reject,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: accept),
                    const SizedBox(width: 12),
                    Expanded(child: reject),
                  ],
                );
              },
            ),
          ] else if (request.isClosed) ...[
            const SizedBox(height: 12),
            Text(
              request.isRejected
                  ? 'This request was rejected.'
                  : 'This request has been accepted.',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMetricTile extends StatelessWidget {
  const _PaymentMetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.35,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

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
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PersonalAndRequestCard extends StatelessWidget {
  const _PersonalAndRequestCard({required this.request});

  final PendingRequestModel request;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Personal information',
      subtitle: 'Applicant profile and contact details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    request.initials,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(request.applicantName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _text(request.organization),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.requestId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FieldGrid(
            fields: [
              _FieldData(label: 'Email', value: _text(request.email)),
              _FieldData(label: 'Phone', value: _text(request.phoneNumber)),
              _FieldData(
                label: 'Alternate phone',
                value: _text(request.alternatePhone),
              ),
              _FieldData(
                label: 'Date of birth',
                value: _formatDate(request.dateOfBirth),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FieldTile(
            label: 'Address',
            value: _text(request.address),
          ),
          const SizedBox(height: 16),
          _FieldGrid(
            fields: [
              _FieldData(label: 'Allocation', value: _text(request.allocation)),
              _FieldData(
                label: 'Submitted',
                value:
                    '${_formatDate(request.submittedAt)}  ·  ${_formatTime(request.submittedAt)}',
              ),
              _FieldData(label: 'Status', value: request.statusLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycDocumentsColumn extends StatelessWidget {
  const _KycDocumentsColumn({required this.request});

  final PendingRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DocumentCard(
          title: 'PAN card',
          numberLabel: 'PAN number',
          number: _text(request.panNumber),
          photoUrl: request.panPhotoUrl,
          photoLabel: 'PAN card photo',
        ),
        const SizedBox(height: 14),
        _DocumentCard(
          title: 'Aadhaar',
          numberLabel: 'Aadhaar number',
          number: _text(request.aadhaarNumber),
          photoUrl: request.aadhaarPhotoUrl,
          photoLabel: 'Aadhaar photo',
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.title,
    required this.numberLabel,
    required this.number,
    required this.photoLabel,
    this.photoUrl,
  });

  final String title;
  final String numberLabel;
  final String number;
  final String photoLabel;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldTile(label: numberLabel, value: number),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: _DocumentPhoto(
              label: photoLabel,
              photoUrl: photoUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPhoto extends StatelessWidget {
  const _DocumentPhoto({
    required this.label,
    this.photoUrl,
  });

  final String label;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showKycImagePreviewDialog(
        context: context,
        title: label,
        imageUrl: photoUrl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFF5F1F8),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _KycThumbnailContent(
            label: label,
            imageUrl: photoUrl,
            iconSize: 28,
          ),
        ),
      ),
    );
  }
}

class _BankDetailsCard extends StatelessWidget {
  const _BankDetailsCard({required this.request});

  final PendingRequestModel request;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Bank details',
      subtitle: 'Account information submitted with this request',
      child: _FieldGrid(
        fields: [
          _FieldData(label: 'Bank name', value: _text(request.bankName)),
          _FieldData(
            label: 'Account number',
            value: _text(request.accountNumber),
          ),
          _FieldData(label: 'IFSC code', value: _text(request.ifscCode)),
        ],
      ),
    );
  }
}

class _NomineeDetailsSection extends StatelessWidget {
  const _NomineeDetailsSection({required this.nominees});

  final List<PendingRequestNominee> nominees;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: nominees.isEmpty
          ? 'Nominee details'
          : 'Nominee details (${nominees.length})',
      subtitle: nominees.isEmpty
          ? 'No nominee details submitted with this request'
          : 'Nominees linked to this registration request',
      child: nominees.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                const spacing = 12.0;
                final cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (spacing * (columns - 1))) /
                        columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var i = 0; i < nominees.length; i++)
                      SizedBox(
                        width: cardWidth,
                        child: _NomineeCard(
                          index: i + 1,
                          nominee: nominees[i],
                          isPrimary: i == 0,
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _NomineeCard extends StatelessWidget {
  const _NomineeCard({
    required this.index,
    required this.nominee,
    required this.isPrimary,
  });

  final int index;
  final PendingRequestNominee nominee;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nominee ${index.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPrimary ? 'Primary' : 'Secondary',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FieldTile(label: 'Full name', value: _text(nominee.name)),
          const SizedBox(height: 8),
          _FieldTile(
            label: 'Relationship',
            value: _text(nominee.relationship),
          ),
          const SizedBox(height: 8),
          _FieldTile(label: 'Phone', value: _text(nominee.phoneNumber)),
          const SizedBox(height: 8),
          _FieldTile(label: 'Aadhaar', value: _text(nominee.aadhaarNumber)),
          const SizedBox(height: 8),
          _FieldTile(label: 'PAN', value: _text(nominee.panNumber)),
          const SizedBox(height: 12),
          Text(
            'KYC documents',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _KycThumbnail(
                  label: 'Aadhaar',
                  imageUrl: nominee.aadhaarPhotoUrl,
                  previewTitle: '${nominee.name} · Aadhaar',
                  previewSubtitle: _text(nominee.aadhaarNumber),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KycThumbnail(
                  label: 'PAN',
                  imageUrl: nominee.panPhotoUrl,
                  previewTitle: '${nominee.name} · PAN',
                  previewSubtitle: _text(nominee.panNumber),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycThumbnail extends StatelessWidget {
  const _KycThumbnail({
    required this.label,
    required this.previewTitle,
    this.previewSubtitle,
    this.imageUrl,
  });

  final String label;
  final String previewTitle;
  final String? previewSubtitle;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showKycImagePreviewDialog(
        context: context,
        title: previewTitle,
        subtitle: previewSubtitle,
        imageUrl: imageUrl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1F8),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _KycThumbnailContent(
                label: label,
                imageUrl: imageUrl,
                iconSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycThumbnailContent extends StatelessWidget {
  const _KycThumbnailContent({
    required this.label,
    this.imageUrl,
    required this.iconSize,
  });

  final String label;
  final String? imageUrl;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ImageConstants.documents,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.accent,
              BlendMode.srcIn,
            ),
          ),
          if (iconSize >= 24) ...[
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ImageConstants.imageError,
            width: iconSize,
            height: iconSize,
          ),
        ],
      ),
    );
  }
}

class _FieldData {
  const _FieldData({required this.label, required this.value});

  final String label;
  final String value;
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.fields});

  final List<_FieldData> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 420;
        if (!twoCol) {
          return Column(
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _FieldTile(label: fields[i].label, value: fields[i].value),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += 2) {
          final left = fields[i];
          final right = i + 1 < fields.length ? fields[i + 1] : null;
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < fields.length ? 10 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FieldTile(label: left.label, value: left.value),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: right == null
                        ? const SizedBox.shrink()
                        : _FieldTile(label: right.label, value: right.value),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

String _text(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? 'N/A' : text;
}

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
