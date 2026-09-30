import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/user/home/model/banner_item_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investor_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_item_model.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/home_repository.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_update_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/repository/updates_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository repository,
    required UpdatesRepository updatesRepository,
  })  : _repository = repository,
        _updatesRepository = updatesRepository,
        super(HomeInitial());

  final HomeRepository _repository;
  final UpdatesRepository _updatesRepository;
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
      List<WorkProgressItemModel>? workProgress;
      List<BannerItemModel>? banners;
      WorkUpdateModel? latestUpdate;
      Object? profileError;
      Object? investorsError;
      Object? workProgressError;
      Object? bannersError;
      Object? latestUpdateError;

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
        _repository.getWorkProgressDetails().then((value) {
          workProgress = value;
        }).catchError((Object error) {
          workProgressError = error;
        }),
        _repository.getBanners().then((value) {
          banners = value;
        }).catchError((Object error) {
          bannersError = error;
        }),
        _updatesRepository.getWorkUpdates(forceRefresh: true).then((value) {
          latestUpdate = _pickLatest(value);
        }).catchError((Object error) {
          latestUpdateError = error;
        }),
      ]);

      final nextProfile = profile ?? previous?.profile;
      final nextInvestors = topInvestors ?? previous?.topInvestors;
      final nextWorkProgress = workProgress ?? previous?.workProgress;
      final nextBanners = banners ?? previous?.banners;
      final nextLatestUpdate = latestUpdate ?? previous?.latestUpdate;

      // Prefer emitting updated data even if one of the calls failed.
      if (nextProfile != null) {
        emit(
          HomeSuccess(
            profile: nextProfile,
            topInvestors: nextInvestors ?? const [],
            workProgress: nextWorkProgress ?? const [],
            banners: nextBanners ?? const [],
            latestUpdate: nextLatestUpdate,
          ),
        );
        return;
      }

      if (silent && previous != null) return;

      final error = profileError ??
          investorsError ??
          workProgressError ??
          bannersError ??
          latestUpdateError;
      emit(HomeFailure(_messageFromError(error)));
    } finally {
      _isLoading = false;
    }
  }

  WorkUpdateModel? _pickLatest(List<WorkUpdateModel> updates) {
    if (updates.isEmpty) return null;

    final sorted = List<WorkUpdateModel>.from(updates)
      ..sort((a, b) {
        final aDate = a.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return sorted.first;
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
