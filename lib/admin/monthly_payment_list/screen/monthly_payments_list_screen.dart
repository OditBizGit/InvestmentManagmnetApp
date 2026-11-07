import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/montly_payment_overview.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/montly_payment_table.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

class MonthlyPaymentListScreen extends StatefulWidget {
  const MonthlyPaymentListScreen({super.key});

  @override
  State<MonthlyPaymentListScreen> createState() =>
      _MonthlyPaymentListScreenState();
}

class _MonthlyPaymentListScreenState extends State<MonthlyPaymentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  late DateTime _fromDate;
  late DateTime _toDate;

  final Set<int> _selectedPaymentIds = {};

  List<MonthlyPayment> _payments = [
    MonthlyPayment(
      id: 1,
      investorName: 'Anil Raj',
      investorCode: 'INV-0147',
      contact: '+91 98765 43210',
      staff: 'Sreejith K',
      method: 'UPI',
      amount: 50000,
      paidOn: DateTime(2026, 10, 28),
    ),
    MonthlyPayment(
      id: 2,
      investorName: 'Megha Nair',
      investorCode: 'INV-0152',
      contact: '+91 98470 22334',
      staff: 'Renjith P',
      method: 'NEFT',
      amount: 100000,
      paidOn: DateTime(2026, 10, 28),
    ),
    MonthlyPayment(
      id: 3,
      investorName: 'Vijay Kumar',
      investorCode: 'INV-0098',
      contact: '+91 99612 34567',
      staff: 'Sreejith K',
      method: 'Bank Transfer',
      amount: 75000,
      paidOn: DateTime(2026, 10, 27),
      status: PaymentStatus.approved,
    ),
    MonthlyPayment(
      id: 4,
      investorName: 'Ravi Prakash',
      investorCode: 'INV-0105',
      contact: '+91 98950 66778',
      staff: 'Aneesh M',
      method: 'RTGS',
      amount: 200000,
      paidOn: DateTime(2026, 10, 26),
    ),
    MonthlyPayment(
      id: 5,
      investorName: 'Latha Suresh',
      investorCode: 'INV-0119',
      contact: '+91 97455 88990',
      staff: 'Renjith P',
      method: 'Cash',
      amount: 25000,
      paidOn: DateTime(2026, 10, 25),
      status: PaymentStatus.approved,
    ),
    MonthlyPayment(
      id: 6,
      investorName: 'Harish J',
      investorCode: 'INV-0127',
      contact: '+91 90721 44556',
      staff: 'Aneesh M',
      method: 'IMPS',
      amount: 50000,
      paidOn: DateTime(2026, 10, 24),
    ),
    MonthlyPayment(
      id: 7,
      investorName: 'Sridevi Menon',
      investorCode: 'INV-0134',
      contact: '+91 99618 77441',
      staff: 'Sreejith K',
      method: 'Cheque',
      amount: 150000,
      paidOn: DateTime(2026, 10, 23),
      status: PaymentStatus.rejected,
    ),
    MonthlyPayment(
      id: 8,
      investorName: 'Pradeep T',
      investorCode: 'INV-0141',
      contact: '+91 98461 22011',
      staff: 'Renjith P',
      method: 'NEFT',
      amount: 75000,
      paidOn: DateTime(2026, 10, 22),
    ),
    MonthlyPayment(
      id: 9,
      investorName: 'Dileep Kumar',
      investorCode: 'INV-0103',
      contact: '+91 98956 33441',
      staff: 'Aneesh M',
      method: 'UPI',
      amount: 50000,
      paidOn: DateTime(2026, 10, 21),
      status: PaymentStatus.approved,
    ),
    MonthlyPayment(
      id: 10,
      investorName: 'Nisha S',
      investorCode: 'INV-0150',
      contact: '+91 90376 99887',
      staff: 'Sreejith K',
      method: 'Bank Transfer',
      amount: 100000,
      paidOn: DateTime(2026, 10, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultMonthRange();
  }

  void _setDefaultMonthRange() {
    final anchor = _payments
        .map((payment) => payment.paidOn)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    _fromDate = DateTime(anchor.year, anchor.month, 1);
    _toDate = DateTime(anchor.year, anchor.month + 1, 0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isOnOrAfter(DateTime day, DateTime bound) {
    return !day.isBefore(DateTime(bound.year, bound.month, bound.day));
  }

  bool _isOnOrBefore(DateTime day, DateTime bound) {
    return !day.isAfter(DateTime(bound.year, bound.month, bound.day));
  }

  List<MonthlyPayment> get _filteredPayments {
    final query = _searchController.text.trim().toLowerCase();

    return _payments.where((payment) {
      final matchesSearch = query.isEmpty ||
          payment.investorName.toLowerCase().contains(query) ||
          payment.investorCode.toLowerCase().contains(query) ||
          payment.contact.toLowerCase().contains(query);

      final matchesFrom = _isOnOrAfter(payment.paidOn, _fromDate);
      final matchesTo = _isOnOrBefore(payment.paidOn, _toDate);

      return matchesSearch && matchesFrom && matchesTo;
    }).toList();
  }

  void _updateStatus(
    Iterable<int> ids,
    PaymentStatus status,
  ) {
    final idSet = ids.toSet();

    setState(() {
      _payments = _payments.map((payment) {
        if (idSet.contains(payment.id) &&
            payment.status == PaymentStatus.pending) {
          return payment.copyWith(status: status);
        }
        return payment;
      }).toList();

      _selectedPaymentIds.removeAll(idSet);
    });
  }

  void _approveAll() {
    final pendingIds = _filteredPayments
        .where((payment) => payment.status == PaymentStatus.pending)
        .map((payment) => payment.id);

    _updateStatus(pendingIds, PaymentStatus.approved);
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _payments.where((p) => p.status == PaymentStatus.pending);
    final approved =
        _payments.where((p) => p.status == PaymentStatus.approved);
    final rejected =
        _payments.where((p) => p.status == PaymentStatus.rejected);

    final totalAmount = _payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  16,
                ),
                child: const AdminTopBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MonthlyPaymentOverview(
                        totalPayments: _payments.length,
                        totalAmount: totalAmount,
                        pendingCount: pending.length,
                        approvedCount: approved.length,
                        rejectedCount: rejected.length,
                      ),
                      const SizedBox(height: 20),
                      MonthlyPaymentTable(
                          payments: _filteredPayments,
                          selectedIds: _selectedPaymentIds,
                          searchController: _searchController,
                          fromDate: _fromDate,
                          toDate: _toDate,
                          onSearchChanged: (_) => setState(() {}),
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          onFromDateChanged: (value) {
                            setState(() {
                              if (value == null) {
                                _setDefaultMonthRange();
                              } else {
                                _fromDate = value;
                              }
                            });
                          },
                          onToDateChanged: (value) {
                            setState(() {
                              if (value == null) {
                                _setDefaultMonthRange();
                              } else {
                                _toDate = value;
                              }
                            });
                          },
                          onSelectionChanged: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedPaymentIds.add(id);
                              } else {
                                _selectedPaymentIds.remove(id);
                              }
                            });
                          },
                          onSelectAllChanged: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPaymentIds.addAll(
                                  _filteredPayments
                                      .where(
                                        (p) =>
                                            p.status == PaymentStatus.pending,
                                      )
                                      .map((p) => p.id),
                                );
                              } else {
                                _selectedPaymentIds.removeAll(
                                  _filteredPayments.map((p) => p.id),
                                );
                              }
                            });
                          },
                          onApprove: (id) {
                            _updateStatus([id], PaymentStatus.approved);
                          },
                          onReject: (id) {
                            _updateStatus([id], PaymentStatus.rejected);
                          },
                          onApproveAll: _approveAll,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
