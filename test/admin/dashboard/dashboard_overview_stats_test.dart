import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/cubit/dashboard_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/model/dashboard_model.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/repository/dashboard_repository.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_overview.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_shimmer.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class _FakeDashboardRepository extends Fake implements DashboardRepository {}

class _FakeAddPhaseRepository extends Fake implements AddPhaseRepository {}

/// Cubit that only holds a given state; it never calls the repositories.
class _FakeDashboardCubit extends DashboardCubit {
  _FakeDashboardCubit(DashboardState initial)
      : super(
          phaseRepository: _FakeAddPhaseRepository(),
          dashboardRepository: _FakeDashboardRepository(),
        ) {
    emit(initial);
  }
}

DashboardModel _dashboard({double totalInvestmentAmount = 2500000}) {
  return DashboardModel(
    projectFund: 5000000,
    totalInvestmentAmount: totalInvestmentAmount,
    totalReceivedAmount: 1000000,
    totalPendingAmount: 1500000,
    totalInvestors: 12,
    fundingProgress: 50,
  );
}

DashboardState _state({DashboardModel? dashboard, bool loading = false}) {
  return DashboardState(
    fromDate: DateTime(2026, 11, 1),
    toDate: DateTime(2026, 11, 25),
    dashboard: dashboard,
    dashboardLoading: loading,
  );
}

Future<void> _pump(
  WidgetTester tester,
  DashboardState state, {
  double width = 1440,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = _FakeDashboardCubit(state);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: BlocProvider<DashboardCubit>.value(
            value: cubit,
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: DashboardOverview(),
            ),
          ),
        ),
      ),
    ),
  );
  // Shimmer animates forever, so pumpAndSettle would never return.
  await tester.pump(const Duration(milliseconds: 100));
}

const _expectedOrder = [
  'Total Funding',
  'Committed Amount',
  'Amount Received',
  'Amount Remaining',
  'Total Investors',
  'Funding Progress',
];

/// The `Row` that holds the six stat cards (one `Expanded` per card).
Row _statsRow(WidgetTester tester) {
  final rowFinder = find
      .ancestor(of: find.text('Total Funding'), matching: find.byType(Row))
      .first;
  return tester.widget<Row>(rowFinder);
}

void main() {
  testWidgets('T1: Committed Amount card shows the formatted amount',
      (tester) async {
    await _pump(tester, _state(dashboard: _dashboard()));

    expect(find.text('Committed Amount'), findsOneWidget);
    // 2500000 -> Indian grouping with two decimals.
    expect(find.text('₹25,00,000.00'), findsOneWidget);
  });

  testWidgets('T2: no Active Investors card and exactly 6 cards',
      (tester) async {
    await _pump(tester, _state(dashboard: _dashboard()));

    expect(find.text('Active Investors'), findsNothing);
    final cards = _statsRow(tester).children.whereType<Expanded>();
    expect(cards.length, 6);
  });

  testWidgets('T3: cards are in the agreed order', (tester) async {
    await _pump(tester, _state(dashboard: _dashboard()));

    final xs = [
      for (final label in _expectedOrder)
        tester.getTopLeft(find.text(label)).dx,
    ];
    for (var i = 1; i < xs.length; i++) {
      expect(
        xs[i],
        greaterThan(xs[i - 1]),
        reason: '${_expectedOrder[i]} must sit right of ${_expectedOrder[i - 1]}',
      );
    }
  });

  testWidgets('T4: zero committed amount renders without error',
      (tester) async {
    await _pump(
      tester,
      _state(dashboard: _dashboard(totalInvestmentAmount: 0)),
    );

    expect(find.text('Committed Amount'), findsOneWidget);
    expect(find.text('₹0.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [1024.0, 1440.0]) {
    testWidgets('T5: no overflow at ${width.toInt()} px', (tester) async {
      await _pump(tester, _state(dashboard: _dashboard()), width: width);

      expect(tester.takeException(), isNull);
      expect(find.text('Committed Amount'), findsOneWidget);
    });
  }

  testWidgets('T6: loading state shows the shimmer with 6 placeholders',
      (tester) async {
    await _pump(tester, _state(loading: true));

    expect(find.byType(DashboardStatsShimmer), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DashboardStatsShimmer),
        matching: find.byType(Shimmer),
      ),
      findsNWidgets(6),
    );
    expect(find.text('Committed Amount'), findsNothing);
  });
}
