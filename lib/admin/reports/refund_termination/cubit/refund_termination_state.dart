part of 'refund_termination_cubit.dart';

sealed class RefundTerminationState {
  const RefundTerminationState();
}

final class RefundTerminationInitial extends RefundTerminationState {
  const RefundTerminationInitial();
}

final class RefundTerminationLoading extends RefundTerminationState {
  const RefundTerminationLoading();
}

final class RefundTerminationLoaded extends RefundTerminationState {
  const RefundTerminationLoaded(this.report);

  final RefundTerminationReportModel report;
}

final class RefundTerminationError extends RefundTerminationState {
  const RefundTerminationError(this.message);

  final String message;
}
