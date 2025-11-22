import 'package:flutter/foundation.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/services/configuration_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/search_result_model.dart';

/// Service that uses DummyJSON API for product search.

class ProductSearchService {
  final ApiClient _apiClient;

  ProductSearchService({required ApiClient apiClient, required IConfigurationService config})
    : _apiClient = apiClient;

  Future<ProductGridData> searchProducts(SearchCriteria criteria) async {
    try {
      debugPrint('[PRODUCT_SEARCH] Starting search with criteria: ${criteria.toJson()}');

      final String apiUrl = _buildSearchUrl(criteria);
      debugPrint('[PRODUCT_SEARCH] API URL: $apiUrl');

      final response = await _apiClient.safeApiCall(endPoint: apiUrl, httpMethod: HttpMethod.get);

      final data = response.data as Map<String, dynamic>;
      final products = data['products'] as List? ?? [];
      final total = data['total'] as int? ?? products.length;

      debugPrint('[PRODUCT_SEARCH] Found $total products');

      // Enhance products with additional display data
      final enhancedProducts = _enhanceProductsData(products);

      final productGridData = ProductGridData(
        products: enhancedProducts.map((p) => ProductModel.fromJson(p)).toList(),
        totalResults: total,
        hasMore: total > enhancedProducts.length,
        searchCriteria: criteria,
      );

      return productGridData;
    } catch (e) {
      debugPrint('[PRODUCT_SEARCH] Error: $e');
      // Return empty result on error
      return ProductGridData(
        products: [],
        totalResults: 0,
        hasMore: false,
        searchCriteria: criteria,
      );
    }
  }

  Future<ProductModel> getProductDetails(String productId) async {
    try {
      debugPrint('[PRODUCT_DETAILS] Fetching details for product: $productId');

      final response = await _apiClient.safeApiCall(
        httpMethod: HttpMethod.get,
        endPoint: '/products/$productId',
      );

      final productData = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(productData);
    } catch (e) {
      debugPrint('[PRODUCT_DETAILS] Error: $e');
      rethrow;
    }
  }

  /// - Category search: /products/category/category-name
  /// - All products with filters: /products?filters
  String _buildSearchUrl(SearchCriteria criteria) {
    // Use DummyJSON search endpoint for text queries
    if (criteria.query != null && criteria.query!.isNotEmpty) {
      return '/products/search?q=${Uri.encodeComponent(criteria.query!)}&limit=${criteria.limit ?? 20}';
    }

    // Use category endpoint for category-specific searches
    if (criteria.category != null && criteria.category!.isNotEmpty) {
      final mappedCategory = _mapCategoryToApi(criteria.category!);
      return '/products/category/$mappedCategory?limit=${criteria.limit ?? 20}';
    }

    // Build URL with filters for general product listing
    // final params = <String>[];
    // params.add('limit=${criteria.limit ?? 20}');

    // if (criteria.minPrice != null) params.add('minPrice=${criteria.minPrice}');
    // if (criteria.maxPrice != null) params.add('maxPrice=${criteria.maxPrice}');
    // if (criteria.minRating != null) params.add('minRating=${criteria.minRating}');
    // if (criteria.brand != null && criteria.brand!.isNotEmpty) {
    //   params.add('brand=${Uri.encodeComponent(criteria.brand!)}');
    // }

    // if (params.length > 1) {
    //   return '/products?${params.join('&')}';
    // }

    // Default: get all products
    return '/products?limit=20';
  }

  /// Maps user-friendly category names to API category identifiers.
  ///
  /// Handles common category aliases and variations.
  String _mapCategoryToApi(String userCategory) {
    final categoryMap = {
      'men clothing': 'mens-shirts',
      'men clothes': 'mens-shirts',
      'men fashion': 'mens-shirts',
      'women clothing': 'womens-dresses',
      'women clothes': 'womens-dresses',
      'women fashion': 'womens-dresses',
      'electronics': 'smartphones',
      'phones': 'smartphones',
      'laptops': 'laptops',
      'computers': 'laptops',
      'fragrances': 'fragrances',
      'perfumes': 'fragrances',
      'skincare': 'skincare',
      'beauty': 'skincare',
      'groceries': 'groceries',
      'food': 'groceries',
      'home decoration': 'home-decoration',
      'home decor': 'home-decoration',
      'furniture': 'furniture',
      'dresses': 'womens-dresses',
      'shoes': 'womens-shoes',
      'bags': 'womens-bags',
      'jewelry': 'womens-jewellery',
      'watches': 'mens-watches',
      'shirts': 'mens-shirts',
      'sunglasses': 'sunglasses',
      'automotive': 'automotive',
      'cars': 'automotive',
      'motorcycle': 'motorcycle',
      'lighting': 'lighting',
      'lights': 'lighting',
    };

    final lowerCategory = userCategory.toLowerCase();
    return categoryMap[lowerCategory] ?? userCategory.toLowerCase();
  }

  List<Map<String, dynamic>> _enhanceProductsData(List<dynamic> products) {
    return products.map((product) {
      final enhanced = Map<String, dynamic>.from(product as Map<String, dynamic>);

      // Add display-friendly fields
      if (product['price'] != null) {
        enhanced['displayPrice'] = '\$${product['price']}';
      }

      if (product['rating'] != null) {
        enhanced['displayRating'] = '${product['rating']} ⭐';
      }

      if (product['discountPercentage'] != null) {
        enhanced['hasDiscount'] = (product['discountPercentage'] as num) > 0;
      }

      return enhanced;
    }).toList();
  }
}
