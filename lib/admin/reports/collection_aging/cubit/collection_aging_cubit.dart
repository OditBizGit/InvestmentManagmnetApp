import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../model/collection_aging_model.dart';
import '../repository/collection_aging_repository.dart';

part 'collection_aging_state.dart';

class CollectionAgingCubit extends Cubit<CollectionAgingState> {
  CollectionAgingCubit(this.repository) : super(const CollectionAgingInitial());

  final CollectionAgingRepository repository;

  /// Only the latest request may emit; older responses are dropped.
  int _requestId = 0;

  Future<void> load(DateTime asOfDate) async {
    final id = ++_requestId;
    emit(const CollectionAgingLoading());
    try {
      final report = await repository.getReport(asOfDate: asOfDate);
      if (isClosed || id != _requestId) return;
      emit(CollectionAgingLoaded(report));
    } catch (e) {
      if (isClosed || id != _requestId) return;
      emit(CollectionAgingError(ApiErrorMessage.from(e)));
    }
  }
}
