import 'dart:io';

import 'package:dio/dio.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exeptions.dart';

/// Exception handler class for processing and transforming network errors.
/// This class provides methods to convert Dio errors and other exceptions
/// into appropriate AppException objects for consistent error handling.
class ExceptionHandler {
  /// Singleton instance
  static final ExceptionHandler _instance = ExceptionHandler._internal();

  factory ExceptionHandler() => _instance;

  ExceptionHandler._internal();

  /// Handle Dio specific errors and convert to AppException
  AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Connection timeout. Please check your internet connection and try again.',
          code: error.response?.statusCode,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response);

      case DioExceptionType.cancel:
        return CancelledException(
          message: 'Request was cancelled',
          code: error.response?.statusCode,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return _handleNetworkError(error);
        }
        return UnknownException(
          message: 'Network error occurred. Please try again.',
          code: error.response?.statusCode,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      default:
        return UnknownException(
          message: 'An unexpected network error occurred',
          code: error.response?.statusCode,
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Handle HTTP error responses from server
  AppException _handleHttpError(Response? response) {
    if (response == null) {
      return ServerException(message: 'Unknown server error occurred', isTemporary: false);
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = _extractErrorMessage(data);

    // Handle specific status codes with user-friendly messages
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: 'Invalid request: ${message.isNotEmpty ? message : 'Please check your input'}',
          code: statusCode,
          originalError: response,
        );

      case 401:
        return AuthenticationException(
          message: 'Authentication failed: ${message.isNotEmpty ? message : 'Please log in again'}',
          code: statusCode,
          originalError: response,
          isTokenExpired: true,
        );

      case 403:
        return AuthenticationException(
          message: 'Access denied: ${message.isNotEmpty ? message : 'You do not have permission'}',
          code: statusCode,
          originalError: response,
        );

      case 404:
        return ServerException(
          message:
              'Resource not found: ${message.isNotEmpty ? message : 'The requested item was not found'}',
          code: statusCode,
          originalError: response,
          isTemporary: false,
        );

      case 409:
        return ValidationException(
          message:
              'Conflict: ${message.isNotEmpty ? message : 'There was a conflict with your request'}',
          code: statusCode,
          originalError: response,
        );

      case 422:
        return ValidationException(
          message:
              'Validation failed: ${message.isNotEmpty ? message : 'Please check your input data'}',
          code: statusCode,
          originalError: response,
        );

      case 429:
        return RateLimitException(
          message:
              'Too many requests: ${message.isNotEmpty ? message : 'Please wait and try again'}',
          retryAfter: const Duration(seconds: 60), // Default retry after
          code: statusCode,
          originalError: response,
        );

      case 500:
        return ServerException(
          message:
              'Server error: ${message.isNotEmpty ? message : 'Something went wrong on our end'}',
          code: statusCode,
          originalError: response,
          isTemporary: true,
        );

      case 502:
      case 503:
      case 504:
        return ServerException(
          message:
              'Service temporarily unavailable: ${message.isNotEmpty ? message : 'Please try again later'}',
          code: statusCode,
          originalError: response,
          isTemporary: true,
        );

      default:
        return ServerException(
          message: message.isNotEmpty ? message : 'An error occurred (${statusCode})',
          code: statusCode,
          originalError: response,
          isTemporary: statusCode >= 500,
        );
    }
  }

  /// Handle network connectivity errors
  AppException _handleNetworkError(DioException error) {
    return NetworkException(
      message: 'No internet connection. Please check your network settings and try again.',
      code: 0,
      originalError: error,
      stackTrace: error.stackTrace,
      isConnectivityIssue: true,
    );
  }

  /// Handle unexpected errors
  AppException handleUnexpectedError(Object error, {StackTrace? stackTrace}) {
    return UnknownException(
      message: 'An unexpected error occurred: ${error.toString()}',
      code: 0,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle cache-related errors
  AppException handleCacheError(Object error, {StackTrace? stackTrace}) {
    return CacheException(
      message: 'Cache operation failed: ${error.toString()}',
      code: 0,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle database-related errors
  AppException handleDatabaseError(Object error, {StackTrace? stackTrace}) {
    return DatabaseException(
      message: 'Database operation failed: ${error.toString()}',
      code: 0,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle file operation errors
  AppException handleFileError(Object error, {String? filePath, StackTrace? stackTrace}) {
    return FileException(
      message: 'File operation failed: ${error.toString()}',
      filePath: filePath,
      code: 0,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle permission-related errors
  AppException handlePermissionError(String permission, {Object? error, StackTrace? stackTrace}) {
    return PermissionException(
      message: 'Permission denied for $permission',
      permission: permission,
      code: 0,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Extract error message from various response formats
  String _extractErrorMessage(dynamic data) {
    if (data == null) return '';

    try {
      if (data is Map<String, dynamic>) {
        // Try common error message keys
        final possibleKeys = ['message', 'error', 'detail', 'msg', 'description'];

        for (final key in possibleKeys) {
          if (data.containsKey(key) && data[key] != null) {
            final message = data[key].toString().trim();
            if (message.isNotEmpty) {
              return message;
            }
          }
        }

        // Check for nested errors
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          } else if (firstError is String) {
            return firstError;
          }
        }

        // Check for validation errors
        if (data.containsKey('validation_errors') && data['validation_errors'] is Map) {
          final validationErrors = data['validation_errors'] as Map;
          final firstField = validationErrors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            return firstField.first.toString();
          }
        }
      } else if (data is String) {
        return data.trim();
      } else if (data is List && data.isNotEmpty) {
        return data.first.toString();
      }
    } catch (e) {
      // If parsing fails, return empty string
      return '';
    }

    return '';
  }
}
