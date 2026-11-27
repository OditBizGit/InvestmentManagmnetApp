import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/model/refund_termination_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/repository/refund_termination_repository.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/fakes.dart';

/// Repository fake: records the (from, to) dates and answers from [handler].
class FakeRefundTerminationRepository extends RefundTerminationRepository {
  FakeRefundTerminationRepository(this.handler) : super(Dio());

  final Future<RefundTerminationReportModel> Function() handler;
  final List<(DateTime, DateTime)> calls = [];

  @override
  Future<RefundTerminationReportModel> getReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    calls.add((fromDate, toDate));
    return handler();
  }
}

/// Dio adapter that answers from [handler] and records each request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  /// When set, responses wait until it completes (to observe loading).
  Completer<void>? gate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await gate?.future;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> refundEnvelope({
  List<Map<String, dynamic>> refunds = const [],
  List<Map<String, dynamic>> terminated = const [],
}) {
  return {
    'success': true,
    'message': 'ok',
    'data': {
      'refunds': refunds,
      'terminated': terminated,
      'totals': {
        'refundCount': refunds.length,
        'refundAmount': 7000,
        'terminatedCount': terminated.length,
        'totalPaid': 90000,
        'totalRefunded': 8000,
        'remainingRefundable': 5500,
      },
    },
  };
}

Map<String, dynamic> refundRow({
  required String code,
  required String name,
  num amount = 2500,
  String method = 'Bank Transfer',
  String remarks = 'Refund remark',
}) {
  return {
    'refundId': 1,
    'requestId': 2,
    'userId': 3,
    'investorCode': code,
    'name': name,
    'refundDate': '2026-11-10T00:00:00',
    'refundAmount': amount,
    'paymentMethod': method,
    'remarks': remarks,
  };
}

Map<String, dynamic> terminatedRow({
  required String code,
  required String name,
  String dateSource = 'BlockRequest',
}) {
  return {
    'userId': 5,
    'investorCode': code,
    'name': name,
    'terminatedDate': '2026-11-05T00:00:00',
    'dateSource': dateSource,
    'totalPayable': 100000,
    'totalPaid': 40000,
    'totalRefunded': 8000,
    'pendingRefundRequests': 1500,
    'remainingRefundable': 30500,
  };
}

/// Registers a [Dio] backed by [adapter] and a [LocalStorage] in get_it.
Future<void> registerDeps(FakeAdapter adapter) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorage.init(secureStorage: FakeSecureStorage());
  final getIt = GetIt.instance;
  await getIt.reset();
  getIt.registerSingleton<LocalStorage>(storage);
  getIt.registerSingleton<Dio>(Dio()..httpClientAdapter = adapter);
  addTearDown(getIt.reset);
}

Widget sizerApp(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) =>
        MaterialApp(home: Scaffold(body: child)),
  );
}

void useWideView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1600, 3000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
