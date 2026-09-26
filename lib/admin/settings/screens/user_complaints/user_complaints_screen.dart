import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/cubit/user_complaints_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/model/complaint_ui_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/repository/user_complaints_respository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/widgets/complaint_card.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/widgets/complaints_date_filter.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class UserComplaintsScreen extends StatelessWidget {
  const UserComplaintsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserComplaintsCubit(
        userComplaintsRepository: UserComplaintsRepository(
          dio: getIt<Dio>(),
        ),
      ),
      child: _UserComplaintsView(onBack: onBack),
    );
  }
}

class _UserComplaintsView extends StatefulWidget {
  const _UserComplaintsView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_UserComplaintsView> createState() => _UserComplaintsViewState();
}

class _UserComplaintsViewState extends State<_UserComplaintsView> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(const Duration(days: 30));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchComplaints();
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  String _formatDate(DateTime date) {
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

  String _apiDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _fetchComplaints() {
    context.read<UserComplaintsCubit>().fetchUserComplaints(
          fromDate: _apiDate(_fromDate),
          toDate: _apiDate(_toDate),
        );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? _fromDate : _toDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
      } else {
        _toDate = picked.isBefore(_fromDate) ? _fromDate : picked;
      }
    });

    _fetchComplaints();
  }

  void _clearDates() {
    final now = DateTime.now();
    setState(() {
      _toDate = DateTime(now.year, now.month, now.day);
      _fromDate = _toDate.subtract(const Duration(days: 30));
    });
    _fetchComplaints();
  }

  void _markAsRead(UserComplaintModel complaint) {
    if (complaint.isRead) return;
    context.read<UserComplaintsCubit>().markAsRead(complaint.complaintId);
  }

  void _markAsSolved(UserComplaintModel complaint) {
    if (complaint.isSolved) return;
    context.read<UserComplaintsCubit>().solveComplaint(complaint.complaintId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserComplaintsCubit, UserComplaintsState>(
      listenWhen: (previous, current) =>
          current is UserComplaintsFailure ||
          current is ViewComplaintSuccess ||
          current is ViewComplaintFailure ||
          current is SolveComplaintSuccess ||
          current is SolveComplaintFailure,
      listener: (context, state) {
        if (state is UserComplaintsFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is ViewComplaintSuccess) {
          AppToast.success(state.message, context: context);
        } else if (state is ViewComplaintFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is SolveComplaintSuccess) {
          AppToast.success(state.message, context: context);
        } else if (state is SolveComplaintFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<UserComplaintsCubit>();
        // Always render from cubit list so mark-as-read/solve updates show immediately.
        final complaints = cubit.complaints;
        final isLoading = state is UserComplaintsLoading;
        final markingComplaintId =
            state is ViewComplaintLoading ? state.complaintId : null;
        final solvingComplaintId =
            state is SolveComplaintLoading ? state.complaintId : null;
        final unreadCount = complaints.where((c) => !c.isRead).length;

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      16,
                    ),
                    child: _BreadcrumbHeader(onBack: _handleBack),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ComplaintsDateFilterBar(
                            fromDate: _fromDate,
                            toDate: _toDate,
                            formatDate: _formatDate,
                            onPickFrom: () => _pickDate(isFrom: true),
                            onPickTo: () => _pickDate(isFrom: false),
                            onClear: _clearDates,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Complaints',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EBF6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${complaints.length} total'
                                  '${unreadCount > 0 ? ' · $unreadCount unread' : ''}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isLoading)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                )
                              else
                                InkWell(
                                  onTap: _fetchComplaints,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: AppColors.accent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Refresh',
                                          style: TextStyle(
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isLoading && complaints.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.accent,
                                ),
                              ),
                            )
                          else if (complaints.isEmpty)
                            const ComplaintsEmptyState()
                          else
                            LayoutBuilder(
                              builder: (context, gridConstraints) {
                                final width = gridConstraints.maxWidth;
                                final crossAxisCount = width >= 1100
                                    ? 3
                                    : width >= 700
                                        ? 2
                                        : 1;
                                const spacing = 12.0;
                                final cardWidth = (width -
                                        (spacing * (crossAxisCount - 1))) /
                                    crossAxisCount;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: [
                                    for (final complaint in complaints)
                                      SizedBox(
                                        width: cardWidth,
                                        height: 230,
                                        child: ComplaintCard(
                                          complaint: complaint,
                                          formatDate: _formatDate,
                                          isMarking: markingComplaintId ==
                                              complaint.complaintId,
                                          isSolving: solvingComplaintId ==
                                              complaint.complaintId,
                                          onMarkAsRead: () =>
                                              _markAsRead(complaint),
                                          onMarkAsSolved: () =>
                                              _markAsSolved(complaint),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  'User Complaints',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'User Complaints',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review user feedback and mark complaints as read',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Settings',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 12),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndTitle),
            backButton,
          ],
        );
      },
    );
  }
}
