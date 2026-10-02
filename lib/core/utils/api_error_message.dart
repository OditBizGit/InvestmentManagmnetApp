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
      }

      return fallback;
    }

    final text = error.toString().replaceFirst('Exception: ', '').trim();
    if (_looksLikeNetworkText(text)) return noInternet;
    return text.isNotEmpty ? text : fallback;
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
            _looksLikeNetworkText('${error.error ?? ''} ${error.message ?? ''}');
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
