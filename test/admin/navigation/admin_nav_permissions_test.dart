import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_nav_permissions.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';

/// Every item except Pending Requests and Monthly List (Admin / fallback set).
Set<AdminDrawerItem> _fallbackItems() => AdminDrawerItem.values
    .where(
      (item) =>
          item != AdminDrawerItem.pendingRequests &&
          item != AdminDrawerItem.monthlyList,
    )
    .toSet();

List<String> _labels(String? role) =>
    AdminSideDrawer.destinationsForRole(role).map((d) => d.label).toList();

void main() {
  group('allowedDrawerItems', () {
    test(
      'U1 SuperAdmin gets every item, incl. Pending Requests and Monthly List',
      () {
        final items = AdminNavPermissions.allowedDrawerItems('SuperAdmin');
        expect(items, AdminDrawerItem.values.toSet());
        expect(items, contains(AdminDrawerItem.pendingRequests));
        expect(items, contains(AdminDrawerItem.monthlyList));
        // everything SuperAdmin could open before this change is still open
        expect(items.containsAll(_fallbackItems()), isTrue);
      },
    );

    test('U2 FinancialManager gets only Monthly List', () {
      expect(AdminNavPermissions.allowedDrawerItems('FinancialManager'), {
        AdminDrawerItem.monthlyList,
      });
    });

    test('U3 MarketingManager gets only Pending Requests', () {
      expect(AdminNavPermissions.allowedDrawerItems('MarketingManager'), {
        AdminDrawerItem.pendingRequests,
      });
    });

    test(
      'U4 Admin, null and unknown roles lose Pending Requests and Monthly List',
      () {
        for (final role in <String?>['Admin', null, 'Unknown']) {
          final items = AdminNavPermissions.allowedDrawerItems(role);
          expect(
            items,
            isNot(contains(AdminDrawerItem.pendingRequests)),
            reason: '$role',
          );
          expect(
            items,
            isNot(contains(AdminDrawerItem.monthlyList)),
            reason: '$role',
          );
          expect(items, _fallbackItems(), reason: '$role');
        }
      },
    );
  });

  group('Pending Requests permissions', () {
    test(
      'U5 canAccessPendingRequests: MarketingManager and SuperAdmin only',
      () {
        for (final role in <String?>['MarketingManager', 'SuperAdmin']) {
          expect(
            AdminNavPermissions.canAccessPendingRequests(role),
            isTrue,
            reason: '$role',
          );
        }
        for (final role in <String?>[
          'Admin',
          'FinancialManager',
          null,
          'Investor',
          'Unknown',
        ]) {
          expect(
            AdminNavPermissions.canAccessPendingRequests(role),
            isFalse,
            reason: '$role',
          );
        }
      },
    );

    test('U6 canReviewPendingRequests: MarketingManager only', () {
      expect(
        AdminNavPermissions.canReviewPendingRequests('MarketingManager'),
        isTrue,
      );
      for (final role in <String?>[
        'SuperAdmin',
        'Admin',
        'FinancialManager',
        null,
        'Investor',
        'Unknown',
      ]) {
        expect(
          AdminNavPermissions.canReviewPendingRequests(role),
          isFalse,
          reason: '$role',
        );
      }
    });
  });

  group('Monthly List permissions', () {
    test('U7 canAccessMonthlyList: FinancialManager and SuperAdmin only', () {
      for (final role in <String?>['FinancialManager', 'SuperAdmin']) {
        expect(
          AdminNavPermissions.canAccessMonthlyList(role),
          isTrue,
          reason: '$role',
        );
      }
      for (final role in <String?>[
        'Admin',
        'MarketingManager',
        null,
        'Investor',
        'Unknown',
      ]) {
        expect(
          AdminNavPermissions.canAccessMonthlyList(role),
          isFalse,
          reason: '$role',
        );
      }
    });

    test('U7 canModifyMonthlyList: FinancialManager only', () {
      expect(
        AdminNavPermissions.canModifyMonthlyList('FinancialManager'),
        isTrue,
      );
      for (final role in <String?>[
        'SuperAdmin',
        'Admin',
        'MarketingManager',
        null,
        'Investor',
        'Unknown',
      ]) {
        expect(
          AdminNavPermissions.canModifyMonthlyList(role),
          isFalse,
          reason: '$role',
        );
      }
    });
  });

  group('Role normalisation', () {
    test('U8 casing and spaces behave like SuperAdmin', () {
      expect(AdminNavPermissions.isSuperAdmin('SuperAdmin'), isTrue);
      expect(AdminNavPermissions.isSuperAdmin('Admin'), isFalse);
      expect(AdminNavPermissions.isSuperAdmin(null), isFalse);
      for (final role in ['superadmin', 'Super Admin', ' SuperAdmin ']) {
        expect(AdminNavPermissions.isSuperAdmin(role), isTrue, reason: role);
        expect(
          AdminNavPermissions.allowedDrawerItems(role),
          AdminNavPermissions.allowedDrawerItems('SuperAdmin'),
          reason: role,
        );
        expect(
          AdminNavPermissions.canAccessPendingRequests(role),
          isTrue,
          reason: role,
        );
        expect(
          AdminNavPermissions.canReviewPendingRequests(role),
          isFalse,
          reason: role,
        );
        expect(
          AdminNavPermissions.canAccessMonthlyList(role),
          isTrue,
          reason: role,
        );
        expect(
          AdminNavPermissions.canModifyMonthlyList(role),
          isFalse,
          reason: role,
        );
        expect(
          AdminNavPermissions.defaultDrawerItem(role),
          AdminDrawerItem.dashboard,
          reason: role,
        );
      }
      expect(
        AdminNavPermissions.defaultDrawerItem('SuperAdmin'),
        AdminDrawerItem.dashboard,
      );
    });

    test('default drawer item is unchanged for the other roles', () {
      expect(
        AdminNavPermissions.defaultDrawerItem('MarketingManager'),
        AdminDrawerItem.pendingRequests,
      );
      expect(
        AdminNavPermissions.defaultDrawerItem('FinancialManager'),
        AdminDrawerItem.monthlyList,
      );
      expect(
        AdminNavPermissions.defaultDrawerItem('Admin'),
        AdminDrawerItem.dashboard,
      );
    });
  });

  group('AdminSideDrawer.destinationsForRole', () {
    test('U10 SuperAdmin sees Pending Requests and Monthly List', () {
      final labels = _labels('SuperAdmin');
      expect(labels, contains('Pending Requests'));
      expect(labels, contains('Monthly List'));
    });

    test('U10 Admin sees neither Pending Requests nor Monthly List', () {
      final labels = _labels('Admin');
      expect(labels, isNot(contains('Pending Requests')));
      expect(labels, isNot(contains('Monthly List')));
      expect(labels, contains('Dashboard'));
      expect(labels, contains('Settings'));
    });

    test('U10 managers keep a single item', () {
      expect(_labels('FinancialManager'), ['Monthly List']);
      expect(_labels('MarketingManager'), ['Pending Requests']);
    });
  });
}
