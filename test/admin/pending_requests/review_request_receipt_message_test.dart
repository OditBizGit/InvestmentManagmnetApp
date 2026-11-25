import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/cubit/pending_requests_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/payment_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/review_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/repository/pending_request_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/review_request_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

const _receiptMessage =
    'Please wait... Sending email receipt and app receipt.';

Map<String, dynamic> _json() => {
      'requestId': 7,
      'userId': 3,
      'investorCode': 'INV-1',
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
      'phoneNumber': '9999',
      'paidAmount': 1000,
      'paymentMethod': 'Cash',
      'status': 'Pending',
    };

class _FakePaymentRequestRepository extends PaymentRequestRepository {
  _FakePaymentRequestRepository() : super(dio: Dio());

  /// One completer per review call, in call order. Tests complete them to
  /// decide when (and how) each approve/reject call returns.
  final List<Completer<AcceptOrRejectPaymentResponseModel>> reviewCalls = [];
  final List<String> reviewStatuses = [];

  @override
  Future<PaymentRequestResponseModel> getPaymentRequests({
    String status = 'All',
  }) async {
    return PaymentRequestResponseModel.fromJson({
      'status': true,
      'message': 'ok',
      'data': [_json()],
    });
  }

  @override
  Future<AcceptOrRejectPaymentResponseModel> acceptOrRejectPaymentRequest({
    required int requestId,
    required String status,
    String remarks = '',
  }) {
    final completer = Completer<AcceptOrRejectPaymentResponseModel>();
    reviewCalls.add(completer);
    reviewStatuses.add(status);
    return completer.future;
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

AcceptOrRejectPaymentResponseModel _ok(String message) =>
    AcceptOrRejectPaymentResponseModel(status: true, message: message);

/// Shows the review screen until it calls onBack, then shows a marker.
class _Host extends StatefulWidget {
  const _Host({required this.canReview});

  final bool canReview;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool _left = false;

  @override
  Widget build(BuildContext context) {
    if (_left) return const Text('left review screen');
    return ReviewRequestScreen(
      requestId: '7',
      canReview: widget.canReview,
      onBack: () => setState(() => _left = true),
    );
  }
}

class _Harness {
  _Harness(this.repo, this.cubit);

  final _FakePaymentRequestRepository repo;
  final PendingRequestsCubit cubit;
}

Future<_Harness> _pumpScreen(
  WidgetTester tester, {
  bool canReview = true,
  double width = 1200,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repo = _FakePaymentRequestRepository();
  final cubit = PendingRequestsCubit(
    repository: repo,
    paymentRepository: _FakeInvestorPaymentRepository(),
  );
  addTearDown(cubit.close);
  await cubit.loadRequests();

  await tester.pumpWidget(
    ToastificationWrapper(
      child: Sizer(
        builder: (context, orientation, screenType) => MaterialApp(
          home: Scaffold(
            body: BlocProvider<PendingRequestsCubit>.value(
              value: cubit,
              child: _Host(canReview: canReview),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(repo, cubit);
}

Finder get _spinner => find.byType(CircularProgressIndicator);
Finder get _message => find.text(_receiptMessage);
Finder get _dialog => find.byType(Dialog);

Finder _dialogButton(String label) =>
    find.descendant(of: _dialog, matching: find.text(label));

/// Taps Approve and confirms the dialog. The review call is left pending.
Future<void> _approveAndConfirm(WidgetTester tester) async {
  await tester.tap(find.text('Approve'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('Approve request?'), findsOneWidget);
  await tester.tap(_dialogButton('Approve'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Taps Reject, enters remarks and confirms. The review call is left pending.
Future<void> _rejectAndConfirm(WidgetTester tester) async {
  await tester.tap(find.text('Reject'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('Reject payment request?'), findsOneWidget);
  await tester.enterText(find.byType(TextFormField), 'Not a valid proof');
  await tester.tap(_dialogButton('Reject'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Lets toasts auto-close so no timer stays pending when the test ends.
Future<void> _drainToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(seconds: 1));
}

bool _approveEnabled(WidgetTester tester) =>
    tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Approve'),
        matching: find.byType(ElevatedButton),
      ),
    ).onPressed !=
    null;

bool _rejectEnabled(WidgetTester tester) =>
    tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Reject'),
        matching: find.byType(OutlinedButton),
      ),
    ).onPressed !=
    null;

void main() {
  group('ReviewRequestScreen approve receipt message', () {
    testWidgets('R1 approve in flight shows spinner and the exact message',
        (tester) async {
      final h = await _pumpScreen(tester);
      expect(_spinner, findsNothing);
      expect(_message, findsNothing);

      await _approveAndConfirm(tester);

      expect(h.repo.reviewCalls, hasLength(1));
      expect(h.repo.reviewStatuses.single, 'Approved');
      expect(_spinner, findsOneWidget);
      expect(_message, findsOneWidget);
      expect(tester.takeException(), isNull);

      // Finish the call so the test ends cleanly.
      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R2 success removes the message and goes back',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();

      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      expect(find.text('left review screen'), findsOneWidget);
      await _drainToasts(tester);
    });

    testWidgets('R3 DioException removes the message, shows error, re-enables',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      final options = RequestOptions(path: '/review');
      h.repo.reviewCalls.single.completeError(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Server said no'},
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      expect(find.text('Server said no'), findsOneWidget);
      expect(find.text('left review screen'), findsNothing);
      expect(_approveEnabled(tester), isTrue);
      expect(_rejectEnabled(tester), isTrue);
      await _drainToasts(tester);

      // The flag must be reset: a following Reject shows no receipt message.
      await _rejectAndConfirm(tester);
      expect(h.repo.reviewCalls, hasLength(2));
      expect(h.repo.reviewStatuses.last, 'Rejected');
      expect(_spinner, findsOneWidget);
      expect(_message, findsNothing);

      h.repo.reviewCalls.last.complete(_ok('Payment rejected'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R4 non-Dio error removes the message and resets loading',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.single.completeError(StateError('plain failure'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      expect(find.textContaining('plain failure'), findsOneWidget);
      expect(_approveEnabled(tester), isTrue);
      expect(_rejectEnabled(tester), isTrue);
      await _drainToasts(tester);

      // The flag must be reset: a following Reject shows no receipt message.
      await _rejectAndConfirm(tester);
      expect(h.repo.reviewCalls, hasLength(2));
      expect(h.repo.reviewStatuses.last, 'Rejected');
      expect(_spinner, findsOneWidget);
      expect(_message, findsNothing);

      h.repo.reviewCalls.last.complete(_ok('Payment rejected'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R5 reject keeps the spinner-only overlay', (tester) async {
      final h = await _pumpScreen(tester);

      await _rejectAndConfirm(tester);

      expect(h.repo.reviewCalls, hasLength(1));
      expect(h.repo.reviewStatuses.single, 'Rejected');
      expect(_spinner, findsOneWidget);
      expect(_message, findsNothing);
      expect(find.textContaining('Sending email receipt'), findsNothing);

      h.repo.reviewCalls.single.complete(_ok('Payment rejected'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R6 second tap while approving does not call the API again',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      await tester.tap(find.text('Approve'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Reject'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(_dialog, findsNothing);
      expect(h.repo.reviewCalls, hasLength(1));
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets(
        'R12 two confirm dialogs open: only one call, message stays until done',
        (tester) async {
      final h = await _pumpScreen(tester);

      // Two real taps cannot do this: the Navigator absorbs pointers for the
      // frame after a push, and the dialog barrier covers the button after it.
      // So the Approve callback is invoked twice with no frame in between,
      // which opens two confirm dialogs (as a double activation could).
      final approve = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Approve'),
          matching: find.byType(ElevatedButton),
        ),
      );
      approve.onPressed!();
      approve.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Approve request?'), findsNWidgets(2));

      // Confirm the top dialog: the first approve call starts.
      await tester.tap(_dialogButton('Approve').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.repo.reviewCalls, hasLength(1));
      expect(find.text('Approve request?'), findsOneWidget);
      expect(_message, findsOneWidget);

      // Confirm the second dialog: it must not start a second call and must
      // not clear the message of the call still in flight.
      await tester.tap(_dialogButton('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Approve request?'), findsNothing);
      expect(h.repo.reviewCalls, hasLength(1));
      expect(_spinner, findsOneWidget);
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();
      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      expect(find.text('left review screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _drainToasts(tester);
    });

    testWidgets('R7 cancelling the confirm dialog shows no overlay or call',
        (tester) async {
      final h = await _pumpScreen(tester);

      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Approve request?'), findsOneWidget);
      await tester.tap(_dialogButton('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(_dialog, findsNothing);
      expect(_spinner, findsNothing);
      expect(_message, findsNothing);
      expect(h.repo.reviewCalls, isEmpty);
      expect(_approveEnabled(tester), isTrue);
    });

    testWidgets('R8 message wraps on a 360 px wide screen without overflow',
        (tester) async {
      final h = await _pumpScreen(tester, width: 360);
      await _approveAndConfirm(tester);

      expect(_message, findsOneWidget);
      expect(_spinner, findsOneWidget);
      expect(tester.takeException(), isNull);

      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R9 canReview false has no Approve/Reject and no message',
        (tester) async {
      final h = await _pumpScreen(tester, canReview: false);

      expect(find.text('Payment request details'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      expect(h.repo.reviewCalls, isEmpty);
    });

    testWidgets('R10 reject after a failed approve shows no receipt message',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.first.completeError(StateError('first failed'));
      await tester.pump();
      await tester.pump();
      expect(_message, findsNothing);
      expect(_spinner, findsNothing);
      await _drainToasts(tester);

      await _rejectAndConfirm(tester);

      expect(h.repo.reviewCalls, hasLength(2));
      expect(h.repo.reviewStatuses.last, 'Rejected');
      expect(_spinner, findsOneWidget);
      expect(_message, findsNothing);

      h.repo.reviewCalls.last.complete(_ok('Payment rejected'));
      await tester.pump();
      await tester.pump();
      await _drainToasts(tester);
    });

    testWidgets('R11 success then leaving the screen throws no exception',
        (tester) async {
      final h = await _pumpScreen(tester);
      await _approveAndConfirm(tester);
      expect(_message, findsOneWidget);

      h.repo.reviewCalls.single.complete(_ok('Payment approved'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('left review screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _drainToasts(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
