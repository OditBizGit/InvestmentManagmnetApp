import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/cubit/pending_requests_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/payment_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/repository/pending_request_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_request_card.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_requests_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/terminated_investors_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/review_request_screen.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/investor_block_requests_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';
import 'package:sizer/sizer.dart';

Map<String, dynamic> _json({String status = 'Pending'}) => {
      'requestId': 7,
      'userId': 3,
      'investorCode': 'INV-1',
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
      'phoneNumber': '9999',
      'paidAmount': 1000,
      'paymentMethod': 'Cash',
      'status': status,
    };

PendingRequestModel _request({String status = 'Pending'}) =>
    PendingRequestModel.fromPaymentRequest(
      PaymentRequestDataModel.fromJson(_json(status: status)),
    );

void _setView(WidgetTester tester, double width, [double height = 1200]) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(WidgetTester tester, Widget child, {double width = 1200}) async {
  _setView(tester, width);
  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

class _FakePaymentRequestRepository extends PaymentRequestRepository {
  _FakePaymentRequestRepository(this._requests) : super(dio: Dio());

  final List<Map<String, dynamic>> _requests;

  @override
  Future<PaymentRequestResponseModel> getPaymentRequests({
    String status = 'All',
  }) async {
    return PaymentRequestResponseModel.fromJson({
      'status': true,
      'message': 'ok',
      'data': _requests,
    });
  }
}

class _FakeInvestorPaymentRepository extends InvestorPaymentRepository {
  _FakeInvestorPaymentRepository() : super(dio: Dio());

  @override
  Future<InvestorDetailsResponseModel> getInvestorDetails({
    required int userId,
  }) async {
    throw Exception('details not available in test');
  }
}

class _FakeManageUsersRepository extends ManageUsersRepository {
  _FakeManageUsersRepository(this._items) : super(dio: Dio());

  final List<InvestorBlockRequestModel> _items;

  @override
  Future<InvestorBlockRequestsResponse> getBlockRequests({
    String? status,
  }) async {
    return InvestorBlockRequestsResponse(
      status: true,
      message: 'ok',
      requests: _items,
      code: 200,
    );
  }
}

InvestorBlockRequestModel _blockRequest({String status = 'Pending'}) =>
    InvestorBlockRequestModel(
      requestId: 11,
      userId: 5,
      investorCode: 'INV-5',
      fullName: 'Terminated Person',
      email: 'term@example.com',
      phoneNumber: '8888',
      isActive: true,
      status: status,
      remarks: 'closing account',
      requestedByName: 'Staff One',
    );

void main() {
  group('PendingRequestCard action label', () {
    testWidgets('W4 canReview false shows View request for pending request',
        (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: PendingRequestCard(
            request: _request(),
            onReview: () {},
            canReview: false,
          ),
        ),
      );
      expect(find.text('View request'), findsOneWidget);
      expect(find.text('Review request'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('W5 canReview true shows Review request for pending request',
        (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: PendingRequestCard(
            request: _request(),
            onReview: () {},
            canReview: true,
          ),
        ),
      );
      expect(find.text('Review request'), findsOneWidget);
      expect(find.text('View request'), findsNothing);
    });

    testWidgets('canReview true on approved request still shows View request',
        (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: PendingRequestCard(
            request: _request(status: 'Approved'),
            onReview: () {},
            canReview: true,
          ),
        ),
      );
      expect(find.text('View request'), findsOneWidget);
    });

    testWidgets('canReview false still opens the request on tap',
        (tester) async {
      var opened = 0;
      await _pump(
        tester,
        SingleChildScrollView(
          child: PendingRequestCard(
            request: _request(),
            onReview: () => opened++,
            canReview: false,
          ),
        ),
      );
      await tester.tap(find.text('View request'));
      expect(opened, 1);
    });
  });

  group('ReviewRequestDetailsSection decision buttons', () {
    testWidgets('W6 no callbacks hides Approve/Reject, details still shown',
        (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: ReviewRequestDetailsSection(request: _request()),
        ),
      );
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(find.text('Payment request details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('W7 callbacks set shows Approve/Reject', (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: ReviewRequestDetailsSection(
            request: _request(),
            onAccept: () {},
            onReject: () {},
          ),
        ),
      );
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });

  group('ReviewRequestScreen canReview wiring', () {
    Future<void> pumpScreen(WidgetTester tester, {required bool canReview}) async {
      final cubit = PendingRequestsCubit(
        repository: _FakePaymentRequestRepository([_json()]),
        paymentRepository: _FakeInvestorPaymentRepository(),
      );
      addTearDown(cubit.close);
      await cubit.loadRequests();

      await _pump(
        tester,
        BlocProvider<PendingRequestsCubit>.value(
          value: cubit,
          child: ReviewRequestScreen(
            requestId: '7',
            onBack: () {},
            canReview: canReview,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('canReview false hides Approve/Reject on a pending request',
        (tester) async {
      await pumpScreen(tester, canReview: false);
      expect(find.text('Payment request details'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('canReview true shows Approve/Reject on a pending request',
        (tester) async {
      await pumpScreen(tester, canReview: true);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });

  group('TerminatedInvestorsSection actions', () {
    Future<void> pumpSection(
      WidgetTester tester, {
      required bool canReview,
      String status = 'Pending',
    }) async {
      final cubit = ManageUsersCubit(
        repository: _FakeManageUsersRepository([_blockRequest(status: status)]),
      );
      addTearDown(cubit.close);

      await _pump(
        tester,
        BlocProvider<ManageUsersCubit>.value(
          value: cubit,
          child: SingleChildScrollView(
            child: TerminatedInvestorsSection(
              searchQuery: '',
              canReview: canReview,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('canReview false hides Approve/Reject for a pending item',
        (tester) async {
      await pumpSection(tester, canReview: false);
      expect(find.text('Terminated Person'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('canReview true shows Approve/Reject for a pending item',
        (tester) async {
      await pumpSection(tester, canReview: true);
      expect(find.text('Terminated Person'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('canReview true hides buttons for an already approved item',
        (tester) async {
      await pumpSection(tester, canReview: true, status: 'Approved');
      expect(find.text('Terminated Person'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
    });
  });

  group('PendingRequestsOverviewSection subtitle (G6)', () {
    testWidgets('canReview true keeps the review wording', (tester) async {
      await _pump(
        tester,
        const PendingRequestsOverviewSection(
          overview: PendingRequestsOverviewStats.empty,
          canReview: true,
        ),
      );
      expect(find.text('Review and approve investor payment requests'),
          findsOneWidget);
    });

    testWidgets('canReview false shows the view-only wording', (tester) async {
      await _pump(
        tester,
        const PendingRequestsOverviewSection(
          overview: PendingRequestsOverviewStats.empty,
          canReview: false,
        ),
      );
      expect(find.text('View investor payment requests'), findsOneWidget);
      expect(find.text('Review and approve investor payment requests'),
          findsNothing);
    });
  });
}
