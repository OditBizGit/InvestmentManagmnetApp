import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

/// Builds a full media URL from an absolute or relative API path.
String? resolveMediaUrl(String? path) {
  if (path == null) return null;

  var value = path.trim();
  if (value.isEmpty) return null;

  // Normalize Windows-style separators from some .NET APIs.
  value = value.replaceAll('\\', '/');

  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('data:')) {
    return value;
  }

  // Strip leading ~/ if present.
  if (value.startsWith('~/')) {
    value = value.substring(2);
  }

  final base = kBaseUrl.endsWith('/')
      ? kBaseUrl.substring(0, kBaseUrl.length - 1)
      : kBaseUrl;
  final relative = value.startsWith('/') ? value : '/$value';
  return '$base$relative';
}
