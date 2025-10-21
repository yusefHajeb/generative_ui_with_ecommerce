import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authentication interceptor for handling JWT tokens and automatic refresh
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding token for auth endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get token from secure storage
    final token = await _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshSuccess = await _refreshToken(err.requestOptions);

      if (refreshSuccess) {
        // Retry the original request with new token
        try {
          final clonedRequest = await _retryRequest(err.requestOptions);
          return handler.resolve(clonedRequest);
        } catch (e) {
          // If retry fails, proceed with original error
        }
      } else {
        // Refresh failed, clear tokens and redirect to login
        await _clearTokens();
        // You might want to emit a logout event here
      }
    }

    super.onError(err, handler);
  }

  /// Check if the endpoint is an authentication endpoint
  bool _isAuthEndpoint(String path) {
    const authEndpoints = ['/auth/login', '/auth/register', '/auth/refresh'];
    return authEndpoints.any((endpoint) => path.contains(endpoint));
  }

  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      log('Error reading token: $e');
      return null;
    }
  }

  Future<String?> _getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      log('Error reading refresh token: $e');
      return null;
    }
  }

  /// Store auth token in secure storage
  Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      log('Error storing token: $e');
    }
  }

  /// Store refresh token in secure storage
  Future<void> storeRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      log('Error storing refresh token: $e');
    }
  }

  /// Store both tokens
  Future<void> storeTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([storeToken(accessToken), storeRefreshToken(refreshToken)]);
  }

  /// Clear all tokens
  Future<void> _clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);
    } catch (e) {
      log('Error clearing tokens: $e');
    }
  }

  /// Refresh the access token using refresh token
  Future<bool> _refreshToken(RequestOptions originalRequest) async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio();
      dio.options.baseUrl = originalRequest.baseUrl;

      final response = await dio.post('/auth/refresh', data: {'refresh_token': refreshToken});

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await storeToken(newAccessToken);
          if (newRefreshToken != null) {
            await storeRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      log('Error refreshing token: $e');
    }
    return false;
  }

  /// Retry the original request with new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final token = await _getToken();
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: requestOptions.baseUrl,
      connectTimeout: requestOptions.connectTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    );

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user by clearing all tokens
  Future<void> logout() async {
    await _clearTokens();
  }
}



/// Retry interceptor for failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;

  RetryInterceptor({this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Don't retry on auth errors or client errors
    if (err.response?.statusCode == 401 ||
        err.response?.statusCode == 403 ||
        (err.response?.statusCode ?? 0) >= 400 && (err.response?.statusCode ?? 0) < 500) {
      return super.onError(err, handler);
    }

    // Retry logic for network errors or server errors
    if (_shouldRetry(err)) {
      for (int i = 0; i < maxRetries; i++) {
        try {
          log('Retrying request (${i + 1}/$maxRetries): ${err.requestOptions.path}');

          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: i + 1));

          final dio = Dio();
          dio.options = BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: err.requestOptions.connectTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
          );

          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
              responseType: err.requestOptions.responseType,
              contentType: err.requestOptions.contentType,
            ),
          );

          return handler.resolve(response);
        } catch (retryError) {
          if (i == maxRetries - 1) {
            // Last retry failed, continue with original error
            break;
          }
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}

/// Cache interceptor for GET requests
class CacheInterceptor extends Interceptor {
  final Map<String, Response> _cache = {};
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'GET') {
      final cacheKey = _generateCacheKey(options);
      final cachedResponse = _cache[cacheKey];

      if (cachedResponse != null) {
        final cacheTime = cachedResponse.extra['cache_time'] as DateTime?;
        if (cacheTime != null && DateTime.now().difference(cacheTime) < cacheDuration) {
          log('📋 Using cached response for: ${options.path}');
          return handler.resolve(cachedResponse);
        } else {
          _cache.remove(cacheKey);
        }
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET') {
      final cacheKey = _generateCacheKey(response.requestOptions);
      response.extra['cache_time'] = DateTime.now();
      _cache[cacheKey] = response;
    }

    super.onResponse(response, handler);
  }

  String _generateCacheKey(RequestOptions options) {
    final queryString = options.queryParameters.isNotEmpty
        ? '?${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    return '${options.method}:${options.path}$queryString';
  }

  /// Clear all cached responses
  void clearCache() {
    _cache.clear();
  }

  /// Remove specific cached response
  void removeCache(String path, {Map<String, dynamic>? queryParameters}) {
    final options = RequestOptions(path: path, queryParameters: queryParameters ?? {});
    final cacheKey = _generateCacheKey(options);
    _cache.remove(cacheKey);
  }
}
