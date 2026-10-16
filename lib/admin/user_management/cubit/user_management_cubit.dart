import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/data/dummy_managed_users.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';

part 'user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit()
      : super(
          UserManagementState(
            users: List<ManagedUserModel>.from(dummyManagedUsers),
          ),
        );

  void toggleBlockStatus(String userId) {
    _replaceUser(
      userId,
      (user) => user.copyWith(isBlocked: !user.isBlocked),
    );
  }

  void updateMouStatus(String userId, DocumentProcessStatus status) {
    _replaceUser(userId, (user) => user.copyWith(mouStatus: status));
  }

  void updateLlpStatus(String userId, DocumentProcessStatus status) {
    _replaceUser(userId, (user) => user.copyWith(llpStatus: status));
  }

  void _replaceUser(
    String userId,
    ManagedUserModel Function(ManagedUserModel user) update,
  ) {
    emit(
      state.copyWith(
        users: [
          for (final user in state.users)
            if (user.userId == userId) update(user) else user,
        ],
      ),
    );
  }
}
