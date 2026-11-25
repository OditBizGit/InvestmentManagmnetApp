import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';

/// Role → admin sidebar visibility. Local until backend permissions arrive.
///
/// - MarketingManager: Pending Requests only (can review requests).
/// - FinancialManager: Monthly List only (can approve/reject payments).
/// - SuperAdmin: every item, explicitly. Pending Requests and Monthly List are
///   view-only for SuperAdmin (the review/modify checks below are false).
/// - Admin and unknown/null roles: every item except Pending Requests and
///   Monthly List.
///
/// The API is the real guard; these rules only decide what the UI shows.
class AdminNavPermissions {
  AdminNavPermissions._();

  static const String adminRole = 'Admin';
  static const String superAdminRole = 'SuperAdmin';
  static const String financialManagerRole = 'FinancialManager';
  static const String marketingManagerRole = 'MarketingManager';

  /// Roles that may sign in on the admin web login screen.
  static const List<String> adminWebLoginRoles = [
    adminRole,
    superAdminRole,
    financialManagerRole,
    marketingManagerRole,
  ];

  /// Display labels for the admin web login role dropdown.
  static const List<String> adminWebLoginRoleLabels = [
    'Admin',
    'Super Admin',
    'Financial Manager',
    'Marketing Manager',
  ];

  /// Maps a web-login dropdown label to the API `userRole` value.
  static String apiRoleForWebLoginLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'super admin':
        return superAdminRole;
      case 'financial manager':
        return financialManagerRole;
      case 'marketing manager':
        return marketingManagerRole;
      case 'admin':
      default:
        return adminRole;
    }
  }

  /// Lowercase, no spaces — matches API values and display labels.
  static String normalizeRole(String? role) =>
      role?.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '') ?? '';

  static bool canAccessAdminWebLogin(String? role) {
    final normalized = normalizeRole(role);
    return adminWebLoginRoles
        .map(normalizeRole)
        .any((allowed) => allowed == normalized);
  }

  static bool isMarketingManager(String? role) =>
      normalizeRole(role) == normalizeRole(marketingManagerRole);

  static bool isFinancialManager(String? role) =>
      normalizeRole(role) == normalizeRole(financialManagerRole);

  static bool isSuperAdmin(String? role) =>
      normalizeRole(role) == normalizeRole(superAdminRole);

  /// Fallback set for Admin and unknown/null roles.
  static Set<AdminDrawerItem> _allExceptPendingRequestsAndMonthlyList() {
    return AdminDrawerItem.values
        .where(
          (item) =>
              item != AdminDrawerItem.pendingRequests &&
              item != AdminDrawerItem.monthlyList,
        )
        .toSet();
  }

  /// Drawer items the role may open. Logout is always available outside this set.
  static Set<AdminDrawerItem> allowedDrawerItems(String? role) {
    if (isMarketingManager(role)) {
      return {AdminDrawerItem.pendingRequests};
    }
    if (isFinancialManager(role)) {
      return {AdminDrawerItem.monthlyList};
    }
    if (isSuperAdmin(role)) {
      // Explicit, not via the fallback helper: a later fallback change must not
      // widen or shrink SuperAdmin.
      return AdminDrawerItem.values.toSet();
    }
    return _allExceptPendingRequestsAndMonthlyList();
  }

  static AdminDrawerItem defaultDrawerItem(String? role) {
    if (isMarketingManager(role)) {
      return AdminDrawerItem.pendingRequests;
    }
    if (isFinancialManager(role)) {
      return AdminDrawerItem.monthlyList;
    }
    return AdminDrawerItem.dashboard;
  }

  static bool canOpen(AdminDrawerItem item, String? role) =>
      allowedDrawerItems(role).contains(item);

  /// May open Pending Requests (MarketingManager reviews, SuperAdmin views).
  static bool canAccessPendingRequests(String? role) =>
      isMarketingManager(role) || isSuperAdmin(role);

  /// May accept/reject payment and block requests (MarketingManager only).
  static bool canReviewPendingRequests(String? role) =>
      isMarketingManager(role);

  /// May open Monthly List (FinancialManager, SuperAdmin).
  static bool canAccessMonthlyList(String? role) =>
      canOpen(AdminDrawerItem.monthlyList, role);

  /// May approve/reject monthly payments (FinancialManager only).
  static bool canModifyMonthlyList(String? role) => isFinancialManager(role);
}
