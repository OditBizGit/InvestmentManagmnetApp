import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Returns the full text of every `log(`, `_log(`, `appLog(`, `debugPrint(` or
/// `print(` call in [source] (parentheses balanced, multi-line aware).
List<String> logCalls(String source) {
  final starts = RegExp(r'(?<![\w.])(?:log|_log|appLog|debugPrint|print)\(');
  final calls = <String>[];
  for (final m in starts.allMatches(source)) {
    var depth = 1;
    var i = m.end;
    while (i < source.length && depth > 0) {
      final c = source[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      i++;
    }
    calls.add(source.substring(m.start, i));
  }
  return calls;
}

/// Sensitive content that must never be logged: response bodies (a bare
/// `response.data` / `e.response?.data`, not `.data.length` etc.), request
/// payloads, auth headers and passwords.
final RegExp sensitive = RegExp(
  r'response\??\.data(?![\w.])'
  r'|\.toJson\(\)'
  r'|\bAuthorization\b'
  r'|password'
  r'|aadhaar'
  r'|\bpan\b'
  r'|\.fields(?![\w.])'
  r'|imageUrl',
  caseSensitive: false,
);

/// `debugPrint` / `print` calls that are not inside a `kDebugMode` guard
/// (looked up in the 250 characters before the call).
List<String> ungatedPrints(String source) {
  final starts = RegExp(r'(?<![\w.])(?:debugPrint|print)\(');
  final found = <String>[];
  for (final m in starts.allMatches(source)) {
    final from = m.start > 250 ? m.start - 250 : 0;
    if (!source.substring(from, m.start).contains('kDebugMode')) {
      found.add(source.substring(m.start, (m.start + 60).clamp(0, source.length)));
    }
  }
  return found;
}

/// Raw `dart:developer` `log(` calls (use `appLog` instead).
final RegExp rawLog = RegExp(r'(?<![\w.])log\(');

void main() {
  group('new rules self-test', () {
    test('ungated debugPrint/print flagged, gated allowed', () {
      expect(ungatedPrints("debugPrint('x');"), isNotEmpty);
      expect(ungatedPrints("print('x');"), isNotEmpty);
      expect(
        ungatedPrints("if (kDebugMode) {\n debugPrint('x');\n}"),
        isEmpty,
      );
      expect(ungatedPrints("if (kDebugMode) debugPrint('x');"), isEmpty);
      expect(ungatedPrints("appLog('x');"), isEmpty);
    });

    test('raw log() flagged, appLog/_log not', () {
      expect(rawLog.hasMatch("log('x');"), isTrue);
      expect(rawLog.hasMatch("appLog('x');"), isFalse);
      expect(rawLog.hasMatch("_log('x');"), isFalse);
      expect(rawLog.hasMatch("math.log(2)"), isFalse);
    });

    test('aadhaar, pan and imageUrl in logs are flagged', () {
      for (final s in [
        "appLog('aadhaar=\$a');",
        "appLog('pan=\$p');",
        "debugPrint('url \$imageUrl');",
      ]) {
        expect(logCalls(s).any(sensitive.hasMatch), isTrue, reason: s);
      }
      expect(logCalls("appLog('f \${formData.fields}');").any(sensitive.hasMatch), isTrue);
      expect(logCalls("appLog('k \${formData.fields.map((f) => f.key)}');").any(sensitive.hasMatch), isFalse);
      expect(logCalls("appLog('Expand panel');").any(sensitive.hasMatch), isFalse);
    });
  });

  group('scanner', () {
    test('flags response bodies, payloads, auth and passwords', () {
      for (final s in [
        "log('r: \${response.data}');",
        "log('r: \${e.response?.data}');",
        "log('r: \${e.response?.data ?? e.message}');",
        "log(\n  'Request: \${request.toJson()}',\n);",
        "debugPrint('h: \${headers['Authorization']}');",
        "print('pw \$password');",
      ]) {
        expect(logCalls(s).any(sensitive.hasMatch), isTrue, reason: s);
      }
    });

    test('ignores harmless logs', () {
      for (final s in [
        "log('status \${response.statusCode}');",
        "log('type \${response.data.runtimeType}');",
        "log('count \${result.data.length}');",
        "debugPrint('tapped \${message.data['type']}');",
        "final x = response.data;",
      ]) {
        expect(logCalls(s).any(sensitive.hasMatch), isFalse, reason: s);
      }
    });
  });

  test('no log call in lib/ prints bodies, payloads, auth or passwords', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final source = f.readAsStringSync();
      for (final call in logCalls(source)) {
        if (sensitive.hasMatch(call)) {
          offenders.add('${f.path}: ${call.replaceAll(RegExp(r'\s+'), ' ')}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.take(10).join('\n'));
  });

  test('lib/ has no ungated print/debugPrint and no raw dart:developer log()',
      () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.replaceAll(r'\', '/').endsWith('core/utils/app_log.dart')) {
        continue;
      }
      final source = f.readAsStringSync();
      for (final p in ungatedPrints(source)) {
        offenders.add('${f.path}: ungated $p');
      }
      if (rawLog.hasMatch(source)) offenders.add('${f.path}: raw log()');
    }
    expect(offenders, isEmpty, reason: offenders.take(10).join('\n'));
  });
}
