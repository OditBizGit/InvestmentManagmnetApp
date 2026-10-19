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
  static const _filters = ['Pending', 'Completed'];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  PendingRequestsListFilter _filter = PendingRequestsListFilter.pending;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PendingRequestModel> _filtered(List<PendingRequestModel> requests) {
    final query = _query.trim().toLowerCase();

    return requests.where((request) {
      final matchesFilter = switch (_filter) {
        PendingRequestsListFilter.pending => request.isAwaitingReview,
        PendingRequestsListFilter.completed => request.isClosed,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return request.applicantName.toLowerCase().contains(query) ||
          request.requestId.toLowerCase().contains(query) ||
          request.email.toLowerCase().contains(query) ||
          request.phoneNumber.toLowerCase().contains(query) ||
          request.allocation.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendingRequestsCubit, PendingRequestsState>(
      builder: (context, state) {
        final isLoading = state is PendingRequestsInitial ||
            state is PendingRequestsLoading ||
            (state is PendingRequestsSuccess && state.isListLoading);

        final requests = state is PendingRequestsSuccess
            ? state.requests
            : const <PendingRequestModel>[];
        final filtered = _filtered(requests);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserManagementTableCard(
              child: UserManagementListToolbar(
                title: 'Registration requests',
                searchController: _searchController,
                searchHint: 'Search by name, request ID, email, phone...',
                onSearchChanged: (value) => setState(() => _query = value),
                onClearSearch: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                filters: _filters,
                selectedFilterIndex: _filter.index,
                onFilterSelected: (index) {
                  setState(() {
                    _filter = PendingRequestsListFilter.values[index];
                  });
                },
              ),
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const _ListLoading()
            else if (filtered.isEmpty)
              _EmptyState(
                message: _query.trim().isEmpty
                    ? _filter == PendingRequestsListFilter.pending
                        ? 'No pending requests'
                        : 'No completed requests'
                    : 'No requests match your search',
              )
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
