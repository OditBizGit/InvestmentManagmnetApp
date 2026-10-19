part of 'due_payments_cubit.dart';

@immutable
sealed class DuePaymentsState {
  const DuePaymentsState();
}

final class DuePaymentsInitial extends DuePaymentsState {
  const DuePaymentsInitial();
}

final class DuePaymentsLoading extends DuePaymentsState {
  const DuePaymentsLoading();
}

final class DuePaymentsSuccess extends DuePaymentsState {
  const DuePaymentsSuccess({
    required this.items,
    required this.statusFilter,
    required this.search,
    this.overview,
    this.isTableLoading = false,
  });

  final List<PaymentStatusReportModel> items;
  final DuePaymentsStatusFilter statusFilter;
  final String search;
  final DuePaymentsOverviewStats? overview;
  final bool isTableLoading;

  DuePaymentsSuccess copyWith({
    List<PaymentStatusReportModel>? items,
    DuePaymentsStatusFilter? statusFilter,
    String? search,
    DuePaymentsOverviewStats? overview,
    bool? isTableLoading,
  }) {
    return DuePaymentsSuccess(
      items: items ?? this.items,
      statusFilter: statusFilter ?? this.statusFilter,
      search: search ?? this.search,
      overview: overview ?? this.overview,
      isTableLoading: isTableLoading ?? this.isTableLoading,
    );
  }
}

final class DuePaymentsEmpty extends DuePaymentsState {
  const DuePaymentsEmpty({
    required this.statusFilter,
    required this.search,
    this.overview,
    this.isTableLoading = false,
  });

  final DuePaymentsStatusFilter statusFilter;
  final String search;
  final DuePaymentsOverviewStats? overview;
  final bool isTableLoading;

  DuePaymentsEmpty copyWith({
    DuePaymentsStatusFilter? statusFilter,
    String? search,
    DuePaymentsOverviewStats? overview,
    bool? isTableLoading,
  }) {
    return DuePaymentsEmpty(
      statusFilter: statusFilter ?? this.statusFilter,
      search: search ?? this.search,
      overview: overview ?? this.overview,
      isTableLoading: isTableLoading ?? this.isTableLoading,
    );
  }
}

final class DuePaymentsFailure extends DuePaymentsState {
  const DuePaymentsFailure({
    required this.message,
    required this.statusFilter,
    required this.search,
    this.overview,
  });

  final String message;
  final DuePaymentsStatusFilter statusFilter;
  final String search;
  final DuePaymentsOverviewStats? overview;
}

@immutable
class DuePaymentsOverviewStats {
  const DuePaymentsOverviewStats({
    required this.totalOutstandingDues,
    required this.usersWithPendingDues,
    required this.partiallyPaidUsers,
    required this.fullyPaidUsers,
  });

  final double totalOutstandingDues;
  final int usersWithPendingDues;
  final int partiallyPaidUsers;
  final int fullyPaidUsers;
}
