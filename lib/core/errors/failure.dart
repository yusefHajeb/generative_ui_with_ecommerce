/// Base failure class for the application.
/// All failures should extend this class to ensure consistent error handling.
abstract class Failure {
  final String message;
  final int? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final String? userFriendlyMessage;
  final bool isRecoverable;
  final List<String> recoverySuggestions;

  Failure({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.userFriendlyMessage,
    this.isRecoverable = false,
    this.recoverySuggestions = const [],
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType);
    buffer.write(': $message');

    if (code != null) {
      buffer.write(' (Code: $code)');
    }

    return buffer.toString();
  }

  /// Get a user-friendly message for UI display
  String get displayMessage => userFriendlyMessage ?? message;

  /// Check if this failure can be retried
  bool get canRetry => isRecoverable;

  /// Get suggestions for how to recover from this failure
  List<String> get suggestions => recoverySuggestions;
}

/// Network-related failures
class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
    String? userFriendlyMessage,
    bool isRecoverable = true,
    List<String> recoverySuggestions = const [
      'Check your internet connection',
      'Try again in a few moments',
    ],
  }) : super(
         message: message,
         code: code,
         originalError: originalError,
         stackTrace: stackTrace,
         userFriendlyMessage: userFriendlyMessage,
         isRecoverable: isRecoverable,
         recoverySuggestions: recoverySuggestions,
       );
}

/// Server-side failures
class ServerFailure extends Failure {
  ServerFailure(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable,
    super.recoverySuggestions = const [
      'Try again later',
      'Contact support if the problem persists',
    ],
  }) : super(message: message);
}

/// Authentication and authorization failures
class AuthenticationFailure extends Failure {
  AuthenticationFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    super.recoverySuggestions = const ['Please log in again', 'Check your credentials'],
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  CacheFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    super.recoverySuggestions = const ['Clear app cache and try again', 'Restart the application'],
  });
}

/// Database-related failures
class DatabaseFailure extends Failure {
  DatabaseFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable,
    super.recoverySuggestions = const ['Contact support', 'Try reinstalling the app'],
  });
}

/// Validation failures for user input
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    super.recoverySuggestions = const [
      'Please check your input',
      'Ensure all required fields are filled',
    ],
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  TimeoutFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    super.recoverySuggestions = const [
      'Check your internet connection',
      'Try again with a better connection',
    ],
  });
}

/// Rate limiting failures
class RateLimitFailure extends Failure {
  final Duration retryAfter;

  RateLimitFailure({
    required super.message,
    required this.retryAfter,
    super.code,
    super.originalError,
    super.stackTrace,
    String? userFriendlyMessage,
    super.isRecoverable = true,
    List<String> recoverySuggestions = const [],
  }) : super(
         userFriendlyMessage:
             userFriendlyMessage ??
             'Please wait ${retryAfter.inSeconds} seconds before trying again',
         recoverySuggestions: [
           ...recoverySuggestions,
           'Please wait ${retryAfter.inSeconds} seconds before trying again',
           'Reduce the frequency of your requests',
         ],
       );
}

/// File operation failures
class FileFailure extends Failure {
  final String? filePath;

  FileFailure({
    required super.message,
    this.filePath,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    super.recoverySuggestions = const [
      'Check file permissions',
      'Ensure the file exists and is accessible',
    ],
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  final String permission;

  PermissionFailure({
    required super.message,
    required this.permission,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable = true,
    List<String> recoverySuggestions = const [],
  }) : super(
         recoverySuggestions: [
           ...recoverySuggestions,
           'Grant $permission permission in app settings',
           'Go to Settings > Apps > App > Permissions',
         ],
       );
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  UnknownFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.userFriendlyMessage,
    super.isRecoverable,
    super.recoverySuggestions = const [
      'Try restarting the app',
      'Contact support with error details',
    ],
  });
}

/// Custom failure for cancelled operations
class CancelledFailure extends Failure {
  CancelledFailure({
    String message = 'Operation was cancelled',
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
    String? userFriendlyMessage,
    bool isRecoverable = true,
    List<String> recoverySuggestions = const ['You can try the operation again'],
  }) : super(
         message: message,
         code: code,
         originalError: originalError,
         stackTrace: stackTrace,
         userFriendlyMessage: userFriendlyMessage,
         isRecoverable: isRecoverable,
         recoverySuggestions: recoverySuggestions,
       );
}
