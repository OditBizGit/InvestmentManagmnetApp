import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_data_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/utils/transaction_receipt_downloader.dart';
import 'package:sizer/sizer.dart';

class UserReceiptsCard extends StatefulWidget {
  const UserReceiptsCard({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  State<UserReceiptsCard> createState() => _UserReceiptsCardState();
}

class _UserReceiptsCardState extends State<UserReceiptsCard> {
  ScrollPosition? _scrollPosition;
  bool _hasTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollListener();
  }

  void _attachScrollListener() {
    final position = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = position;
      _scrollPosition?.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(covariant UserReceiptsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _hasTriggered = false;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_hasTriggered) return;
    final position = _scrollPosition;
    if (position == null || !position.hasContentDimensions) return;

    // Do not trigger on initial position before user scrolls
    if (position.pixels <= 0) return;

    final isNearBottom = position.pixels >= (position.maxScrollExtent - 120);

    bool isVisible = false;
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox &&
        renderObject.hasSize &&
        renderObject.attached) {
      final viewportHeight = MediaQuery.of(context).size.height;
      final localTop = renderObject.localToGlobal(Offset.zero).dy;
      if (localTop < viewportHeight && localTop > 0) {
        isVisible = true;
      }
    }

    if (isNearBottom || isVisible) {
      _triggerFetch();
    }
  }

  void _triggerFetch() {
    final uid = widget.userId?.trim();
    if (uid == null || uid.isEmpty) return;

    final cubit = context.read<ManageUsersCubit>();
    final state = cubit.state;

    if (state is InvestorTransactionHistoryLoading) return;
    if (state is InvestorTransactionHistorySuccess) {
      _hasTriggered = true;
      return;
    }

    if (_hasTriggered) return;
    _hasTriggered = true;

    cubit.fetchInvestorTransactionHistory(uid);
  }

  void _retry() {
    final uid = widget.userId?.trim();
    if (uid == null || uid.isEmpty) return;
    context.read<ManageUsersCubit>().fetchInvestorTransactionHistory(uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageUsersCubit, ManageUsersState>(
      builder: (context, state) {
        bool isLoading = false;
        String? errorMessage;
        List<InvestorTransactionItemModel>? models;
        InvestorTransactionHistoryDataModel? historyData;

        if (state is InvestorTransactionHistoryLoading) {
          isLoading = true;
        } else if (state is InvestorTransactionHistoryFailure) {
          errorMessage = state.message;
        } else if (state is InvestorTransactionHistorySuccess) {
          historyData = state.response.data;
          models = historyData?.transactions ?? const [];
        } else if (state is ManageUsersSuccess) {
          if (state.isTransactionHistoryLoading) {
            isLoading = true;
          } else if (state.transactionHistoryError != null) {
            errorMessage = state.transactionHistoryError;
          } else if (state.transactionHistoryResponse != null) {
            historyData = state.transactionHistoryResponse!.data;
            models = historyData?.transactions ?? const [];
          }
        }

        final receiptContext = _ReceiptDownloadContext.fromHistory(historyData);

        final receipts = models != null
            ? models.map(_ReceiptItem.fromModel).toList()
            : <_ReceiptItem>[];
        final hasLoaded = models != null;

        String badgeText;
        if (isLoading) {
          badgeText = 'Loading...';
        } else if (errorMessage != null) {
          badgeText = 'Error';
        } else if (hasLoaded) {
          badgeText = 'Total Receipts: ${receipts.length}';
        } else {
          badgeText = 'Total Receipts: —';
        }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipts',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All receipts given to this user',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildContent(
                isLoading: isLoading,
                errorMessage: errorMessage,
                hasLoaded: hasLoaded,
                receipts: receipts,
                downloadContext: receiptContext,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required bool isLoading,
    required String? errorMessage,
    required bool hasLoaded,
    required List<_ReceiptItem> receipts,
    required _ReceiptDownloadContext downloadContext,
  }) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading receipts...',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Failed to load transaction history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasLoaded && receipts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                'No receipts found',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No payment or refund records available for this investor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasLoaded) {
      // Idle state before user scrolls down to reveal the card
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'Scroll to view receipts',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        if (compact) {
          return Column(
            children: [
              for (var i = 0; i < receipts.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _ReceiptCompactTile(
                  index: i + 1,
                  receipt: receipts[i],
                  downloadContext: downloadContext,
                ),
              ],
            ],
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              const _ReceiptTableHeader(),
              for (var i = 0; i < receipts.length; i++)
                _ReceiptTableRow(
                  index: i + 1,
                  receipt: receipts[i],
                  showDivider: i < receipts.length - 1,
                  downloadContext: downloadContext,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReceiptDownloadContext {
  const _ReceiptDownloadContext({
    required this.projectName,
    this.investorAddress,
    this.projectSignaturePath,
  });

  final String projectName;
  final String? investorAddress;
  final String? projectSignaturePath;

  factory _ReceiptDownloadContext.fromHistory(
    InvestorTransactionHistoryDataModel? data,
  ) {
    if (data == null) return const _ReceiptDownloadContext(projectName: '');
    return _ReceiptDownloadContext(
      projectName: data.projectName,
      investorAddress: data.investorAddress,
      projectSignaturePath: data.projectSignaturePathUrl,
    );
  }
}

class _ReceiptItem {
  const _ReceiptItem({
    required this.receiptNo,
    required this.date,
    required this.amount,
    required this.purpose,
    required this.transaction,
  });

  final String receiptNo;
  final DateTime? date;
  final double amount;
  final String purpose;
  final InvestorTransactionItemModel transaction;

  factory _ReceiptItem.fromModel(InvestorTransactionItemModel model) {
    final entryNo = model.entryNo;
    final txId = model.transactionId;
    final receiptNo = entryNo > 0
        ? 'RCPT-${entryNo.toString().padLeft(6, '0')}'
        : (txId > 0
            ? 'RCPT-${txId.toString().padLeft(6, '0')}'
            : 'RCPT-000000');

    final amount = model.paidAmount > 0
        ? model.paidAmount
        : (model.receivedAmount > 0
            ? model.receivedAmount
            : model.investmentAmount);

    final purpose = model.narration.trim().isNotEmpty
        ? model.narration.trim()
        : (model.paymentMethod.trim().isNotEmpty
            ? model.paymentMethod.trim()
            : (model.status.trim().isNotEmpty
                ? model.status.trim()
                : 'Investment'));

    return _ReceiptItem(
      receiptNo: receiptNo,
      date: model.date,
      amount: amount,
      purpose: purpose,
      transaction: model,
    );
  }
}

class _ReceiptTableHeader extends StatelessWidget {
  const _ReceiptTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text('#', style: _headerStyle),
          ),
          Expanded(
            flex: 3,
            child: Text('Receipt No.', style: _headerStyle),
          ),
          Expanded(
            flex: 3,
            child: Text('Receipt Date', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('Amount', style: _headerStyle),
          ),
          Expanded(
            flex: 4,
            child: Text('Purpose / Remarks', style: _headerStyle),
          ),
          SizedBox(
            width: 118,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: _headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  static final _headerStyle = TextStyle(
    fontSize: 9.5.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}

class _ReceiptTableRow extends StatelessWidget {
  const _ReceiptTableRow({
    required this.index,
    required this.receipt,
    required this.showDivider,
    required this.downloadContext,
  });

  final int index;
  final _ReceiptItem receipt;
  final bool showDivider;
  final _ReceiptDownloadContext downloadContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _IndexBadge(index: index),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              receipt.receiptNo,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.accentDark,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _DateLabel(date: receipt.date),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(receipt.amount),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              receipt.purpose,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 118,
            child: Align(
              alignment: Alignment.centerRight,
              child: _DownloadButton(
                receipt: receipt,
                downloadContext: downloadContext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCompactTile extends StatelessWidget {
  const _ReceiptCompactTile({
    required this.index,
    required this.receipt,
    required this.downloadContext,
  });

  final int index;
  final _ReceiptItem receipt;
  final _ReceiptDownloadContext downloadContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IndexBadge(index: index),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  receipt.receiptNo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(receipt.amount),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DateLabel(date: receipt.date),
          const SizedBox(height: 6),
          Text(
            receipt.purpose,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _DownloadButton(
              receipt: receipt,
              downloadContext: downloadContext,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 13.sp,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            date != null ? _formatReceiptDate(date!) : '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton({
    required this.receipt,
    required this.downloadContext,
  });

  final _ReceiptItem receipt;
  final _ReceiptDownloadContext downloadContext;

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _isDownloading = false;

  Future<void> _onDownload() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    try {
      await TransactionReceiptDownloader.download(
        context: context,
        transaction: widget.receipt.transaction,
        projectName: widget.downloadContext.projectName,
        investorAddress: widget.downloadContext.investorAddress,
        projectSignaturePath: widget.downloadContext.projectSignaturePath,
      );
      if (!mounted) return;
      AppToast.success(
        'Receipt ${widget.receipt.receiptNo} downloaded',
        title: 'Receipt',
        context: context,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.error(
        'Could not download receipt. Please try again.',
        title: 'Download failed',
        context: context,
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isDownloading ? null : _onDownload,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentDark,
        side: const BorderSide(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: _isDownloading
          ? SizedBox(
              width: 15.sp,
              height: 15.sp,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
          : Icon(Icons.download_rounded, size: 15.sp),
      label: Text(
        _isDownloading ? 'Saving…' : 'Download',
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatReceiptDate(DateTime value) {
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

  return '${value.day.toString().padLeft(2, '0')} '
      '${months[value.month - 1]} ${value.year}';
}
