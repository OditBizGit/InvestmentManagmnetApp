import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/register_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/update_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';

class _CapturingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'status': true, 'message': 'ok', 'code': 200, 'data': []}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;
  late InvestorsRepository repository;

  setUp(() {
    adapter = _CapturingAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.test',
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    )..httpClientAdapter = adapter;
    repository = InvestorsRepository(dio: dio);
  });

  test('registerInvestor raises send and receive timeouts to 180 s', () async {
    await repository.registerInvestor(
      RegisterInvestorRequestModel(
        username: 'user',
        password: 'secret1',
        fullName: 'Full Name',
        email: 'a@b.com',
        phoneNumber: '9999999999',
        alternativeNumber: '',
        investorType: 'Type',
        staffId: 1,
        organization: '',
        address: 'Somewhere',
        investmentDate: DateTime(2026, 1, 1),
        investmentSplitMonths: 12,
        investmentSplitType: 'Month',
        investmentSplitGap: 1,
        investmentAdvanceAmount: 0,
        paymentMethod: 'Cash',
        aadhaarNumber: '',
        panCardNumber: '',
        accountNumber: '',
        ifscCode: '',
        bankName: '',
      ),
    );

    final options = adapter.requests.single;
    expect(options.sendTimeout, const Duration(seconds: 180));
    expect(options.receiveTimeout, const Duration(seconds: 180));
  });

  test('updateInvestor raises send and receive timeouts to 180 s', () async {
    await repository.updateInvestor(
      UpdateInvestorRequestModel(userId: 7, fullName: 'Full Name'),
    );

    final options = adapter.requests.single;
    expect(options.sendTimeout, const Duration(seconds: 180));
    expect(options.receiveTimeout, const Duration(seconds: 180));
  });

  test('other calls keep the shared 30 s timeout', () async {
    await repository.getInvestors();

    final options = adapter.requests.single;
    expect(options.sendTimeout, const Duration(seconds: 30));
  });
}
