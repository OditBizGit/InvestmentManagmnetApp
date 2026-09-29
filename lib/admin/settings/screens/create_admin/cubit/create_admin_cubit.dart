import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/model/create_admin_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/repository/create_admin_repository.dart';

part 'create_admin_state.dart';

class CreateAdminCubit extends Cubit<CreateAdminState> {
  CreateAdminCubit({
    required CreateAdminRepository repository,
  })  : _repository = repository,
        super(CreateAdminInitial());

  final CreateAdminRepository _repository;

  Future<void> createAdmin(CreateAdminModel request) async {
    emit(CreateAdminLoading());
    try {
      final result = await _repository.createAdmin(request);

      emit(
        CreateAdminSuccess(
          message: result.message.isNotEmpty
              ? result.message
              : 'Admin created successfully',
          data: result.data,
        ),
      );
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      emit(
        CreateAdminFailure(
          message.isNotEmpty ? message : 'Failed to create admin',
        ),
      );
    } catch (e) {
      emit(
        CreateAdminFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
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
