import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/network/log_redaction.dart';

void main() {
  test('request line has method, URI and body field names only', () {
    final line = requestLogLine(
      RequestOptions(
        path: '/x',
        method: 'POST',
        headers: {'Authorization': 'Bearer secret'},
        data: {
          'username': 'jane',
          'password': 'hunter2',
          'nested': {'newPassword': 'abc'},
        },
      ),
    );
    expect(line, contains('POST'));
    expect(line, contains('/x'));
    expect(line, contains('username'));
    expect(line, contains('password'));
    expect(line, isNot(contains('secret')));
    expect(line, isNot(contains('hunter2')));
    expect(line, isNot(contains('jane')));
    expect(line, isNot(contains('abc')));
  });

  test('response line has status, method and URI but no body', () {
    final options = RequestOptions(path: '/api/a', method: 'GET');
    final line = responseLogLine(
      Response(requestOptions: options, statusCode: 200, data: {'amount': 99}),
    );
    expect(line, contains('200'));
    expect(line, contains('GET'));
    expect(line, contains('/api/a'));
    expect(line, isNot(contains('99')));
  });

  test('error line has status and server message only', () {
    final options = RequestOptions(path: '/api/a', method: 'GET');
    final line = errorLogLine(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {'message': 'Bad input', 'balance': 12345},
        ),
      ),
    );
    expect(line, contains('400'));
    expect(line, contains('Bad input'));
    expect(line, isNot(contains('12345')));
  });
}
