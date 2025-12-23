import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() => _instance;

  LoggerService._internal();

  /// Sensitive data patterns to redact in production
  static final _sensitivePatterns = [
    RegExp(r'password["\s:=]+[^"\s,}]+', caseSensitive: false),
    RegExp(r'token["\s:=]+[^"\s,}]+', caseSensitive: false),
    RegExp(r'api[_-]?key["\s:=]+[^"\s,}]+', caseSensitive: false),
    RegExp(r'secret["\s:=]+[^"\s,}]+', caseSensitive: false),
    RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN pattern
    RegExp(r'\b\d{16}\b'), // Credit card pattern
  ];

  /// Log a debug message
  void debug(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, tag: tag, context: context, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  void info(String message, {String? tag, Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, tag: tag, context: context);
  }

  /// Log a warning message
  void warning(String message, {String? tag, Map<String, dynamic>? context, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, context: context, error: error);
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, context: context, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method with structured format
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level == LogLevel.debug) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag]' : '';

    final sanitizedMessage = kReleaseMode ? _redactSensitiveData(message) : message;
    final sanitizedContext = kReleaseMode && context != null
        ? _redactSensitiveDataFromMap(context)
        : context;

    // Build log message
    final buffer = StringBuffer();
    buffer.write('$timestamp | $levelStr | $tagStr $sanitizedMessage');

    // Add context if provided
    if (sanitizedContext != null && sanitizedContext.isNotEmpty) {
      buffer.write('\n  Context: ${sanitizedContext.toString()}');
    }

    // Add error if provided
    if (error != null) {
      buffer.write('\n  Error: ${error.toString()}');
    }

    // Add stack trace if provided
    if (stackTrace != null && kDebugMode) {
      buffer.write('\n  Stack Trace:\n${stackTrace.toString()}');
    }

    // Output to debug console
    debugPrint(buffer.toString());
  }

  /// Redact sensitive data from a string
  String _redactSensitiveData(String text) {
    var redacted = text;
    for (final pattern in _sensitivePatterns) {
      redacted = redacted.replaceAll(pattern, '[REDACTED]');
    }
    return redacted;
  }

  /// Redact sensitive data from a map
  Map<String, dynamic> _redactSensitiveDataFromMap(Map<String, dynamic> data) {
    final redacted = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();

      // Check if key contains sensitive terms
      if (key.contains('password') ||
          key.contains('token') ||
          key.contains('secret') ||
          key.contains('api_key') ||
          key.contains('apikey')) {
        redacted[entry.key] = '[REDACTED]';
      } else if (entry.value is String) {
        redacted[entry.key] = _redactSensitiveData(entry.value as String);
      } else if (entry.value is Map) {
        redacted[entry.key] = _redactSensitiveDataFromMap(entry.value as Map<String, dynamic>);
      } else {
        redacted[entry.key] = entry.value;
      }
    }

    return redacted;
  }

  /// Log state transition
  void logStateTransition(
    String fromState,
    String toState, {
    String? tag,
    Map<String, dynamic>? context,
  }) {
    info('State transition: $fromState → $toState', tag: tag ?? 'STATE', context: context);
  }

  /// Log API call
  void logApiCall(
    String method,
    String endpoint, {
    Map<String, dynamic>? parameters,
    int? statusCode,
    Duration? duration,
  }) {
    final context = <String, dynamic>{
      'method': method,
      'endpoint': endpoint,
      if (parameters != null) 'parameters': parameters,
      if (statusCode != null) 'statusCode': statusCode,
      if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    };

    if (statusCode != null && statusCode >= 400) {
      warning('API call failed', tag: 'API', context: context);
    } else {
      debug('API call', tag: 'API', context: context);
    }
  }

  /// Log user action
  void logUserAction(String action, {Map<String, dynamic>? context}) {
    info('User action: $action', tag: 'USER', context: context);
  }
}
