import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

DioException _badResponse(Object? data, {int status = 400}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test('server message wins over ProblemDetails', () {
    expect(
      ApiErrorMessage.from(
        _badResponse({
          'message': 'Server says no',
          'title': 'Bad Request',
          'errors': {
            'a': ['First'],
          },
        }),
      ),
      'Server says no',
    );
  });

  test('ProblemDetails errors: first string of the first entry', () {
    expect(
      ApiErrorMessage.from(
        _badResponse({
          'title': 'One or more validation errors occurred.',
          'errors': {
            'month': ['The month is required.', 'Other'],
          },
        }),
      ),
      'The month is required.',
    );
  });

  test('ProblemDetails title when there are no errors', () {
    expect(
      ApiErrorMessage.from(_badResponse({'title': 'Bad Request'})),
      'Bad Request',
    );
    expect(
      ApiErrorMessage.from(
        _badResponse({'title': 'Bad Request', 'errors': <String, dynamic>{}}),
      ),
      'Bad Request',
    );
  });

  test('network error returns the no-internet text', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );
    expect(ApiErrorMessage.from(error), ApiErrorMessage.noInternet);
  });

  test('fallback when nothing usable is in the response', () {
    expect(
      ApiErrorMessage.from(_badResponse(<String, dynamic>{}, status: 500)),
      'Something went wrong. Please try again.',
    );
    expect(
      ApiErrorMessage.from(_badResponse('<html>', status: 500), fallback: 'F'),
      'F',
    );
  });
}
