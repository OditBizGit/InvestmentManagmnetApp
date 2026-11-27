import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_nav_permissions.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';

const _newItems = [
  // PM 2026-11-23: Collection Aging hidden for now — uncomment to restore.
  // AdminDrawerItem.collectionAging,
  AdminDrawerItem.expectedVsActual,
  AdminDrawerItem.refundTermination,
  AdminDrawerItem.investorStatement,
];

void main() {
  group('AdminNavPermissions (TC02)', () {
    test('Admin and SuperAdmin can open the new report items', () {
      for (final role in ['Admin', 'SuperAdmin']) {
        for (final item in _newItems) {
          expect(
            AdminNavPermissions.canOpen(item, role),
            isTrue,
            reason: '$role / $item',
          );
        }
      }
    });

    test('FinancialManager and MarketingManager cannot open them', () {
      for (final role in ['FinancialManager', 'MarketingManager']) {
        for (final item in _newItems) {
          expect(
            AdminNavPermissions.canOpen(item, role),
            isFalse,
            reason: '$role / $item',
          );
        }
      }
    });
  });

  group('AdminSideDrawer Reports group (TC01)', () {
    test('lists the report items in order for Admin', () {
      final reports = AdminSideDrawer.destinationsForRole(
        'Admin',
      ).firstWhere((d) => d.label == 'Reports');

      expect(reports.children.map((c) => c.label).toList(), [
        'Overview',
        'Staff Report',
        // PM 2026-11-23: Collection Aging hidden for now — uncomment to restore.
        // 'Collection Aging',
        'Expected vs Actual',
        'Refunds & Terminations',
        'Investor Statement',
      ]);
    });

    test('child items map to the new drawer items', () {
      final reports = AdminSideDrawer.destinationsForRole(
        'SuperAdmin',
      ).firstWhere((d) => d.label == 'Reports');

      expect(reports.children.map((c) => c.item).skip(2).toList(), _newItems);
    });

    test('managers see no Reports group', () {
      for (final role in ['FinancialManager', 'MarketingManager']) {
        final labels = AdminSideDrawer.destinationsForRole(
          role,
        ).map((d) => d.label);
        expect(labels, isNot(contains('Reports')));
      }
    });
  });
}
