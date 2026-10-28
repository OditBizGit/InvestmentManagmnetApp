import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';

/// Role → admin sidebar visibility. Local until backend permissions arrive.
class AdminNavPermissions {
  AdminNavPermissions._();

  static const String financialManager = 'financialmanager';

  static String normalizeRole(String? role) =>
      role?.trim().toLowerCase() ?? '';

  static bool isFinancialManager(String? role) =>
      normalizeRole(role) == financialManager;

  /// Drawer items the role may open. Logout is always available outside this set.
  static Set<AdminDrawerItem> allowedDrawerItems(String? role) {
    if (isFinancialManager(role)) {
      return {AdminDrawerItem.pendingRequests};
    }
    return AdminDrawerItem.values.toSet();
  }

  static AdminDrawerItem defaultDrawerItem(String? role) {
    if (isFinancialManager(role)) {
      return AdminDrawerItem.pendingRequests;
    }
    return AdminDrawerItem.dashboard;
  }

  static bool canOpen(AdminDrawerItem item, String? role) =>
      allowedDrawerItems(role).contains(item);
}
