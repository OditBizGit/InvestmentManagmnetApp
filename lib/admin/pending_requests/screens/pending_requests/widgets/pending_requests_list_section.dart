import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_request_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_list_toolbar.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../../../cubit/pending_requests_cubit.dart';
import '../../../model/pending_request_model.dart';

class PendingRequestsListSection extends StatefulWidget {
  const PendingRequestsListSection({
    super.key,
    required this.onReview,
  });

  final ValueChanged<PendingRequestModel> onReview;

  @override
  State<PendingRequestsListSection> createState() =>
      _PendingRequestsListSectionState();
}

class _PendingRequestsListSectionState
    extends State<PendingRequestsListSection> {
  static final _filters =
      PendingRequestsListFilter.values.map((f) => f.label).toList();

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PendingRequestModel> _filtered(List<PendingRequestModel> requests) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return requests;

    return requests.where((request) {
      return request.applicantName.toLowerCase().contains(query) ||
          request.requestId.toLowerCase().contains(query) ||
          request.email.toLowerCase().contains(query) ||
          request.phoneNumber.toLowerCase().contains(query) ||
          request.allocation.toLowerCase().contains(query);
    }).toList();
  }

  String _emptyMessage(PendingRequestsListFilter filter) {
    if (_query.trim().isNotEmpty) return 'No requests match your search';
    return switch (filter) {
      PendingRequestsListFilter.all => 'No payment requests',
      PendingRequestsListFilter.pending => 'No pending requests',
      PendingRequestsListFilter.approved => 'No approved requests',
      PendingRequestsListFilter.rejected => 'No rejected requests',
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendingRequestsCubit, PendingRequestsState>(
      builder: (context, state) {
        final isLoading = state is PendingRequestsInitial ||
            state is PendingRequestsLoading ||
            (state is PendingRequestsSuccess && state.isListLoading);

        final statusFilter = switch (state) {
          PendingRequestsSuccess(:final statusFilter) => statusFilter,
          PendingRequestsLoading(:final statusFilter) => statusFilter,
          PendingRequestsFailure(:final statusFilter) => statusFilter,
          _ => PendingRequestsListFilter.all,
        };

        final requests = state is PendingRequestsSuccess
            ? state.requests
            : const <PendingRequestModel>[];
        final filtered = _filtered(requests);
        final failureMessage =
            state is PendingRequestsFailure ? state.message : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserManagementTableCard(
              child: UserManagementListToolbar(
                title: 'Payment requests',
                searchController: _searchController,
                searchHint: 'Search by name, request ID, email, phone...',
                onSearchChanged: (value) => setState(() => _query = value),
                onClearSearch: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                filters: _filters,
                selectedFilterIndex: statusFilter.index,
                onFilterSelected: (index) {
                  context.read<PendingRequestsCubit>().loadRequests(
                        statusFilter: PendingRequestsListFilter.values[index],
                      );
                },
              ),
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const _ListLoading()
            else if (failureMessage != null)
              _ListError(
                message: failureMessage,
                onRetry: () => context.read<PendingRequestsCubit>().loadRequests(
                      statusFilter: statusFilter,
                    ),
              )
            else if (filtered.isEmpty)
              _EmptyState(message: _emptyMessage(statusFilter))
            else
              Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    PendingRequestCard(
                      request: filtered[i],
                      onReview: () => widget.onReview(filtered[i]),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ListLoading extends StatelessWidget {
  const _ListLoading();

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading requests...',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListError extends StatelessWidget {
  const _ListError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
