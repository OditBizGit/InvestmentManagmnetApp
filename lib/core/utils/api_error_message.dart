import 'dart:io';

import 'package:dio/dio.dart';

/// Shared API / network error messages for admin screens.
class ApiErrorMessage {
  ApiErrorMessage._();

  static const String noInternet =
      'No internet connection. Try after some time.';

  /// Maps [error] to a short user-facing message.
  ///
  /// Network / connectivity failures always return [noInternet].
  static String from(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is DioException) {
      if (isNetworkError(error)) return noInternet;

      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['Message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }

        final problem = _problemDetailsText(data);
        if (problem != null) return problem;
      }

      return fallback;
    }

    final text = error.toString().replaceFirst('Exception: ', '').trim();
    if (_looksLikeNetworkText(text)) return noInternet;
    return text.isNotEmpty ? text : fallback;
  }

  /// ASP.NET ProblemDetails: first string of `errors` (map of lists), then
  /// `title`.
  static String? _problemDetailsText(Map data) {
    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        final first = value is List && value.isNotEmpty ? value.first : value;
        final text = first is String ? first.trim() : '';
        if (text.isNotEmpty) return text;
      }
    }
    final title = data['title'];
    if (title is String && title.trim().isNotEmpty) return title.trim();
    return null;
  }

  static bool isNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.unknown:
        return error.error is SocketException ||
            _looksLikeNetworkText(
              '${error.error ?? ''} ${error.message ?? ''}',
            );
      default:
        return _looksLikeNetworkText(error.message ?? '');
    }
  }

  static bool _looksLikeNetworkText(String text) {
    final lower = text.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('no address associated') ||
        lower.contains('clientexception') ||
        lower.contains('xmlhttprequest error');
  }
}
