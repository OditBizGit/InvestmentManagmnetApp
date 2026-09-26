part of 'user_complaints_cubit.dart';

@immutable
sealed class UserComplaintsState {
  const UserComplaintsState();
}

final class UserComplaintsInitial extends UserComplaintsState {
  const UserComplaintsInitial();
}

final class UserComplaintsLoading extends UserComplaintsState {
  const UserComplaintsLoading();
}

final class UserComplaintsSuccess extends UserComplaintsState {
  const UserComplaintsSuccess({
    required this.complaints,
    this.message = '',
  });

  final List<UserComplaintModel> complaints;
  final String message;
}

final class UserComplaintsFailure extends UserComplaintsState {
  const UserComplaintsFailure(this.message);

  final String message;
}

final class ViewComplaintLoading extends UserComplaintsState {
  const ViewComplaintLoading({required this.complaintId});

  final int complaintId;
}

final class ViewComplaintSuccess extends UserComplaintsState {
  const ViewComplaintSuccess({
    required this.complaintId,
    required this.message,
  });

  final int complaintId;
  final String message;
}

final class ViewComplaintFailure extends UserComplaintsState {
  const ViewComplaintFailure({required this.message});

  final String message;
}

final class SolveComplaintLoading extends UserComplaintsState {
  const SolveComplaintLoading({required this.complaintId});

  final int complaintId;
}

final class SolveComplaintSuccess extends UserComplaintsState {
  const SolveComplaintSuccess({
    required this.complaintId,
    required this.message,
  });

  final int complaintId;
  final String message;
}

final class SolveComplaintFailure extends UserComplaintsState {
  const SolveComplaintFailure({required this.message});

  final String message;
}
