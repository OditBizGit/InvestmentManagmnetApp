import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/model/investor_statement_model.dart';

/// Dio adapter that answers from a callback and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.onRequest);

  Future<ResponseBody> Function(RequestOptions options) onRequest;
  final List<RequestOptions> requests = [];

  Iterable<RequestOptions> get statementRequests =>
      requests.where((r) => r.path.contains('/api/Report/InvestorStatement/'));

  Iterable<RequestOptions> get investorRequests =>
      requests.where((r) => r.path.endsWith('/api/Investor/GetInvestors'));

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

Map<String, dynamic> investorsEnvelope() => {
  'status': true,
  'message': 'ok',
  'data': [
    {
      'userId': 7,
      'fullName': 'Asha Rao',
      'investorCode': 'INV007',
      'isActive': true,
      'userRole': 'Investor',
    },
    {
      'userId': 8,
      'fullName': 'Ravi Kumar',
      'investorCode': 'INV008',
      'isActive': true,
      'userRole': 'Investor',
    },
  ],
};

Map<String, dynamic> statementEnvelope({
  List<Map<String, dynamic>>? ledger,
  List<Map<String, dynamic>>? schedule,
  bool omitLists = false,
}) {
  return {
    'success': true,
    'message': 'ok',
    'data': {
      'header': {
        'userId': 7,
        'investorCode': 'INV007',
        'name': 'Asha Rao',
        'phoneNumber': '9999',
        'email': 'asha@example.com',
        'isActive': true,
        'investmentStartDate': '2025-01-01T00:00:00',
        'commitmentAmount': 120000,
        'grossPaid': 50000.5,
        'refunds': 0,
        'netPaid': 50000.5,
        'discount': 1000,
        'pending': 69000,
        'isSettled': false,
        'settlementAmount': 0,
        'settlementDate': null,
        'openingBalance': 0,
        'closingBalance': 69999.5,
        'fromDate': null,
        'toDate': null,
      },
      if (!omitLists) ...{
        'ledger':
            ledger ??
            [
              {
                'lineNo': 1,
                'entryDate': '2025-01-01T00:00:00',
                'entryType': 'Investment',
                'reference': 'INV-1',
                'description': 'Investment commitment',
                'paymentMethod': '',
                'verificationStatus': 'Approved',
                'chargeAmount': 120000,
                'paymentAmount': 0,
                'runningBalance': 120000,
              },
              {
                'lineNo': 2,
                'entryDate': '2025-02-01T00:00:00',
                'entryType': 'Payment',
                'reference': 'PAY-9',
                'description': 'Installment 1',
                'paymentMethod': 'UPI',
                'verificationStatus': 'Pending',
                'chargeAmount': 0,
                'paymentAmount': 50000.5,
                'runningBalance': 69999.5,
              },
            ],
        'schedule':
            schedule ??
            [
              {
                'installmentNo': 1,
                'dueDate': '2025-02-01T00:00:00',
                'amount': 60000,
                'paidAmount': 50000.5,
                'pendingAmount': 9999.5,
                'status': 'Partially Completed',
                'daysOverdue': 12,
              },
            ],
      },
    },
  };
}

InvestorStatement parsedStatement({
  List<Map<String, dynamic>>? ledger,
  List<Map<String, dynamic>>? schedule,
}) => InvestorStatementResponseModel.fromJson(
  statementEnvelope(ledger: ledger, schedule: schedule),
).data;
