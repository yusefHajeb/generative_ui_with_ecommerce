import 'package:generative_ui_with_ecommerce/core/errors/exeptions.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';

/// Failure handler class for converting exceptions to failures.
/// This class provides methods to transform different types of exceptions
/// into appropriate Failure objects for consistent error handling.
class FailureHandler {
  /// Convert an AppException to a Failure
  Failure exceptionToFailure(AppException exception) {
    // Handle specific exception types
    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is AuthenticationException) {
      return AuthenticationFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is ServerException) {
      return ServerFailure(
        exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is DatabaseException) {
      return DatabaseFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is TimeoutException) {
      return TimeoutFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is RateLimitException) {
      return RateLimitFailure(
        message: exception.message,
        retryAfter: exception.retryAfter,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is FileException) {
      return FileFailure(
        message: exception.message,
        filePath: exception.filePath,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is PermissionException) {
      return PermissionFailure(
        message: exception.message,
        permission: exception.permission,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    if (exception is CancelledException) {
      return CancelledFailure(
        message: exception.message,
        code: exception.code,
        originalError: exception.originalError,
        stackTrace: exception.stackTrace,
        userFriendlyMessage: exception.userFriendlyMessage,
        isRecoverable: exception.isRecoverable,
        recoverySuggestions: exception.recoverySuggestions,
      );
    }

    // Default to UnknownFailure for any other exception types
    return UnknownFailure(
      message: exception.message,
      code: exception.code,
      originalError: exception.originalError,
      stackTrace: exception.stackTrace,
      userFriendlyMessage: exception.userFriendlyMessage,
      isRecoverable: exception.isRecoverable,
      recoverySuggestions: exception.recoverySuggestions,
    );
  }

  /// Handle generic errors and convert to appropriate failures
  Failure handleGenericError(dynamic error, {StackTrace? stackTrace}) {
    if (error is AppException) {
      return exceptionToFailure(error);
    }

    if (error is Exception) {
      return UnknownFailure(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        isRecoverable: false,
        recoverySuggestions: const [
          'Try restarting the app',
          'Contact support if the problem persists',
        ],
      );
    }

    // Handle primitive types or other objects
    return UnknownFailure(
      message: 'An unexpected error occurred: ${error.toString()}',
      originalError: error,
      stackTrace: stackTrace,
      isRecoverable: false,
      recoverySuggestions: const ['Try restarting the app', 'Contact support with error details'],
    );
  }

  /// Create a network failure with connectivity issues
  NetworkFailure createConnectivityFailure({
    String message = 'No internet connection available',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkFailure(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      userFriendlyMessage: 'Please check your internet connection and try again',
      isRecoverable: true,
      recoverySuggestions: const [
        'Check your internet connection',
        'Enable mobile data or connect to Wi-Fi',
        'Try again in a few moments',
      ],
    );
  }

  /// Create a server failure for temporary issues
  ServerFailure createTemporaryServerFailure({
    String message = 'Server temporarily unavailable',
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerFailure(
      message,
      code: code,
      originalError: originalError,
      stackTrace: stackTrace,
      userFriendlyMessage: 'Service temporarily unavailable. Please try again later.',
      isRecoverable: true,
      recoverySuggestions: const [
        'Try again in a few minutes',
        'Check our status page for updates',
      ],
    );
  }

  /// Create an authentication failure for expired tokens
  AuthenticationFailure createTokenExpiredFailure({
    String message = 'Authentication token has expired',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AuthenticationFailure(
      message: message,
      code: 401,
      originalError: originalError,
      stackTrace: stackTrace,
      userFriendlyMessage: 'Your session has expired. Please log in again.',
      isRecoverable: true,
      recoverySuggestions: const [
        'Log in again with your credentials',
        'Check if your account is still active',
      ],
    );
  }
}
