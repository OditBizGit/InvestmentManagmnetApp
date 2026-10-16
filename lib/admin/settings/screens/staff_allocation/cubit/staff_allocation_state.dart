part of 'staff_allocation_cubit.dart';

@immutable
sealed class StaffAllocationState {}

final class StaffAllocationInitial extends StaffAllocationState {}

final class StaffAllocationStaffLoading extends StaffAllocationState {}

final class StaffAllocationStaffLoadFailure extends StaffAllocationState {
  StaffAllocationStaffLoadFailure(this.message);

  final String message;
}

final class StaffAllocationStaffLoaded extends StaffAllocationState {
  StaffAllocationStaffLoaded({
    required this.staffMembers,
    this.isCreating = false,
    this.isRefreshing = false,
  });

  final List<StaffModel> staffMembers;
  final bool isCreating;
  final bool isRefreshing;
}

final class StaffAllocationInvestorsLoading extends StaffAllocationState {
  StaffAllocationInvestorsLoading({
    required this.staff,
    required this.staffMembers,
  });

  final StaffModel staff;
  final List<StaffModel> staffMembers;
}

final class StaffAllocationInvestorsLoaded extends StaffAllocationState {
  StaffAllocationInvestorsLoaded({
    required this.staff,
    required this.staffMembers,
    required this.investors,
  });

  final StaffModel staff;
  final List<StaffModel> staffMembers;
  final List<StaffInvestorModel> investors;
}

final class StaffAllocationInvestorsLoadFailure extends StaffAllocationState {
  StaffAllocationInvestorsLoadFailure({
    required this.staff,
    required this.staffMembers,
    required this.message,
  });

  final StaffModel staff;
  final List<StaffModel> staffMembers;
  final String message;
}

final class StaffAllocationCreateSuccess extends StaffAllocationState {
  StaffAllocationCreateSuccess({required this.message});

  final String message;
}

final class StaffAllocationCreateFailure extends StaffAllocationState {
  StaffAllocationCreateFailure(this.message);

  final String message;
}
