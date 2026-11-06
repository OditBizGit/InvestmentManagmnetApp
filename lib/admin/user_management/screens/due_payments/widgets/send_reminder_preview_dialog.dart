import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/model/payment_status_report_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

String buildWhatsAppReminderMessage(PaymentStatusReportModel item) {
  final invCode = item.investorCode.trim().isNotEmpty
      ? item.investorCode
      : '${item.userId}';

  return 'Hi ${item.name},\n\n'
      'This is a payment reminder from Maribel Wellness Centre.\n\n'
      'INVCode: $invCode\n'
      'Total payable: ${CurrencyFormatter.format(item.totalPayable)}\n'
      'Amount paid: ${CurrencyFormatter.format(item.amountPaid)}\n'
      'Due amount: ${CurrencyFormatter.format(item.dueAmount)}\n'
      'Due date: ${_formatDueDate(item.dueDate)}\n\n'
      'Please complete the pending payment at your earliest convenience.\n\n'
      'Thank you.\n'
      'Maribel Wellness Centre';
}
String _formatDueDate(DateTime? date) {
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
  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]}, ${date.year}';
}

String? normalizeWhatsAppPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return null;
  if (digits.length == 10) return '91$digits';
  return digits;
}

Future<bool> showSendReminderPreviewDialog({
  required BuildContext context,
  required PaymentStatusReportModel item,
}) async {
  final normalizedPhone = normalizeWhatsAppPhone(item.phoneNumber);
  final phoneLabel = item.phoneNumber.trim().isEmpty
      ? 'Phone not available'
      : item.phoneNumber;
  final canSend = normalizedPhone != null;
  final message = buildWhatsAppReminderMessage(item);

  final sent = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'WhatsApp reminder preview',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canSend
                      ? 'Review the message, then confirm to open WhatsApp with this text.'
                      : 'A valid phone number is required before WhatsApp can be opened.',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: canSend ? AppColors.textMuted : AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                _PreviewField(label: 'To', value: phoneLabel),
                const SizedBox(height: 10),
                _PreviewField(
                  label: 'Message',
                  value: message,
                  multiline: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 36,
                      width: 100,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: canSend
                            ? () => Navigator.of(dialogContext).pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textMuted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Text(
                          'Send WhatsApp',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return sent ?? false;
}

class _PreviewField extends StatelessWidget {
  const _PreviewField({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.screenBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: multiline ? 1.45 : 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
