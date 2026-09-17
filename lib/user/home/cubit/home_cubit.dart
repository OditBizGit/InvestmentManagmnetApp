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

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repository.getHomeProfile(),
        _repository.getTopInvestors(),
      ]);

      emit(
        HomeSuccess(
          profile: results[0] as HomeProfileModel,
          topInvestors: results[1] as List<TopInvestorModel>,
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        HomeFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load home'),
        ),
      );
    } catch (e) {
      emit(
        HomeFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
