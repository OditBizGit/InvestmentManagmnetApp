import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
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
      final profile = await _repository.getHomeProfile();
      emit(HomeSuccess(profile));
    } catch (e) {
      emit(
        HomeFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
