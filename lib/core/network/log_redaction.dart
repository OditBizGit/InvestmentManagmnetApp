import 'package:dio/dio.dart';

/// Debug log lines for the shared Dio interceptor.
///
/// Requests: method, URI and body field names only (no values, no headers).
/// Responses and errors: method, URI, status and, for errors, the server
/// `message` only. Bodies are never logged.

String requestLogLine(RequestOptions options) =>
    '→ ${options.method} ${options.uri}'
    '${_fieldNames(options.data)}';

String responseLogLine(Response<dynamic> response) =>
    '← ${response.statusCode} ${response.requestOptions.method} '
    '${response.requestOptions.uri}';

String errorLogLine(DioException error) {
  final data = error.response?.data;
  final message = data is Map ? data['message'] : null;
  return '✖ ${error.response?.statusCode ?? 'NO_STATUS'} '
      '${error.requestOptions.method} ${error.requestOptions.uri}'
      '${message is String && message.isNotEmpty ? '\n  message: $message' : ''}';
}

/// ` body: [a, b]` listing field names only, or empty when there is no body.
String _fieldNames(Object? data) {
  final names = switch (data) {
    Map() => data.keys.map((k) => k.toString()).toList(),
    FormData() => [
        ...data.fields.map((f) => f.key),
        ...data.files.map((f) => f.key),
      ],
    _ => null,
  };
  return names == null ? '' : '\n  body fields: $names';
}
