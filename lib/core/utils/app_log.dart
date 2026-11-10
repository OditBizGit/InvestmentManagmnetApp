import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Test seam: replaces the developer-log sink.
@visibleForTesting
void Function(
  String message, {
  String? name,
  Object? error,
  StackTrace? stackTrace,
})? appLogSinkOverride;

/// Test seam: forces the debug-mode check.
@visibleForTesting
bool? appLogEnabledOverride;

/// Debug-only logger. A no-op in profile/release builds.
///
/// Never pass response bodies, request payloads, tokens or passwords.
void appLog(
  String message, {
  String? name,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!(appLogEnabledOverride ?? kDebugMode)) return;
  final sink = appLogSinkOverride;
  if (sink != null) {
    sink(message, name: name, error: error, stackTrace: stackTrace);
    return;
  }
  developer.log(
    message,
    name: name ?? '',
    error: error,
    stackTrace: stackTrace,
  );
}
