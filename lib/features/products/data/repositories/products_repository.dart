import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/endpoints.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_service.dart';
import 'package:generative_ui_with_ecommerce/features/products/data/models/product.dart';

import '../../../../core/network/dio_client.dart';
// import '../../../../core/provider/network_provider.dart';

/// Repository for products data operations
class ProductsRepository extends NetworkService {
  ProductsRepository(super.apiClient);

  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await handleDirectApiRequest<List<Product>>(
        httpMethod: HttpMethod.get,
        endPoint: '${ApiEndpoints.fakeStoreBaseUrl}${ApiEndpoints.fakeStoreProducts}',
        fromJson: (json) => (json as List).map((json) => Product.fromJson(json)).toList(),
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetch a single product by ID
  Future<Either<Failure, Product>> getProductById(String id) async {
    return handleBaseModelApiRequests<Product>(
      httpMethod: HttpMethod.get,
      endPoint: '${ApiEndpoints.fakeStoreBaseUrl}${ApiEndpoints.fakeStoreProductDetails(id)}',
      fromJson: (json) => Product.fromJson(json),
    );
  }

  /// Fetch products by category
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category) async {
    return handleListApiRequests<Product>(
      httpMethod: HttpMethod.get,
      endPoint:
          '${ApiEndpoints.fakeStoreBaseUrl}${ApiEndpoints.fakeStoreProducts}/category/$category',
      fromJson: (json) => Product.fromJson(json),
    );
  }

  /// Fetch all categories
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final response = await apiClient.safeApiCall(
        httpMethod: HttpMethod.get,
        endPoint: '${ApiEndpoints.fakeStoreBaseUrl}${ApiEndpoints.fakeStoreCategories}',
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final List<dynamic> dataList = response.data;
        final List<String> categories = dataList.map((item) => item as String).toList();
        return Right(categories);
      } else {
        return Left(ServerFailure('HTTP ${response.statusCode}: ${response.statusMessage}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Fake Store API Client Provider
final fakeStoreApiClientProvider = Provider<ApiClient>((ref) {
  return DioClientFactory.createApiClient(
    baseUrl: ApiEndpoints.fakeStoreBaseUrl,
    enableLogging: true,
    enableAuth: false, // Fake Store API does not require auth
    enableRetry: true,
    enableCache: false, // Disable caching for external API
  );
});

/// Riverpod provider for ProductsRepository
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final apiClient = ref.watch(fakeStoreApiClientProvider);
  return ProductsRepository(apiClient);
});
