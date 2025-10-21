import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exception_handler.dart';
import 'package:generative_ui_with_ecommerce/core/network/interceptors.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_info.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Factory class for creating configured Dio instances
class DioClientFactory {
  static const String _baseUrl = 'https://api.example.com'; // Replace with your API base URL

  static Dio createDio({
    String? baseUrl,
    bool enableLogging = true,
    bool enableAuth = true,
    bool enableRetry = true,
    bool enableCache = true,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      if (enableAuth) AuthInterceptor(),
      if (enableLogging)
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: false,
          ),
        ),
      if (enableRetry) RetryInterceptor(),
      if (enableCache) CacheInterceptor(),
    ]);

    return dio;
  }

  static ApiClient createApiClient({
    String? baseUrl,
    bool enableLogging = true,
    bool enableAuth = true,
    bool enableRetry = true,
    bool enableCache = true,
  }) {
    final dio = createDio(
      baseUrl: baseUrl,
      enableLogging: enableLogging,
      enableAuth: enableAuth,
      enableRetry: enableRetry,
      enableCache: enableCache,
    );

    final connectivity = Connectivity();
    final networkInfo = NetworkInfoImpl(connectivity);

    return ApiClient(dio: dio, networkInfo: networkInfo, exceptionHandler: ExceptionHandler());
  }

  /// Create a Dio instance for file uploads (with larger timeouts)
  static Dio createUploadDio({String? baseUrl}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'multipart/form-data', 'Accept': 'application/json'},
      ),
    )..interceptors.addAll([
       AuthInterceptor(),
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: false,
          ),
        ),
       RetryInterceptor(),
      CacheInterceptor(),
    ]);
  }

  /// Create a Dio instance for large downloads
  static Dio createDownloadDio({String? baseUrl}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 300), // 5 minutes for downloads
        sendTimeout: const Duration(seconds: 60),
      ),
    )..interceptors.addAll([AuthInterceptor(), TalkerDioLogger()]);
  }
}
