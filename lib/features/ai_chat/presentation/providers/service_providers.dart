library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/dio_client.dart';
import 'package:generative_ui_with_ecommerce/core/providers/configuration_provider.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/domain/interfaces/i_ai_chat_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/gemini_ai_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/product_search_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/recommendation_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/tool_executor.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/tool_registry.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/local/cart_local_data_source_impl.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/remote/cart_remote_data_source_impl.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/repositories/cart_repository.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/services/manage_cart_service.dart';

/// Dependencies: None (leaf provider)
final productApiClientProvider = Provider<ApiClient>((ref) {
  return DioClientFactory.createApiClient(
    baseUrl: 'https://dummyjson.com',
    enableLogging: true,
    enableAuth: false,
    enableRetry: true,
    enableCache: false,
  );
});

/// Dependencies:
/// - productApiClientProvider: For making HTTP requests
/// - configurationServiceProvider: For service configuration
final productSearchServiceProvider = Provider<ProductSearchService>((ref) {
  final apiClient = ref.watch(productApiClientProvider);
  final config = ref.watch(configurationServiceProvider);

  return ProductSearchService(apiClient: apiClient, config: config);
});


/// Dependencies:
/// - productApiClientProvider: For making HTTP requests
/// - configurationServiceProvider: For service configuration
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final apiClient = ref.watch(productApiClientProvider);
  final config = ref.watch(configurationServiceProvider);

  return RecommendationService(apiClient: apiClient, config: config);
});

final cartLocalDataSourceProvider = Provider((ref) {
  return CartLocalDataSourceImpl();
});

/// Dependencies:
/// - productApiClientProvider: For making HTTP requests
final cartRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(productApiClientProvider);
  return CartRemoteDataSourceImpl(apiClient);
});

/// Dependencies:
/// - cartLocalDataSourceProvider: For local cart storage
/// - cartRemoteDataSourceProvider: For remote cart operations
final aiChatCartRepositoryProvider = Provider<CartRepository>((ref) {
  final localDataSource = ref.watch(cartLocalDataSourceProvider);
  final remoteDataSource = ref.watch(cartRemoteDataSourceProvider);

  return CartRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource);
});

/// Dependencies:
/// - aiChatCartRepositoryProvider: For cart data operations
final cartManagementServiceProvider = Provider<ManageCartService>((ref) {
  final cartRepository = ref.watch(aiChatCartRepositoryProvider);
  return ManageCartService(cartRepository);
});

final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  return ToolRegistry();
});


/// Dependencies:
/// - productSearchServiceProvider: For product search operations
/// - cartManagementServiceProvider: For cart management
/// - recommendationServiceProvider: For product recommendations
/// - productApiClientProvider: For API operations
final toolExecutorProvider = Provider<ToolExecutor>((ref) {
  final productSearchService = ref.watch(productSearchServiceProvider);
  final cartManagementService = ref.watch(cartManagementServiceProvider);
  final recommendationService = ref.watch(recommendationServiceProvider);
  final apiClient = ref.watch(productApiClientProvider);

  return ToolExecutor(
    productSearchService: productSearchService,
    cartManagementService: cartManagementService,
    recommendationService: recommendationService,
    apiClient: apiClient,
  );
});

/// Dependencies:
/// - productApiClientProvider: For API operations
/// - configurationServiceProvider: For configuration
/// - toolExecutorProvider: For tool execution
/// - toolRegistryProvider: For tool definitions
final geminiAiServiceProvider = Provider<IAiChatService>((ref) {
  final apiClient = ref.watch(productApiClientProvider);
  final config = ref.watch(configurationServiceProvider);
  final toolExecutor = ref.watch(toolExecutorProvider);
  final toolRegistry = ref.watch(toolRegistryProvider);

  return GeminiAiService(
    apiClient: apiClient,
    config: config,
    toolExecutor: toolExecutor,
    toolRegistry: toolRegistry,
  );
});
