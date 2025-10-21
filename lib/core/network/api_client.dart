import 'dart:io';

import 'package:dio/dio.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exeptions.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exception_handler.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_info.dart';

/// HTTP Methods enum
enum HttpMethod { get, post, put, delete, patch }

/// API Client class for handling all HTTP requests with safe API calls
class ApiClient {
  final Dio dio;
  final NetworkInfo networkInfo;
  final ExceptionHandler exceptionHandler;

  ApiClient({required this.dio, required this.networkInfo, required this.exceptionHandler});

  /// Safe API call with comprehensive error handling
  Future<Response> safeApiCall<T>({
    required HttpMethod httpMethod,
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    // Check connectivity first
    await _checkConnectivity();

    // Execute API call
    return await _executeApiCall<T>(
      httpMethod: httpMethod,
      endPoint: endPoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }
  }

  /// Execute the actual API call
  Future<Response> _executeApiCall<T>({
    required HttpMethod httpMethod,
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _performRequest(
        httpMethod: httpMethod,
        endPoint: endPoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response;
      }

      // Handle error status codes
      throw UnknownException(message: 'HTTP ${response.statusCode}: ${response.statusMessage}');
    } on DioException catch (dioException) {
      throw exceptionHandler.handleDioError(dioException);
    } catch (e) {
      throw exceptionHandler.handleUnexpectedError('Unexpected error: $e');
    }
  }

  /// Perform the actual HTTP request based on method
  Future<Response> _performRequest({
    required HttpMethod httpMethod,
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    switch (httpMethod) {
      case HttpMethod.get:
        return dio.get(
          endPoint,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.post:
        return dio.post(
          endPoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      case HttpMethod.put:
        return dio.put(
          endPoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      case HttpMethod.delete:
        return dio.delete(
          endPoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.patch:
        return dio.patch(
          endPoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
    }
  }

  // Legacy methods for backward compatibility
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final result = await safeApiCall(
      httpMethod: HttpMethod.get,
      endPoint: path,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final result = await safeApiCall(
      httpMethod: HttpMethod.post,
      endPoint: path,
      data: data,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final result = await safeApiCall(
      httpMethod: HttpMethod.put,
      endPoint: path,
      data: data,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    final result = await safeApiCall(
      httpMethod: HttpMethod.delete,
      endPoint: path,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<dynamic> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final result = await safeApiCall(
      httpMethod: HttpMethod.patch,
      endPoint: path,
      data: data,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<dynamic> uploadFile(String path, File file, {String fieldName = 'file'}) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    final result = await safeApiCall(httpMethod: HttpMethod.post, endPoint: path, data: formData);
    return result;
  }
}
