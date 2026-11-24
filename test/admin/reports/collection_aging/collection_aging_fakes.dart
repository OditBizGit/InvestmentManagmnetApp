import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/model/collection_aging_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/repository/collection_aging_repository.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/fakes.dart';

/// Repository fake: records the as-of dates and answers from [handler].
class FakeCollectionAgingRepository extends CollectionAgingRepository {
  FakeCollectionAgingRepository(this.handler) : super(Dio());

  final Future<CollectionAgingReportModel> Function(DateTime asOf) handler;
  final List<DateTime> calls = [];

  @override
  Future<CollectionAgingReportModel> getReport({required DateTime asOfDate}) {
    calls.add(asOfDate);
    return handler(asOfDate);
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

Map<String, dynamic> agingEnvelope({
  List<Map<String, dynamic>> rows = const [],
  Map<String, dynamic>? totals,
}) {
  return {
    'success': true,
    'message': 'ok',
    'data': {
      'asOfDate': '2026-11-23T00:00:00',
      'rows': rows,
      'totals':
          totals ??
          {
            'investorCount': rows.length,
            'notYetDue': 500,
            'days1To30': 1000,
            'days31To60': 2000,
            'days61To90': 3000,
            'days90Plus': 4000,
            'totalOverdue': 10000,
            'outstanding': 10500,
          },
    },
  };
}

Map<String, dynamic> agingRow({
  required String code,
  required String name,
  String phone = '9000000000',
  bool isActive = true,
  num outstanding = 1000,
  num notYetDue = 0,
  num d1 = 1000,
}) {
  return {
    'userId': code.hashCode,
    'investorCode': code,
    'name': name,
    'phoneNumber': phone,
    'isActive': isActive,
    'totalPayable': 5000,
    'amountPaid': 4000,
    'outstanding': outstanding,
    'notYetDue': notYetDue,
    'days1To30': d1,
    'days31To60': 0,
    'days61To90': 0,
    'days90Plus': 0,
    'totalOverdue': d1,
    'oldestDueDate': '2026-11-01T00:00:00',
    'maxDaysPastDue': 22,
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
  tester.view.physicalSize = const Size(1600, 2400);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
