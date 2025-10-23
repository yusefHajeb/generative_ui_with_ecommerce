import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/dio_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/interceptors.dart';

/// Shared AuthInterceptor instance — ensures tokens are consistent across Dio clients.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

/// Shared Dio factory
final dioProvider = Provider<Dio>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  return DioClientFactory.createDio(
      enableLogging: true,
      enableAuth: true,
      enableRetry: true,
      enableCache: true,
    )
    ..interceptors.removeWhere((i) => i is AuthInterceptor)
    ..interceptors.add(authInterceptor);
});

/// ApiClient provider - concrete implementation available for injection
final apiClientProvider = Provider<ApiClient>((ref) {
  return DioClientFactory.createApiClient(
    enableLogging: true,
    enableAuth: true,
    enableRetry: true,
    enableCache: true,
  );
});
