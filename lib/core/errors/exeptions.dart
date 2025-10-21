
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppException(this.message, [this.code, this.originalError, this.stackTrace])
    : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType);
    buffer.write(': $message');

    if (code != null) {
      buffer.write(' (Code: $code)');
    }

    if (originalError != null) {
      buffer.write(' (Original: $originalError)');
    }

    return buffer.toString();
  }

  /// Convert exception to a user-friendly message
  String get userFriendlyMessage => message;

  /// Check if this exception is recoverable
  bool get isRecoverable => false;

  /// Get recovery suggestions for this exception
  List<String> get recoverySuggestions => [];
}

/// Network-related exceptions
class NetworkException extends AppException {
  final bool isConnectivityIssue;

  NetworkException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.isConnectivityIssue = false,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Check your internet connection',
    'Try again in a few moments',
    if (isConnectivityIssue) 'Enable mobile data or connect to Wi-Fi',
  ];
}

/// Authentication and authorization exceptions
class AuthenticationException extends AppException {
  final bool isTokenExpired;

  AuthenticationException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.isTokenExpired = false,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    if (isTokenExpired) 'Please log in again',
    'Check your credentials',
    'Contact support if the problem persists',
  ];
}

/// Server-side exceptions
class ServerException extends AppException {
  final bool isTemporary;

  ServerException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.isTemporary = false,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => isTemporary;

  @override
  List<String> get recoverySuggestions => [
    if (isTemporary) 'Try again in a few minutes',
    'Contact support if the problem persists',
  ];
}

/// Validation exceptions for user input
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  ValidationException({
    required String message,
    this.fieldErrors = const {},
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Please check your input',
    'Ensure all required fields are filled',
    'Follow the format requirements',
  ];
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Clear app cache and try again',
    'Restart the application',
  ];
}

/// Database-related exceptions
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => false;

  @override
  List<String> get recoverySuggestions => ['Contact support', 'Try reinstalling the app'];
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Check your internet connection',
    'Try again with a better connection',
    'The server might be busy, please wait',
  ];
}

/// Rate limiting exceptions
class RateLimitException extends AppException {
  final Duration retryAfter;

  RateLimitException({
    required String message,
    required this.retryAfter,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Please wait ${retryAfter.inSeconds} seconds before trying again',
    'Reduce the frequency of your requests',
  ];
}

/// File operation exceptions
class FileException extends AppException {
  final String? filePath;

  FileException({
    required String message,
    this.filePath,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Check file permissions',
    'Ensure the file exists and is accessible',
    'Try a different file location',
  ];
}

/// Permission-related exceptions
class PermissionException extends AppException {
  final String permission;

  PermissionException({
    required String message,
    required this.permission,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => [
    'Grant $permission permission in app settings',
    'Go to Settings > Apps > ${const String.fromEnvironment('APP_NAME', defaultValue: 'App')} > Permissions',
  ];
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  UnknownException({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => false;

  @override
  List<String> get recoverySuggestions => [
    'Try restarting the app',
    'Contact support with error details',
  ];
}

/// Custom exception for cancelled operations
class CancelledException extends AppException {
  CancelledException({
    String message = 'Operation was cancelled',
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code, originalError, stackTrace);

  @override
  bool get isRecoverable => true;

  @override
  List<String> get recoverySuggestions => ['You can try the operation again'];
}
