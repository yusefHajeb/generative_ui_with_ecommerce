import 'package:flutter/foundation.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/services/configuration_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/recommendations_data.dart';

/// Service that provides product recommendations.

class RecommendationService {
  final ApiClient _apiClient;

  RecommendationService({required ApiClient apiClient, required IConfigurationService config})
    : _apiClient = apiClient;

  Future<RecommendationData> getRecommendations({
    String? userId,
    Map<String, dynamic>? context,
    int limit = 10,
  }) async {
    try {
      debugPrint('[RECOMMENDATIONS] Getting recommendations with context: $context');

      final type = context?['type'] as String? ?? 'personalized';
      final category = context?['category'] as String?;

      String apiUrl = '/products';
      if (category != null && category.isNotEmpty) {
        apiUrl += '/category/$category';
      }
      apiUrl += '?limit=$limit';

      switch (type) {
        case 'trending':
          apiUrl += '&sortBy=rating&order=desc';
          break;
        case 'new_arrivals':
          apiUrl += '&sortBy=id&order=desc';
          break;
        case 'featured':
          apiUrl += '&select=title,price,rating,images';
          break;
      }

      final response = await _apiClient.safeApiCall(httpMethod: HttpMethod.get, endPoint: apiUrl);

      final data = response.data as Map<String, dynamic>;
      final products = (data['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return RecommendationData(type: type, products: products);
    } catch (e) {
      debugPrint('[RECOMMENDATIONS] Error: $e');
      return RecommendationData(type: 'personalized', products: []);
    }
  }

  Future<RecommendationData> getRelatedProducts(String productId, {int limit = 10}) async {
    try {
      debugPrint('[RECOMMENDATIONS] Getting related products for: $productId');

      // First, get the product details to find its category
      final productResponse = await _apiClient.safeApiCall(
        httpMethod: HttpMethod.get,
        endPoint: '/products/$productId',
      );

      final productData = productResponse.data as Map<String, dynamic>;
      final category = productData['category'] as String?;

      // Get products from the same category
      String apiUrl = '/products';
      if (category != null && category.isNotEmpty) {
        apiUrl += '/category/$category';
      }
      apiUrl += '?limit=${limit + 1}'; // Get one extra to exclude the current product

      final response = await _apiClient.safeApiCall(httpMethod: HttpMethod.get, endPoint: apiUrl);

      final data = response.data as Map<String, dynamic>;
      final products = (data['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .where((p) => p.id.toString() != productId) // Exclude the current product
          .take(limit)
          .toList();

      return RecommendationData(type: 'similar', products: products);
    } catch (e) {
      debugPrint('[RECOMMENDATIONS] Error getting related products: $e');
      return RecommendationData(type: 'similar', products: []);
    }
  }

  Future<RecommendationData> getTrendingProducts({String? category, int limit = 10}) async {
    try {
      String apiUrl = '/products';
      if (category != null && category.isNotEmpty) {
        apiUrl += '/category/$category';
      }
      apiUrl += '?limit=$limit&sortBy=rating&order=desc';

      final response = await _apiClient.safeApiCall(httpMethod: HttpMethod.get, endPoint: apiUrl);

      final data = response.data as Map<String, dynamic>;
      final products = (data['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return RecommendationData(type: 'trending', products: products);
    } catch (e) {
      debugPrint('[RECOMMENDATIONS] Error getting trending products: $e');
      return RecommendationData(type: 'trending', products: []);
    }
  }
}
