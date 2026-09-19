import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investor_model.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository repository,
  })  : _repository = repository,
        super(HomeInitial());

  final HomeRepository _repository;
  bool _isLoading = false;

  Future<void> loadHome({bool silent = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!silent) {
      emit(HomeLoading());
    }

    final previous = state is HomeSuccess ? state as HomeSuccess : null;

    try {
      HomeProfileModel? profile;
      List<TopInvestorModel>? topInvestors;
      Object? profileError;
      Object? investorsError;

      await Future.wait([
        _repository.getHomeProfile().then((value) {
          profile = value;
        }).catchError((Object error) {
          profileError = error;
        }),
        _repository.getTopInvestors().then((value) {
          topInvestors = value;
        }).catchError((Object error) {
          investorsError = error;
        }),
      ]);

      final nextProfile = profile ?? previous?.profile;
      final nextInvestors = topInvestors ?? previous?.topInvestors;

      // Prefer emitting updated data even if one of the calls failed.
      if (nextProfile != null) {
        emit(
          HomeSuccess(
            profile: nextProfile,
            topInvestors: nextInvestors ?? const [],
          ),
        );
        return;
      }

      if (silent && previous != null) return;

      final error = profileError ?? investorsError;
      emit(HomeFailure(_messageFromError(error)));
    } finally {
      _isLoading = false;
    }
  }

  String _messageFromError(Object? error) {
    if (error is DioException) {
      final message = error.response?.data is Map
          ? (error.response?.data['message'] as String?)
          : null;
      if (message != null && message.isNotEmpty) return message;
      return error.message ?? 'Failed to load home';
    }
    if (error == null) return 'Failed to load home';
    return error.toString().replaceFirst('Exception: ', '');
  }
}
