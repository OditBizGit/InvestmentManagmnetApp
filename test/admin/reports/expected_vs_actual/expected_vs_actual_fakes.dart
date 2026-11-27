import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Dio adapter that answers from a callback and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.onRequest);

  Future<ResponseBody> Function(RequestOptions options) onRequest;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return onRequest(options);
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

Dio dioWith(FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  return dio;
}

Map<String, dynamic> monthJson({
  String month = '2024-03-01T00:00:00',
  num expected = 1000,
  int installments = 2,
  num payments = 800,
  num advance = 0,
  num refunds = 100,
  num actual = 700,
  num? rate = 70,
}) => {
  'month': month,
  'expectedAmount': expected,
  'expectedInstallments': installments,
  'actualPayments': payments,
  'advancePayments': advance,
  'refunds': refunds,
  'actualAmount': actual,
  'collectionRate': rate,
};

Map<String, dynamic> reportEnvelope({List<Map<String, dynamic>>? months}) {
  final rows = months ?? [monthJson()];
  return {
    'success': true,
    'message': 'ok',
    'data': {
      'fromMonth': '2024-03-01T00:00:00',
      'toMonth': '2024-03-01T00:00:00',
      'months': rows,
      'totals': {
        'expectedAmount': 1000,
        'expectedInstallments': 2,
        'actualPayments': 800,
        'advancePayments': 0,
        'refunds': 100,
        'actualAmount': 700,
        'collectionRate': 70,
      },
    },
  };
}

Map<String, dynamic> detailsEnvelope({List<Map<String, dynamic>>? rows}) {
  return {
    'success': true,
    'message': 'ok',
    'data': {
      'month': '2024-03-01T00:00:00',
      'rows':
          rows ??
          [
            {
              'userId': 7,
              'investorCode': 'INV007',
              'name': 'Asha Rao',
              'phoneNumber': '9999',
              'isActive': true,
              'expectedAmount': 1000,
              'expectedInstallments': 2,
              'actualPayments': 800,
              'advancePayments': 0,
              'refunds': 100,
              'actualAmount': 700,
              'collectionRate': 70,
            },
          ],
      'totals': {
        'investorCount': 1,
        'expectedAmount': 1000,
        'expectedInstallments': 2,
        'actualPayments': 800,
        'advancePayments': 0,
        'refunds': 100,
        'actualAmount': 700,
        'collectionRate': 70,
      },
    },
  };
}
