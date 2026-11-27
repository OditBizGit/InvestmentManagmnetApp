part of 'collection_aging_cubit.dart';

sealed class CollectionAgingState {
  const CollectionAgingState();
}

final class CollectionAgingInitial extends CollectionAgingState {
  const CollectionAgingInitial();
}

final class CollectionAgingLoading extends CollectionAgingState {
  const CollectionAgingLoading();
}

final class CollectionAgingLoaded extends CollectionAgingState {
  const CollectionAgingLoaded(this.report);

  final CollectionAgingReportModel report;
}

final class CollectionAgingError extends CollectionAgingState {
  const CollectionAgingError(this.message);

  final String message;
}
