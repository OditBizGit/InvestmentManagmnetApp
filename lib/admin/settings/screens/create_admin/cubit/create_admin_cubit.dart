import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/model/admins_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/model/create_admin_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/repository/create_admin_repository.dart';

part 'create_admin_state.dart';

class CreateAdminCubit extends Cubit<CreateAdminState> {
  CreateAdminCubit({
    required CreateAdminRepository repository,
  })  : _repository = repository,
        super(const CreateAdminViewState());

  final CreateAdminRepository _repository;

  CreateAdminViewState get _view {
    final current = state;
    if (current is CreateAdminViewState) return current;
    return const CreateAdminViewState();
  }

  Future<void> fetchAdmins() async {
    final current = _view;
    if (current.isAdminsLoading) return;

    emit(
      current.copyWith(
        isAdminsLoading: true,
        clearAdminsError: true,
      ),
    );

    try {
      final result = await _repository.getAdmins();
      if (isClosed) return;

      emit(
        _view.copyWith(
          admins: result.data,
          isAdminsLoading: false,
          clearAdminsError: true,
        ),
      );
    } on DioException catch (e) {
      if (isClosed) return;
      final message = _dioErrorMessage(e);
      emit(
        _view.copyWith(
          isAdminsLoading: false,
          adminsError: message.isNotEmpty
              ? message
              : 'Failed to retrieve admins',
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        _view.copyWith(
          isAdminsLoading: false,
          adminsError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> createAdmin(CreateAdminModel request) async {
    final current = _view;
    if (current.isSubmitting) return;

    emit(
      current.copyWith(
        isSubmitting: true,
        clearActionFeedback: true,
      ),
    );

    try {
      final result = await _repository.createAdmin(request);
      if (isClosed) return;

      emit(
        _view.copyWith(
          isSubmitting: false,
          actionFeedback: CreateAdminActionFeedback(
            isSuccess: true,
            message: result.message.isNotEmpty
                ? result.message
                : 'Admin created successfully',
            data: result.data,
          ),
        ),
      );
    } on DioException catch (e) {
      if (isClosed) return;
      final message = _dioErrorMessage(e);
      emit(
        _view.copyWith(
          isSubmitting: false,
          actionFeedback: CreateAdminActionFeedback(
            isSuccess: false,
            message: message.isNotEmpty ? message : 'Failed to create admin',
          ),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        _view.copyWith(
          isSubmitting: false,
          actionFeedback: CreateAdminActionFeedback(
            isSuccess: false,
            message: e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void clearActionFeedback() {
    final current = state;
    if (current is! CreateAdminViewState || current.actionFeedback == null) {
      return;
    }
    emit(current.copyWith(clearActionFeedback: true));
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['Message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return e.message ?? '';
  }
}
