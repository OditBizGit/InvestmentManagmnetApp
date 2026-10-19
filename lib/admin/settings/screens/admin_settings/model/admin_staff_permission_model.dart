class AdminScreenAccess {
  const AdminScreenAccess({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class AdminStaffPermissionModel {
  const AdminStaffPermissionModel({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.email,
    required this.allowedScreenIds,
  });

  final String id;
  final String fullName;
  final String designation;
  final String email;
  final Set<String> allowedScreenIds;

  int get allowedCount => allowedScreenIds.length;

  AdminStaffPermissionModel copyWith({
    Set<String>? allowedScreenIds,
  }) {
    return AdminStaffPermissionModel(
      id: id,
      fullName: fullName,
      designation: designation,
      email: email,
      allowedScreenIds: allowedScreenIds ?? this.allowedScreenIds,
    );
  }
}

const List<AdminScreenAccess> adminPermissionScreens = [
  AdminScreenAccess(
    id: 'dashboard',
    title: 'Dashboard',
    description: 'Overview, stats, and quick actions',
  ),
  AdminScreenAccess(
    id: 'investors',
    title: 'Investors',
    description: 'View and manage investor records',
  ),
  AdminScreenAccess(
    id: 'payments',
    title: 'Payments',
    description: 'Funding and payment entries',
  ),
  AdminScreenAccess(
    id: 'workProgress',
    title: 'Work Progress',
    description: 'Photos, videos, and project updates',
  ),
  AdminScreenAccess(
    id: 'reports',
    title: 'Reports',
    description: 'Download and review reports',
  ),
  AdminScreenAccess(
    id: 'manageUsers',
    title: 'Manage Users',
    description: 'Block users and update investor status',
  ),
  AdminScreenAccess(
    id: 'duePayments',
    title: 'Due Payments',
    description: 'Outstanding dues and reminders',
  ),
  AdminScreenAccess(
    id: 'pendingRequests',
    title: 'Pending Requests',
    description: 'Review investor document requests',
  ),
  AdminScreenAccess(
    id: 'settings',
    title: 'Settings',
    description: 'Projects, staff, admins, and complaints',
  ),
];
