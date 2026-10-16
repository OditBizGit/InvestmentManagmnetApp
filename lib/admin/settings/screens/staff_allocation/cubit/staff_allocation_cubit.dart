import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/model/create_staff_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/model/get_investors_by_staff_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/model/get_staff_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/repository/staff_allocation_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

part 'staff_allocation_state.dart';

class StaffAllocationCubit extends Cubit<StaffAllocationState> {
  StaffAllocationCubit({
    required StaffRepository repository,
  })  : _repository = repository,
        super(StaffAllocationInitial());

  final StaffRepository _repository;

  Future<void> fetchStaff({bool showLoading = true}) async {
    final current = _currentStaffMembers();
    if (showLoading && current == null) {
      emit(StaffAllocationStaffLoading());
    } else if (current != null) {
      emit(
        StaffAllocationStaffLoaded(
          staffMembers: current,
          isRefreshing: true,
        ),
      );
    }

    try {
      final result = await _repository.getStaff();

      if (!result.success) {
        final message = result.message.trim().isNotEmpty
            ? result.message.trim()
            : 'Failed to load staff';
        if (current != null) {
          emit(StaffAllocationStaffLoaded(staffMembers: current));
        } else {
          emit(StaffAllocationStaffLoadFailure(message));
        }
        return;
      }

      emit(
        StaffAllocationStaffLoaded(
          staffMembers: _validStaffList(result.data),
        ),
      );
    } on DioException catch (e) {
      final message = ApiErrorMessage.from(
        e,
        fallback: 'Failed to load staff',
      );
      if (current != null) {
        emit(StaffAllocationStaffLoaded(staffMembers: current));
      } else {
        emit(StaffAllocationStaffLoadFailure(message));
      }
    } catch (e) {
      final message = ApiErrorMessage.from(
        e,
        fallback: 'Failed to load staff',
      );
      if (current != null) {
        emit(StaffAllocationStaffLoaded(staffMembers: current));
      } else {
        emit(StaffAllocationStaffLoadFailure(message));
      }
    }
  }

  Future<void> createStaff(CreateStaffRequestModel request) async {
    final current = _currentStaffMembers() ?? const <StaffModel>[];

    if (state is StaffAllocationStaffLoaded &&
        (state as StaffAllocationStaffLoaded).isCreating) {
      return;
    }

    emit(
      StaffAllocationStaffLoaded(
        staffMembers: current,
        isCreating: true,
      ),
    );

    try {
      final result = await _repository.createStaff(request);

      if (!result.success) {
        emit(
          StaffAllocationCreateFailure(
            result.message.trim().isNotEmpty
                ? result.message.trim()
                : 'Failed to create staff',
          ),
        );
        emit(
          StaffAllocationStaffLoaded(
            staffMembers: current,
            isCreating: false,
          ),
        );
        return;
      }

      emit(
        StaffAllocationCreateSuccess(
          message: result.message.trim().isNotEmpty
              ? result.message.trim()
              : 'Staff created successfully',
        ),
      );

      await fetchStaff(showLoading: false);
    } on DioException catch (e) {
      emit(
        StaffAllocationCreateFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to create staff',
          ),
        ),
      );
      emit(
        StaffAllocationStaffLoaded(
          staffMembers: current,
          isCreating: false,
        ),
      );
    } catch (e) {
      emit(
        StaffAllocationCreateFailure(
          ApiErrorMessage.from(
            e,
            fallback: 'Failed to create staff',
          ),
        ),
      );
      emit(
        StaffAllocationStaffLoaded(
          staffMembers: current,
          isCreating: false,
        ),
      );
    }
  }

  Future<void> fetchInvestorsByStaff(StaffModel staff) async {
    if (state is StaffAllocationInvestorsLoading) return;

    final staffMembers = _staffMembersSnapshot() ?? const <StaffModel>[];
    emit(
      StaffAllocationInvestorsLoading(
        staff: staff,
        staffMembers: staffMembers,
      ),
    );

    if (staff.staffId <= 0) {
      emit(
        StaffAllocationInvestorsLoadFailure(
          staff: staff,
          staffMembers: staffMembers,
          message: 'Invalid staff id',
        ),
      );
      return;
    }

    try {
      final result = await _repository.getInvestorByStaff(staff.staffId);

      if (!result.success) {
        emit(
          StaffAllocationInvestorsLoadFailure(
            staff: staff,
            staffMembers: staffMembers,
            message: result.message.trim().isNotEmpty
                ? result.message.trim()
                : 'Failed to load assigned investors',
          ),
        );
        return;
      }

      emit(
        StaffAllocationInvestorsLoaded(
          staff: staff,
          staffMembers: staffMembers,
          investors: _validInvestorList(result.data),
        ),
      );
    } on DioException catch (e) {
      emit(
        StaffAllocationInvestorsLoadFailure(
          staff: staff,
          staffMembers: staffMembers,
          message: ApiErrorMessage.from(
            e,
            fallback: 'Failed to load assigned investors',
          ),
        ),
      );
    } catch (e) {
      emit(
        StaffAllocationInvestorsLoadFailure(
          staff: staff,
          staffMembers: staffMembers,
          message: ApiErrorMessage.from(
            e,
            fallback: 'Failed to load assigned investors',
          ),
        ),
      );
    }
  }

  void closeStaffDetail() {
    final members = _staffMembersSnapshot();
    if (members == null) return;
    emit(StaffAllocationStaffLoaded(staffMembers: members));
  }

  List<StaffModel>? _currentStaffMembers() {
    return _staffMembersSnapshot();
  }

  List<StaffModel>? _staffMembersSnapshot() {
    final state = this.state;
    if (state is StaffAllocationStaffLoaded) {
      return state.staffMembers;
    }
    if (state is StaffAllocationInvestorsLoading) {
      return state.staffMembers;
    }
    if (state is StaffAllocationInvestorsLoaded) {
      return state.staffMembers;
    }
    if (state is StaffAllocationInvestorsLoadFailure) {
      return state.staffMembers;
    }
    return null;
  }

  List<StaffModel> _validStaffList(List<StaffModel> data) {
    return data
        .where((staff) => staff.staffId > 0 && staff.fullName.trim().isNotEmpty)
        .toList();
  }

  List<StaffInvestorModel> _validInvestorList(List<StaffInvestorModel> data) {
    return data
        .where(
          (investor) =>
              investor.userId > 0 && investor.fullName.trim().isNotEmpty,
        )
        .toList();
  }
}
