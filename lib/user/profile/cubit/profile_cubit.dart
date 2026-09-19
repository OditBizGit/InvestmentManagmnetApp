import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository repository,
    required LocalStorage localStorage,
  })  : _repository = repository,
        _localStorage = localStorage,
        super(const ProfileInitial());

  final ProfileRepository _repository;
  final LocalStorage _localStorage;

  Future<void> loadProfile({bool silent = false}) async {
    if (!silent) {
      emit(const ProfileLoading());
    }

    final userId = _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      if (!silent || state is! ProfileSuccess) {
        emit(const ProfileFailure('User not logged in'));
      }
      return;
    }

    try {
      final response = await _repository.getInvestorDetails(userId);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful || response.data == null) {
        if (silent && state is ProfileSuccess) return;
        emit(
          ProfileFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load investor details',
          ),
        );
        return;
      }

      emit(ProfileSuccess(response.data!));
    } on DioException catch (e) {
      if (silent && state is ProfileSuccess) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      emit(
        ProfileFailure(
          message?.isNotEmpty == true
              ? message!
              : (e.message ?? 'Failed to load investor details'),
        ),
      );
    } catch (e) {
      if (silent && state is ProfileSuccess) return;
      emit(
        ProfileFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
