import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exception_handler.dart';
import 'package:generative_ui_with_ecommerce/core/errors/exeptions.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

/// Abstract base class for network services that handle API requests.
/// This class provides common methods for handling different types of API responses.
/// Services that extend this class should inject an ApiClient instance.
abstract class NetworkService {
  final ApiClient apiClient;

  NetworkService(this.apiClient);

  /// Handles API requests that return a single BaseModel instance.
  /// Returns Either<Failure, T> where T extends BaseModel.
  Future<Either<Failure, T>> handleBaseModelApiRequests<T extends BaseModel>({
    required HttpMethod httpMethod,
    required String endPoint,
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await apiClient.safeApiCall(
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
        final model = fromJson(response.data);
        return Right(model);
      } else {
        return Left(ServerFailure('HTTP ${response.statusCode}: ${response.statusMessage}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Handles API requests that return a list of BaseModel instances.
  /// Returns Either<Failure, List<T>> where T extends BaseModel.
  Future<Either<Failure, List<T>>> handleListApiRequests<T extends BaseModel>({
    required HttpMethod httpMethod,
    required String endPoint,
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await apiClient.safeApiCall(
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
        final List<dynamic> dataList = response.data;
        final List<T> models = dataList.map((item) => fromJson(item)).toList();
        return Right(models);
      } else {
        return Left(ServerFailure('HTTP ${response.statusCode}: ${response.statusMessage}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Handles API requests that don't return data (void responses).
  /// Returns Either<Failure, void>.
  Future<Either<Failure, void>> handleVoidApiRequests({
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
      final response = await apiClient.safeApiCall(
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
        return const Right(null);
      } else {
        return Left(ServerFailure('HTTP ${response.statusCode}: ${response.statusMessage}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<T> handleDirectApiRequest<T>({
    required HttpMethod httpMethod,
    required String endPoint,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await apiClient.safeApiCall(
        httpMethod: httpMethod,
        endPoint: endPoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      } else {
        return fromJson(response.data as List<dynamic>);
      }
    } on DioException catch (dioException) {
      // Re-throw as GException for repository to handle
      throw ExceptionHandler().handleDioError(dioException);
    } on Exception {
      // Re-throw GException as is
      rethrow;
    } catch (e) {
      // Re-throw as GException
      throw UnknownException(message: 'Failed to parse response: ${e.toString()}');
    }
  }
}
