part of 'create_admin_cubit.dart';

@immutable
sealed class CreateAdminState {
  const CreateAdminState();
}

class CreateAdminActionFeedback {
  const CreateAdminActionFeedback({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  final bool isSuccess;
  final String message;
  final CreateAdminModel? data;
}

final class CreateAdminViewState extends CreateAdminState {
  const CreateAdminViewState({
    this.admins = const [],
    this.isSubmitting = false,
    this.isAdminsLoading = false,
    this.adminsError,
    this.actionFeedback,
  });

  final List<AdminModel> admins;
  final bool isSubmitting;
  final bool isAdminsLoading;
  final String? adminsError;
  final CreateAdminActionFeedback? actionFeedback;

  CreateAdminViewState copyWith({
    List<AdminModel>? admins,
    bool? isSubmitting,
    bool? isAdminsLoading,
    String? adminsError,
    bool clearAdminsError = false,
    CreateAdminActionFeedback? actionFeedback,
    bool clearActionFeedback = false,
  }) {
    return CreateAdminViewState(
      admins: admins ?? this.admins,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAdminsLoading: isAdminsLoading ?? this.isAdminsLoading,
      adminsError: clearAdminsError ? null : adminsError ?? this.adminsError,
      actionFeedback: clearActionFeedback
          ? null
          : actionFeedback ?? this.actionFeedback,
    );
  }
}
