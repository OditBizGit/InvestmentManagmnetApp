import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';

/// Role → admin sidebar visibility. Local until backend permissions arrive.
class AdminNavPermissions {
  AdminNavPermissions._();

  static const String marketingManagerRole = 'MarketingManager';

  /// Lowercase, no spaces — matches API values and display labels.
  static String normalizeRole(String? role) =>
      role?.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '') ?? '';

  static bool isMarketingManager(String? role) =>
      normalizeRole(role) == normalizeRole(marketingManagerRole);

  static Set<AdminDrawerItem> _allExceptPendingRequests() {
    return AdminDrawerItem.values
        .where((item) => item != AdminDrawerItem.pendingRequests)
        .toSet();
  }

  /// Drawer items the role may open. Logout is always available outside this set.
  static Set<AdminDrawerItem> allowedDrawerItems(String? role) {
    if (isMarketingManager(role)) {
      return {AdminDrawerItem.pendingRequests};
    }
    return _allExceptPendingRequests();
  }

  static AdminDrawerItem defaultDrawerItem(String? role) {
    if (isMarketingManager(role)) {
      return AdminDrawerItem.pendingRequests;
    }
    return AdminDrawerItem.dashboard;
  }

  static bool canOpen(AdminDrawerItem item, String? role) =>
      allowedDrawerItems(role).contains(item);

  static bool canAccessPendingRequests(String? role) =>
      isMarketingManager(role);
}
