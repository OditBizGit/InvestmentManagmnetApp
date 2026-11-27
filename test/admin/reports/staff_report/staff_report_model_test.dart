import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_model.dart';

void main() {
  group('StaffReportModel.fromJson', () {
    test('parses the original fields', () {
      final m = StaffReportModel.fromJson({
        'staffId': 4,
        'staffCode': 'S004',
        'staffName': 'Asha',
        'mobileNumber': '9999',
        'totalAmount': 700,
      });
      expect(m.staffId, 4);
      expect(m.staffCode, 'S004');
      expect(m.staffName, 'Asha');
      expect(m.mobileNumber, '9999');
      expect(m.totalAmount, 700);
    });

    test('ignores extra backend fields (receivedAmount, allocatedAmount, ...)',
        () {
      final m = StaffReportModel.fromJson({
        'staffId': 4,
        'staffCode': 'S004',
        'staffName': 'Asha',
        'mobileNumber': '9999',
        'totalAmount': 700,
        'receivedAmount': 1000.5,
        'allocatedAmount': 800,
        'refundAmount': 100,
        'netAmount': 700,
        'investorCount': 3,
      });
      expect(m.staffCode, 'S004');
      expect(m.totalAmount, 700);
    });
  });
}
