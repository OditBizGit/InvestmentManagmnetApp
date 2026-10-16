import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

Future<void> showPaymentDetailsDialog({
  required BuildContext context,
  required ManagedUserModel user,
}) {
  return showDialog<void>(
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
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Payment details',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.name} · ${user.userId}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    UserManagementStatusBadge(
                      label: user.accountStatusLabel,
                      tone: user.isBlocked
                          ? UserManagementBadgeTone.danger
                          : UserManagementBadgeTone.success,
                    ),
                    UserManagementStatusBadge(
                      label: user.paymentStatusLabel,
                      tone: _paymentTone(user.paymentStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Email', value: user.email),
                _DetailRow(label: 'Phone', value: user.phoneNumber),
                _DetailRow(
                  label: 'Total payable',
                  value: CurrencyFormatter.format(user.totalPayable),
                ),
                _DetailRow(
                  label: 'Amount paid',
                  value: CurrencyFormatter.format(user.amountPaid),
                ),
                _DetailRow(
                  label: 'Outstanding balance',
                  value: CurrencyFormatter.format(user.outstandingBalance),
                ),
                _DetailRow(
                  label: 'Last payment',
                  value: _formatDate(user.lastPaymentDate),
                ),
                _DetailRow(
                  label: 'Next due date',
                  value: _formatDate(user.nextDueDate),
                ),
                const SizedBox(height: 14),
                Text(
                  'Payment history',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: user.payments.isEmpty
                      ? Center(
                          child: Text(
                            'No payments recorded yet',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: user.payments.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final payment = user.payments[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.screenBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.reference,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_formatDate(payment.date)} · ${payment.method}',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(payment.amount),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 36,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        elevation: 0,
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
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

UserManagementBadgeTone _paymentTone(UserPaymentStatus status) {
  switch (status) {
    case UserPaymentStatus.fullyPaid:
      return UserManagementBadgeTone.success;
    case UserPaymentStatus.partiallyPaid:
      return UserManagementBadgeTone.warning;
    case UserPaymentStatus.pending:
      return UserManagementBadgeTone.danger;
  }
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
