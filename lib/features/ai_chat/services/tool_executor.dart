import 'package:flutter/foundation.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/ai_response.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/category_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/recommendations_data.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/search_result_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/product_search_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/recommendation_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/exceptions.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/tool_response_factory.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/services/manage_cart_service.dart';

class ToolExecutor {
  final ProductSearchService _productSearchService;
  final ManageCartService _cartManagementService;
  final RecommendationService _recommendationService;
  final ApiClient _apiClient;

  ToolExecutor({
    required ProductSearchService productSearchService,
    required ManageCartService cartManagementService,
    required RecommendationService recommendationService,
    required ApiClient apiClient,
  }) : _productSearchService = productSearchService,
       _cartManagementService = cartManagementService,
       _recommendationService = recommendationService,
       _apiClient = apiClient;

  /// Returns an [AiResponse] containing the tool execution result or error.
  Future<AiResponse> executeTool(String toolName, Map<String, dynamic> arguments) async {
    try {
      debugPrint('[TOOL_EXECUTOR] Executing tool: $toolName with args: $arguments');

      switch (toolName) {
        case 'search_products':
          return await _executeSearchProducts(arguments);
        case 'get_categories':
          return await _executeGetCategories(arguments);
        case 'get_product_details':
          return await _executeGetProductDetails(arguments);
        case 'manage_cart':
          return await _executeManageCart(arguments);
        case 'get_recommendations':
          return await _executeGetRecommendations(arguments);
        case 'navigate_to_page':
          return _executeNavigateToPage(arguments);
        case 'change_theme':
          return _executeChangeTheme(arguments);
        case 'get_knowledge':
          return _executeGetKnowledge(arguments);
        default:
          throw ToolExecutionException('Unknown tool: $toolName', toolName, arguments: arguments);
      }
    } on ToolExecutionException catch (e) {
      debugPrint('[TOOL_EXECUTOR] Tool execution error: $e');
      return ErrorResponse(message: 'Sorry, I encountered an error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('[TOOL_EXECUTOR] Unexpected error: $e');
      debugPrint('[TOOL_EXECUTOR] Stack trace: $stackTrace');
      return ErrorResponse(
        message: 'Sorry, I encountered an unexpected error while processing your request.',
      );
    }
  }

  Future<AiResponse> _executeSearchProducts(Map<String, dynamic> arguments) async {
    try {
      final searchCriteria = SearchCriteria.fromJson(arguments);
      final result = await _productSearchService.searchProducts(searchCriteria);

      final products = result.products;
      final total = result.totalResults;

      if (products.length == 1) {
        return ToolResponseFactory.productDetails(
          arguments: arguments,
          productData: products.first.toJson(),
          productName: products.first.title,
        );
      }

      String message;
      if (products.isEmpty) {
        message = 'No products found matching your criteria.';
      } else if (total == 1) {
        message = 'Found 1 product matching your search:';
      } else {
        message = 'Found $total products matching your search:';
      }

      return ToolResponseFactory.productGrid(arguments: arguments, message: message, data: result);
    } catch (e) {
      debugPrint('[TOOL_EXECUTOR] Search products error: $e');
      throw ToolExecutionException(
        'Failed to search products',
        'search_products',
        arguments: arguments,
      );
    }
  }

  Future<AiResponse> _executeGetCategories(Map<String, dynamic> arguments) async {
    try {
      final showProducts = arguments['showProducts'] as bool? ?? false;

      final response = await _apiClient.safeApiCall(
        httpMethod: HttpMethod.get,
        endPoint: 'https://dummyjson.com/products/categories',
      );

      final categoriesJson = response.data as List;
      final categories = categoriesJson
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      List<ProductModel> sampleProducts = [];
      if (showProducts && categories.isNotEmpty) {
        for (final category in categories.take(4)) {
          try {
            final searchCriteria = SearchCriteria(category: category.slug, limit: 2);
            final result = await _productSearchService.searchProducts(searchCriteria);
            sampleProducts.addAll(result.products);
          } catch (e) {
            debugPrint('[TOOL_EXECUTOR] Error fetching samples for ${category.name}: $e');
          }
        }
      }

      final categoriesData = CategoriesData(
        categories: categories,
        sampleProducts: sampleProducts,
        showSampleProduct: showProducts,
      );

      return ToolResponseFactory.categories(arguments: arguments, data: categoriesData);
    } catch (e) {
      debugPrint('[TOOL_EXECUTOR] Get categories error: $e');
      throw ToolExecutionException(
        'Failed to fetch categories',
        'get_categories',
        arguments: arguments,
      );
    }
  }

  Future<AiResponse> _executeGetProductDetails(Map<String, dynamic> arguments) async {
    try {
      final productId = arguments['productId'] as String?;
      final productTitle = arguments['productTitle'] as String?;

      if (productId == null && productTitle == null) {
        throw ToolExecutionException(
          'Either productId or productTitle must be provided',
          'get_product_details',
          arguments: arguments,
        );
      }

      ProductModel? product;

      // Try to get by ID first
      if (productId != null && productId.isNotEmpty) {
        product = await _productSearchService.getProductDetails(productId);
      }

      // Fallback to search by title
      if (product == null && productTitle != null && productTitle.isNotEmpty) {
        final searchCriteria = SearchCriteria(query: productTitle, limit: 1);
        final result = await _productSearchService.searchProducts(searchCriteria);
        if (result.products.isNotEmpty) {
          product = result.products.first;
        }
      }

      if (product == null) {
        return ErrorResponse(message: 'Sorry, I couldn\'t find details for that product.');
      }

      return ToolResponseFactory.productDetails(
        arguments: arguments,
        productData: product.toJson(),
        productName: product.title,
      );
    } catch (e) {
      debugPrint('[TOOL_EXECUTOR] Get product details error: $e');
      throw ToolExecutionException(
        'Failed to fetch product details',
        'get_product_details',
        arguments: arguments,
      );
    }
  }

  Future<AiResponse> _executeManageCart(Map<String, dynamic> arguments) async {
    try {
      final action = arguments['action'] as String?;

      if (action == null) {
        throw ToolExecutionException(
          'Cart action is required',
          'manage_cart',
          arguments: arguments,
        );
      }

      switch (action) {
        case 'view':
          return await _cartManagementService.viewCart();

        case 'add':
          final productId = arguments['productId'] as String?;
          final productData = arguments['productData'];
          final quantity = (arguments['quantity'] as num?)?.toInt() ?? 1;

          if (productId == null && productData == null) {
            return ErrorResponse(message: 'Please specify which product to add to cart.');
          }

          if (productData != null) {
            final productTitle = productData['title'] as String?;
            if (productTitle != null) {
              final searchCriteria = SearchCriteria(query: productTitle, limit: 1);
              final result = await _productSearchService.searchProducts(searchCriteria);
              if (result.products.isNotEmpty) {
                final product = result.products.first;
                return await _cartManagementService.addToCart(
                  product.id.toString(),
                  product.toJson(),
                  quantity,
                );
              }
            }
          }

          // Use product ID
          if (productId != null) {
            final product = await _productSearchService.getProductDetails(productId);
            return await _cartManagementService.addToCart(productId, product.toJson(), quantity);
          }

          return ErrorResponse(message: 'Sorry, I couldn\'t find that product to add to cart.');

        case 'remove':
          final productId = arguments['productId'] as String?;
          if (productId == null) {
            return ErrorResponse(message: 'Please specify which product to remove from cart.');
          }
          return await _cartManagementService.removeFromCart(productId);

        case 'update':
          final productId = arguments['productId'] as String?;
          final quantity = (arguments['quantity'] as num?)?.toInt();
          if (productId == null || quantity == null) {
            return ErrorResponse(message: 'Please specify product and quantity to update.');
          }
          return await _cartManagementService.updateCartQuantity(productId, quantity);

        case 'clear':
          return await _cartManagementService.clearCart();

        default:
          return ErrorResponse(message: 'Invalid cart action: $action');
      }
    } catch (e) {
      debugPrint('[TOOL_EXECUTOR] Manage cart error: $e');
      throw ToolExecutionException('Failed to manage cart', 'manage_cart', arguments: arguments);
    }
  }

  Future<AiResponse> _executeGetRecommendations(Map<String, dynamic> arguments) async {
    try {
      final type = arguments['type'] as String? ?? 'trending';
      final category = arguments['category'] as String?;
      final productId = arguments['productId'] as String?;
      final limit = (arguments['limit'] as num?)?.toInt() ?? 8;

      RecommendationData recommendationData;

      // Route to appropriate recommendation method based on type and parameters
      if (productId != null) {
        recommendationData = await _recommendationService.getRelatedProducts(
          productId,
          limit: limit,
        );
      } else if (type == 'trending') {
        recommendationData = await _recommendationService.getTrendingProducts(
          category: category,
          limit: limit,
        );
      } else {
        recommendationData = await _recommendationService.getRecommendations(
          context: {'type': type, if (category != null) 'category': category},
          limit: limit,
        );
      }

      String message = 'Here are some recommended products for you:';
      if (category != null) {
        message = 'Here are recommended $category products:';
      }

      return ToolResponseFactory.recommendations(
        arguments: arguments,
        message: message,
        data: recommendationData,
      );
    } catch (e) {
      debugPrint('[TOOL_EXECUTOR] Get recommendations error: $e');
      throw ToolExecutionException(
        'Failed to fetch recommendations',
        'get_recommendations',
        arguments: arguments,
      );
    }
  }

  AiResponse _executeNavigateToPage(Map<String, dynamic> arguments) {
    final page = arguments['page'] as String?;

    if (page == null) {
      return ErrorResponse(message: 'Page parameter is required for navigation.');
    }

    final pageNames = {
      'home': 'Home',
      'search': 'Search',
      'cart': 'Cart',
      'wishlist': 'Wishlist',
      'categories': 'Categories',
      'profile': 'Profile',
      'orders': 'Orders',
      'deals': 'Deals',
      'products': 'Products',
    };

    final pageName = pageNames[page] ?? page;

    return ToolResponseFactory.navigation(arguments: arguments, page: page, pageName: pageName);
  }

  AiResponse _executeChangeTheme(Map<String, dynamic> arguments) {
    final mode = arguments['mode'] as String?;
    final seedColor = arguments['seedColor'] as String?;

    String message = 'Theme updated: ';
    if (mode != null) {
      message += '${mode.toUpperCase()} mode';
    }
    if (seedColor != null) {
      final colorName = _getColorNameFromHex(seedColor);
      message += mode != null ? ' with $colorName color' : '$colorName color scheme';
    }

    return ToolResponseFactory.themeChange(
      arguments: arguments,
      message: message,
      mode: mode,
      seedColor: seedColor,
    );
  }

  AiResponse _executeGetKnowledge(Map<String, dynamic> arguments) {
    final topic = arguments['topic'] as String? ?? 'about';

    final knowledgeBase = {
      'about': {
        'title': 'ShopAI Assistant',
        'description':
            'I am your AI shopping assistant, powered by advanced AI technology to help you discover and shop for amazing products.',
        'tagline': 'Your Personal Shopping Companion',
      },
      'capabilities': {
        'title': 'What I Can Do',
        'features': [
          {
            'name': 'Product Search',
            'icon': '🔍',
            'description':
                'Find products using natural language - search by name, category, price range, or features',
          },
          {
            'name': 'Smart Recommendations',
            'icon': '💡',
            'description':
                'Get personalized product suggestions based on your preferences and trending items',
          },
          {
            'name': 'Category Browsing',
            'icon': '📂',
            'description':
                'Explore products by categories like electronics, fashion, home goods, and more',
          },
          {
            'name': 'Cart Management',
            'icon': '🛒',
            'description': 'Add items to cart, view your selections, and manage your shopping list',
          },
          {
            'name': 'Product Details',
            'icon': '📱',
            'description':
                'Get detailed information about any product including specs, ratings, and images',
          },
        ],
      },
      'help': {
        'title': 'How to Use',
        'tips': [
          'Ask me to search for products: "Show me laptops under \$1000"',
          'Browse categories: "What categories do you have?"',
          'Get recommendations: "Recommend some trending products"',
          'Manage your cart: "Add this to my cart" or "Show my cart"',
          'Get product details: "Tell me more about this product"',
        ],
      },
      'features': {
        'title': 'App Features',
        'description':
            'This e-commerce app offers a complete shopping experience with AI-powered assistance, product search, cart management, and more.',
      },
    };

    final knowledgeData = knowledgeBase[topic] ?? knowledgeBase['about'];

    return ToolResponseFactory.knowledge(
      arguments: arguments,
      message: 'Here\'s what you need to know:',
      knowledgeData: knowledgeData,
    );
  }

  // Helper methods

  String _getColorNameFromHex(String hex) {
    final colorMap = {
      '#FF0000': 'Red',
      '#00FF00': 'Green',
      '#0000FF': 'Blue',
      '#FFFF00': 'Yellow',
      '#FF00FF': 'Magenta',
      '#00FFFF': 'Cyan',
      '#FFA500': 'Orange',
      '#800080': 'Purple',
      '#FFC0CB': 'Pink',
      '#A52A2A': 'Brown',
    };

    return colorMap[hex.toUpperCase()] ?? 'Custom';
  }
}
