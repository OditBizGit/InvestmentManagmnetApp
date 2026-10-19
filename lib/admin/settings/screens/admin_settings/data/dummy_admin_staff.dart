import 'package:maribel_wellness_centre_application/admin/settings/screens/admin_settings/model/admin_staff_permission_model.dart';

final List<AdminStaffPermissionModel> dummyAdminStaff = [
  AdminStaffPermissionModel(
    id: 'staff-01',
    fullName: 'Ananya Sharma',
    designation: 'Operations Manager',
    email: 'ananya.sharma@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'investors',
      'payments',
      'duePayments',
      'reports',
      'settings',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-02',
    fullName: 'Rahul Menon',
    designation: 'Accounts Executive',
    email: 'rahul.menon@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'payments',
      'duePayments',
      'reports',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-03',
    fullName: 'Priya Nair',
    designation: 'Investor Relations',
    email: 'priya.nair@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'investors',
      'pendingRequests',
      'manageUsers',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-04',
    fullName: 'Vikram Iyer',
    designation: 'Site Coordinator',
    email: 'vikram.iyer@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'workProgress',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-05',
    fullName: 'Meera Kapoor',
    designation: 'Compliance Officer',
    email: 'meera.kapoor@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'investors',
      'pendingRequests',
      'reports',
      'settings',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-06',
    fullName: 'Arjun Das',
    designation: 'Support Associate',
    email: 'arjun.das@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'pendingRequests',
    },
  ),
  AdminStaffPermissionModel(
    id: 'staff-07',
    fullName: 'Sneha Reddy',
    designation: 'Admin Assistant',
    email: 'sneha.reddy@maribel.local',
    allowedScreenIds: {
      'dashboard',
      'investors',
      'workProgress',
      'reports',
      'duePayments',
      'pendingRequests',
      'manageUsers',
      'payments',
      'settings',
    },
  ),
];
