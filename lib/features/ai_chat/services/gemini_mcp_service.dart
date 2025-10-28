import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/tool_convert.dart'
    show Tool, ToolFunction, convertToolsToGemini;
import 'package:http/http.dart' as http;
import '../../../features/products/data/models/product.dart';
import '../data/models/ai_response.dart';
import '../data/models/search_result_model.dart';

// import 'tool_convert.dart';
typedef MCPToolCallingService = GeminiMCPService;

class GeminiMCPService extends NetworkService {
  static const String apiKey = '';
  static const String defaultModel = 'gemini-2.0-flash';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // APIs
  static const String fakeStoreApi = 'https://fakestoreapi.com';
  static const String dummyJsonApi = 'https://dummyjson.com';

  final List<Map<String, String>> _conversationPairs = [];
  // late final UserBehaviorService _behaviorService;

  GeminiMCPService(super.apiClient) {
    // _behaviorService = UserBehaviorService();
  }

  Future<AiResponse> processToolCallingRequest(String userInput) async {
    try {
      debugPrint('[INPUT] USER INPUT: "$userInput"');

      // Track AI chat interaction
      // await _behaviorService.trackAiChat(userInput, 'query');

      debugPrint('[GEMINI] SENDING REQUEST TO GEMINI MODEL: $defaultModel');

      final tools = _createEcommerceTools();
      final systemInstruction = _getEcommerceSystemInstruction();
      final conversationContext = _buildConversationContext(userInput);

      final requestBody = {
        'contents': conversationContext,
        'systemInstruction': systemInstruction,
        'tools': tools,
        'generationConfig': {'temperature': 0.1, 'topP': 0.9, 'topK': 40},
      };
      final response = await apiClient.safeApiCall(
        httpMethod: HttpMethod.post,
        endPoint: '$baseUrl/models/$defaultModel:generateContent',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey}),
      );

      if (response.statusCode != 200) {
        return ErrorResponse(
          message: 'Sorry, I encountered an error communicating with Gemini API',
        );
      }

      final responseData = response.data;
      debugPrint('[OK] GEMINI RESPONSE RECEIVED');

      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return TextResponse(message: 'I couldn\'t process that request. Please try again.');
      }

      final candidate = candidates.first;
      final content = candidate['content'];
      final parts = content['parts'] as List;

      for (var part in parts) {
        if (part.containsKey('functionCall')) {
          final functionCall = part['functionCall'];
          final functionName = functionCall['name'] as String;
          final args = functionCall['args'] as Map<String, dynamic>? ?? {};

          debugPrint('[TOOL] Tool call: $functionName');
          debugPrint('[ARGS] Arguments: $args');

          final toolResult = await _executeToolCall(functionName, args, userInput);
          log('tool results ');
          log(toolResult.data.toString());
          log(toolResult.message.toString());
          log(toolResult.type);

          // await _behaviorService.trackInteraction(
          //   action: 'ai_tool_$functionName',
          //   context: {'tool': functionName, 'arguments': args, 'userInput': userInput},
          // );

          // For e-commerce, we'll use structured data instead of HTML
          if (toolResult.data != null) {
            return toolResult;
          }
          if (toolResult is ErrorResponse) {
            log('errors toolResults${toolResult.data.toString()}  ${toolResult.type} ');
          }
          return toolResult;
        }
      }

      // Handle text response
      final textPart = parts.firstWhere(
        (p) => p.containsKey('text'),
        orElse: () => {'text': 'I couldn\'t understand that request.'},
      );

      var textMessage = textPart['text'] as String;
      textMessage = _cleanMarkdownCodeBlocks(textMessage);

      // Store conversation context
      try {
        _conversationPairs.add({'user': userInput, 'assistant': textMessage});
        if (_conversationPairs.length > 5) {
          _conversationPairs.removeAt(0);
        }
      } catch (e) {
        debugPrint('[CONTEXT_ERROR] Failed to store conversation pair: $e');
      }

      // await _behaviorService.trackInteraction(
      //   action: 'ai_text_response',
      //   context: {'responseLength': textMessage.length, 'userInput': userInput},
      // );
      log('---------------------');
      return TextResponse(message: textMessage);
    } catch (e) {
      debugPrint('[ERROR] MCP TOOL CALLING ERROR: $e');
      return ErrorResponse(message: 'Sorry, I encountered an error: $e');
    }
  }

  // E-COMMERCE TOOLS IMPLEMENTATION
  List<Map<String, dynamic>> _createEcommerceTools() {
    return convertToolsToGemini([
      // Product Search & Discovery
      Tool(
        function: ToolFunction(
          name: 'search_products',
          description:
              'Search and filter products from the e-commerce catalog. Use DummyJSON API for advanced search with text queries, categories, price ranges, ratings, and brands.',
          parameters: {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description':
                    'Search keywords to find in product titles and descriptions. Use for text-based searches like "red dress", "gaming laptop", "wireless headphones"',
              },
              'category': {
                'type': 'string',
                'description':
                    'Product category like smartphones, laptops, fragrances, skincare, groceries, home-decoration, furniture, womens-dresses, mens-shirts, etc.',
              },
              'brand': {
                'type': 'string',
                'description': 'Specific brand like Apple, Samsung, Dell, Oppo, Microsoft, etc.',
              },
              'minPrice': {'type': 'number', 'description': 'Minimum price filter for products'},
              'maxPrice': {'type': 'number', 'description': 'Maximum price filter for products'},
              'minRating': {'type': 'number', 'description': 'Minimum rating from 0 to 5 stars'},
              'inStock': {
                'type': 'boolean',
                'description': 'Only show products currently in stock',
              },
              'onSale': {'type': 'boolean', 'description': 'Only show products with discounts'},
              'sortBy': {
                'type': 'string',
                'description': 'Sorting method for results',
                'enum': ['price_low', 'price_high', 'rating', 'popular', 'newest'],
              },
              'limit': {
                'type': 'number',
                'description': 'Maximum number of results to return (default: 20)',
              },
            },
          },
        ),
      ),

      // Product Categories
      Tool(
        function: ToolFunction(
          name: 'get_categories',
          description:
              'Get all available product categories from the store. Use this when user asks about categories, product types, or what kinds of products are available.',
          parameters: {
            'type': 'object',
            'properties': {
              'showProducts': {
                'type': 'boolean',
                'description': 'Whether to include sample products from each category',
              },
            },
          },
        ),
      ),

      // Product Details
      Tool(
        function: ToolFunction(
          name: 'get_product_details',
          description:
              'Get detailed information about a specific product including description, images, rating, stock, and specifications.',
          parameters: {
            'type': 'object',
            'properties': {
              'productId': {
                'type': 'string',
                'description': 'The ID of the product to get details for',
              },
              'productTitle': {
                'type': 'string',
                'description': 'The title or name of the product to search for',
              },
            },
          },
        ),
      ),

      // Cart Management
      Tool(
        function: ToolFunction(
          name: 'manage_cart',
          description:
              'Add, remove, or view items in the shopping cart. Manage cart operations and show current cart contents.',
          parameters: {
            'type': 'object',
            'properties': {
              'action': {
                'type': 'string',
                'description': 'Cart operation to perform',
                'enum': ['add', 'remove', 'update', 'view', 'clear'],
              },
              'productId': {'type': 'string', 'description': 'Product ID to add/remove/update'},
              'quantity': {'type': 'number', 'description': 'Quantity for add/update operations'},
              'productData': {
                'type': 'object',
                'description': 'Product details when adding to cart',
              },
            },
            'required': ['action'],
          },
        ),
      ),

      // Product Recommendations
      Tool(
        function: ToolFunction(
          name: 'get_recommendations',
          description:
              'Get personalized product recommendations based on user preferences, similar products, or trending items.',
          parameters: {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'description': 'Type of recommendations to get',
                'enum': ['trending', 'similar', 'personalized', 'featured', 'new_arrivals'],
              },
              'category': {'type': 'string', 'description': 'Category for recommendations'},
              'productId': {
                'type': 'string',
                'description': 'Product ID to find similar items for',
              },
              'limit': {'type': 'number', 'description': 'Number of recommendations to return'},
            },
          },
        ),
      ),

      // Navigation
      Tool(
        function: ToolFunction(
          name: 'navigate_to_page',
          description: 'Navigate to different sections of the e-commerce app',
          parameters: {
            'type': 'object',
            'properties': {
              'page': {
                'type': 'string',
                'description': 'Page to navigate to',
                'enum': [
                  'home',
                  'search',
                  'cart',
                  'wishlist',
                  'categories',
                  'profile',
                  'orders',
                  'deals',
                ],
              },
            },
            'required': ['page'],
          },
        ),
      ),

      // Theme Management
      Tool(
        function: ToolFunction(
          name: 'change_theme',
          description: 'Change app theme mode and color scheme',
          parameters: {
            'type': 'object',
            'properties': {
              'mode': {
                'type': 'string',
                'description': 'Theme mode: dark or light',
                'enum': ['dark', 'light'],
              },
              'seedColor': {
                'type': 'string',
                'description': 'Seed color as HEX code for theme customization',
              },
            },
          },
        ),
      ),

      // AI Identity
      Tool(
        function: ToolFunction(
          name: 'get_knowledge',
          description:
              'Get information about the AI assistant, its capabilities, and how to use the e-commerce features',
          parameters: {
            'type': 'object',
            'properties': {
              'topic': {
                'type': 'string',
                'description': 'Information topic about the AI assistant',
                'enum': ['about', 'capabilities', 'help', 'features'],
              },
            },
          },
        ),
      ),
    ]);
  }

  // TOOL EXECUTION
  Future<AiResponse> _executeToolCall(
    String toolName,
    Map<String, dynamic> arguments,
    String userInput,
  ) async {
    switch (toolName) {
      case 'search_products':
        return await _searchProducts(arguments);
      case 'get_categories':
        return await _getCategories(arguments);
      case 'get_product_details':
        return await _getProductDetails(arguments);
      case 'manage_cart':
        return _manageCart(arguments);
      case 'get_recommendations':
        return await _getRecommendations(arguments);
      case 'navigate_to_page':
        return _navigateToPage(arguments);
      case 'change_theme':
        return _changeTheme(arguments);
      case 'get_knowledge':
        return _getKnowledge(arguments);
      default:
        return TextResponse(message: 'Action completed');
    }
  }

  // PRODUCT SEARCH IMPLEMENTATION
  Future<AiResponse> _searchProducts(Map<String, dynamic> arguments) async {
    try {
      debugPrint('[PRODUCT_SEARCH] Starting product search with: $arguments');

      final String apiUrl = _buildSearchUrl(arguments);
      debugPrint('[PRODUCT_SEARCH] API URL: $apiUrl');

      // final response = await http.get(Uri.parse(apiUrl));
      final response = await apiClient.safeApiCall(
        endPoint: apiUrl,
        queryParameters: arguments,
        httpMethod: HttpMethod.get,
      );

      final data = response.data;
      final products = data['products'] as List? ?? [];
      final total = data['total'] as int? ?? products.length;

      debugPrint('[PRODUCT_SEARCH] Found $total products');

      // Enhance products with additional data if needed
      final enhancedProducts = await _enhanceProductsData(products);

      String message;
      if (products.isEmpty) {
        message = 'No products found matching your criteria.';
      } else if (total == 1) {
        message = 'Found 1 product matching your search:';
      } else {
        message = 'Found $total products matching your search:';
      }
      // log(enhancedProducts.map((e) => e).toString());

      final searchCriteria = SearchCriteria.fromJson(arguments);
      final productGridData = ProductGridData(
        products: enhancedProducts.map((p) => Product.fromJson(p)).toList(),
        totalResults: total,
        hasMore: total > enhancedProducts.length,
        searchCriteria: searchCriteria,
      );

      return ToolCallResponse(
        tool: 'search_products',

        arguments: arguments,
        message: message,
        data: {'type': 'product_grid', 'content': productGridData.toJson()},
      );
    } catch (e) {
      debugPrint('[PRODUCT_SEARCH] Error: $e');
      return ErrorResponse(message: 'Sorry, I encountered an error while searching products.');
    }
  }

  String _buildSearchUrl(Map<String, dynamic> args) {
    // Use DummyJSON for advanced searches with queries
    if (args['query'] != null) {
      return '/products/search?q=${Uri.encodeComponent(args['query'])}&limit=${args['limit'] ?? 20}';
    }

    // Use DummyJSON for category searches
    if (args['category'] != null) {
      final category = _mapCategoryToApi(args['category'] as String);
      return '/products/category/$category?limit=${args['limit'] ?? 20}';
    }

    // Use DummyJSON for all products with filters
    final params = <String>[];
    params.add('limit=${args['limit'] ?? 20}');

    if (args['minPrice'] != null) params.add('minPrice=${args['minPrice']}');
    if (args['maxPrice'] != null) params.add('maxPrice=${args['maxPrice']}');
    if (args['minRating'] != null) params.add('minRating=${args['minRating']}');
    if (args['brand'] != null) params.add('brand=${Uri.encodeComponent(args['brand'])}');
    log('test argument for search product');
    log(args.toString());

    if (params.length > 1) {
      return '/products?${params.join('&')}';
    }

    // Default: get all products from DummyJSON
    return '/products?limit=20';
  }

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

  Future<List<dynamic>> _enhanceProductsData(List<dynamic> products) async {
    // Add any additional processing or data enhancement here
    return products.map((product) {
      // Ensure all products have required fields for display
      final enhanced = Map<String, dynamic>.from(product);

      // Add display-friendly fields
      if (product['price'] != null) {
        enhanced['displayPrice'] = '\$${product['price']}';
      }

      if (product['rating'] != null) {
        enhanced['displayRating'] = '${product['rating']} ⭐';
      }

      if (product['discountPercentage'] != null) {
        enhanced['hasDiscount'] = product['discountPercentage'] > 0;
      }

      return enhanced;
    }).toList();
  }

  // CATEGORIES IMPLEMENTATION
  Future<AiResponse> _getCategories(Map<String, dynamic> arguments) async {
    try {
      debugPrint('[CATEGORIES] Fetching categories');

      // Get categories from DummyJSON
      final response = await http.get(Uri.parse('$fakeStoreApi/products/categories'));

      if (response.statusCode != 200) {
        // Fallback to FakeStore API
        final fallbackResponse = await http.get(Uri.parse('$fakeStoreApi/products/categories'));
        if (fallbackResponse.statusCode == 200) {
          final categories = jsonDecode(fallbackResponse.body) as List;
          List<dynamic> sampleProducts = [];
          if (arguments['showProducts'] == true) {
            sampleProducts = await _getSampleProductsForCategories(categories);
          }
          return ToolCallResponse(
            tool: 'get_categories',
            arguments: arguments,
            message: 'Here are our product categories:',
            data: {
              'categories': categories,
              'sampleProducts': sampleProducts,
              'total': categories.length,
            },
          );
        }
        throw Exception('Failed to fetch categories');
      }

      final categories = jsonDecode(response.body) as List;

      // Get sample products if requested
      List<dynamic> sampleProducts = [];
      if (arguments['showProducts'] == true) {
        sampleProducts = await _getSampleProductsForCategories(categories);
      }

      return ToolCallResponse(
        tool: 'get_categories',
        arguments: arguments,
        message: 'Here are our product categories:',
        data: {
          'categories': categories,
          'sampleProducts': sampleProducts,
          'total': categories.length,
        },
      );
    } catch (e) {
      debugPrint('[CATEGORIES] Error: $e');
      return ErrorResponse(message: 'Sorry, I couldn\'t fetch categories at the moment.');
    }
  }

  Future<List<dynamic>> _getSampleProductsForCategories(List<dynamic> categories) async {
    final sampleProducts = <dynamic>[];

    for (final category in categories.take(4)) {
      try {
        final response = await http.get(
          Uri.parse('$dummyJsonApi/products/category/$category?limit=2'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final products = data['products'] as List;
          sampleProducts.addAll(products.take(2));
        }
      } catch (e) {
        debugPrint('[SAMPLE_PRODUCTS] Error for category $category: $e');
      }
    }

    return sampleProducts;
  }

  // PRODUCT DETAILS IMPLEMENTATION
  Future<AiResponse> _getProductDetails(Map<String, dynamic> arguments) async {
    try {
      String productId = arguments['productId'] ?? '';
      String productTitle = arguments['productTitle'] ?? '';

      // Try DummyJSON first for rich product data
      if (productId.isNotEmpty) {
        final response = await http.get(Uri.parse('$dummyJsonApi/products/$productId'));
        if (response.statusCode == 200) {
          final product = jsonDecode(response.body);
          return ToolCallResponse(
            tool: 'get_product_details',
            arguments: arguments,
            message: 'Here are the details for ${product['title']}:',
            data: {'type': 'product_details', 'product': product},
          );
        }
      }

      // Fallback to FakeStore API
      if (productId.isEmpty && productTitle.isNotEmpty) {
        // Search for product by title
        final searchResponse = await http.get(
          Uri.parse('$dummyJsonApi/products/search?q=${Uri.encodeComponent(productTitle)}&limit=1'),
        );

        if (searchResponse.statusCode == 200) {
          final data = jsonDecode(searchResponse.body);

          final products = data['products'];
          if (products != null && products != []) {
            return ToolCallResponse(
              tool: 'get_product_details',
              arguments: arguments,
              message: 'Here are the details for ${products.first['title']}:',
              data: {
                'type': 'product_details',
                'product': products is List ? products.first : data['product'],
              },
            );
          }
        }
      }

      return ErrorResponse(message: 'Sorry, I couldn\'t find details for that product.');
    } catch (e) {
      debugPrint('[PRODUCT_DETAILS] Error: $e');
      return ErrorResponse(message: 'Sorry, I encountered an error fetching product details.');
    }
  }

  // CART MANAGEMENT
  AiResponse _manageCart(Map<String, dynamic> arguments) {
    final action = arguments['action'] as String;

    switch (action) {
      case 'view':
      case 'add':
        final productId = arguments['productId'] as String?;
        final quantity = (arguments['quantity'] as num?)?.toInt() ?? 1;
        final productData = arguments['productData'] as Map<String, dynamic>?;

        if (productId != null && productData != null) {
          // In a real app, you'd add to persistent cart storage
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: arguments,
            message: 'Product added to cart!',
            data: {'action': 'add', 'productId': productId, 'quantity': quantity},
          );
        }
        return ErrorResponse(message: 'Please specify which product to add to cart.');

      case 'remove':
        final productId = arguments['productId'] as String?;
        if (productId != null) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: arguments,
            message: 'Product removed from cart!',
            data: {'action': 'remove', 'productId': productId},
          );
        }
        return ErrorResponse(message: 'Please specify which product to remove from cart.');

      case 'update':
        final productId = arguments['productId'] as String?;
        final quantity = (arguments['quantity'] as num?)?.toInt();
        if (productId != null && quantity != null) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: arguments,
            message: 'Cart updated!',
            data: {'action': 'update', 'productId': productId, 'quantity': quantity},
          );
        }
        return ErrorResponse(message: 'Please specify product and quantity to update.');

      case 'clear':
        return ToolCallResponse(
          tool: 'manage_cart',
          arguments: arguments,
          message: 'Cart cleared!',
          data: {'action': 'clear'},
        );

      default:
        return ErrorResponse(message: 'Cart action completed.');
    }
  }

  // RECOMMENDATIONS
  Future<AiResponse> _getRecommendations(Map<String, dynamic> arguments) async {
    try {
      log(arguments.toString());
      final type = arguments['type'] as String? ?? 'trending';
      final category = arguments['category'] as String?;
      final limit = (arguments['limit'] as num?)?.toInt() ?? 8;

      String apiUrl = '$dummyJsonApi/products';
      if (category != null) {
        apiUrl += '/category/${_mapCategoryToApi(category)}';
      }
      apiUrl += '?limit=$limit';

      // Add sorting based on recommendation type
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

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List;

        String message = 'Here are some recommended products for you:';
        if (category != null) {
          message = 'Here are recommended $category products:';
        }

        return ToolCallResponse(
          tool: 'get_recommendations',
          arguments: arguments,
          message: message,
          data: {
            'type': 'recommendations',
            'products': products,
            'recommendationType': type,
            'category': category,
          },
        );
      }

      return ErrorResponse(message: 'Sorry, I couldn\'t fetch recommendations at the moment.');
    } catch (e) {
      debugPrint('[RECOMMENDATIONS] Error: $e');
      return ErrorResponse(message: 'Sorry, I encountered an error fetching recommendations.');
    }
  }

  // EXISTING METHODS (keep from original)
  AiResponse _navigateToPage(Map<String, dynamic> arguments) {
    final page = arguments['page'] as String?;
    final pageNames = {
      'home': 'Home',
      'search': 'Search',
      'cart': 'Cart',
      'wishlist': 'Wishlist',
      'categories': 'Categories',
      'profile': 'Profile',
      'orders': 'Orders',
      'deals': 'Deals',
    };
    final pageName = pageNames[page] ?? page;
    return ToolCallResponse(
      tool: 'navigate_to_page',
      arguments: arguments,
      message: '✓ Navigated to $pageName page',
      data: {'type': 'navigation', 'page': page},
    );
  }

  AiResponse _changeTheme(Map<String, dynamic> arguments) {
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
    return ToolCallResponse(
      tool: 'change_theme',
      arguments: arguments,
      message: message,
      data: {'type': 'theme_change', 'mode': mode, 'seedColor': seedColor},
    );
  }

  AiResponse _getKnowledge(Map<String, dynamic> arguments) {
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
        'title': 'How to Shop with Me',
        'tips': [
          'Search for products: "show me red dresses", "find laptops under \$1000"',
          'Browse by category: "show me electronics", "what home decor do you have?"',
          'Filter results: "phones with 4+ stars", "women\'s shoes in size 8"',
          'Get recommendations: "suggest some trending products", "what\'s popular in skincare?"',
          'Manage cart: "add this to cart", "show me my cart", "clear my cart"',
          'Product details: "tell me about this product", "show me more images"',
        ],
      },
    };

    final knowledge = knowledgeBase[topic] ?? knowledgeBase['about']!;

    return ToolCallResponse(
      tool: 'get_knowledge',
      arguments: arguments,
      message: 'Here\'s information about $topic',
      data: {'type': 'knowledge', 'content': knowledge},
    );
  }

  // HELPER METHODS (keep from original)
  String _getColorNameFromHex(String hex) {
    final cleanHex = hex.replaceAll('#', '').toUpperCase();
    final colorMap = {
      'F44336': 'red',
      'E91E63': 'pink',
      '9C27B0': 'purple',
      '673AB7': 'deep purple',
      '3F51B5': 'indigo',
      '2196F3': 'blue',
      '03A9F4': 'light blue',
      '00BCD4': 'cyan',
      '009688': 'teal',
      '4CAF50': 'green',
      '8BC34A': 'light green',
      'CDDC39': 'lime',
      'FFEB3B': 'yellow',
      'FFC107': 'amber',
      'FF9800': 'orange',
      'FF5722': 'deep orange',
      'FF6B6B': 'coral',
      '4ECDC4': 'turquoise',
      'BB8FCE': 'lavender',
      '98D8C8': 'mint',
      'FFD700': 'gold',
      'C0C0C0': 'silver',
      '000080': 'navy',
      '228B22': 'forest green',
    };
    return colorMap[cleanHex] ?? _analyzeColorFromHex(cleanHex);
  }

  String _analyzeColorFromHex(String hex) {
    if (hex.length != 6) return 'custom color';
    try {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      final maxValue = [r, g, b].reduce((a, b) => a > b ? a : b);
      final minValue = [r, g, b].reduce((a, b) => a < b ? a : b);
      if ((maxValue - minValue) < 30) {
        if (maxValue < 85) return 'dark grey';
        if (maxValue < 170) return 'grey';
        return 'light grey';
      }
      if (r > g && r > b) return 'red';
      if (g > r && g > b) return 'green';
      if (b > r && b > g) return 'blue';
      if (r > 200 && g > 200 && b < 150) return 'yellow';
      return 'custom color';
    } catch (e) {
      return 'custom color';
    }
  }

  String _cleanMarkdownCodeBlocks(String text) {
    final htmlPattern = RegExp(r'```html\s*([\s\S]*?)\s*```', multiLine: true);
    text = text.replaceAllMapped(htmlPattern, (match) {
      return match.group(1)?.trim() ?? '';
    });
    final codePattern = RegExp(r'```[\w]*\s*([\s\S]*?)\s*```', multiLine: true);
    text = text.replaceAllMapped(codePattern, (match) {
      return match.group(1)?.trim() ?? '';
    });
    return text.trim();
  }

  List<Map<String, dynamic>> _buildConversationContext(String currentInput) {
    final contents = <Map<String, dynamic>>[];
    try {
      if (_conversationPairs.isNotEmpty) {
        for (final pair in _conversationPairs) {
          if (pair.containsKey('user') && pair.containsKey('assistant')) {
            contents.add({
              'role': 'user',
              'parts': [
                {'text': pair['user']},
              ],
            });
            contents.add({
              'role': 'model',
              'parts': [
                {'text': pair['assistant']},
              ],
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[CONTEXT_ERROR] Failed to build conversation history: $e');
    }
    contents.add({
      'role': 'user',
      'parts': [
        {'text': currentInput},
      ],
    });
    return contents;
  }

  Map<String, dynamic> _getEcommerceSystemInstruction() {
    return {
      'parts': [
        {
          'text':
              r'''You are ShopAI, an ELITE AI shopping assistant - a fusion of Gemini's intelligence with deep e-commerce expertise and adaptive design capabilities.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌟 YOUR CORE IDENTITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You are NOT just a chatbot. You are:
  • A shopping companion who LEARNS user preferences
  • A product expert who KNOWS inventory and trends
  • A personal shopper who RECOMMENDS perfect items
  • A cart manager who OPTIMIZES shopping experience
  • A design expert who SHOWCASES products beautifully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 INTELLIGENCE FRAMEWORK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. CONTEXT-DRIVEN DECISION MAKING:
   ┌─────────────────────────────────────────────────────────────┐
   │ ALWAYS analyze THREE dimensions before responding:         │
   │                                                             │
   │ A) USER INTENT                                              │
   │    • What are they truly looking for? (explicit + implicit) │
   │    • What's their shopping mood? (browsing/specific/urgent) │
   │    • What preferences have they shown? (brands/categories)  │
   │                                                             │
   │ B) PRODUCT CONTEXT                                          │
   │    • What products are relevant? (category/price/features)  │
   │    • What's the key value? (quality/price/ratings)          │
   │    • What's the availability? (stock/delivery)              │
   │                                                             │
   │ C) OPTIMAL RESPONSE                                         │
   │    • Format: text | product grid | details | combination    │
   │    • Tone: helpful | excited | professional | empathetic    │
   │    • Action: search | recommend | add to cart | navigate    │
   └─────────────────────────────────────────────────────────────┘

2. ADAPTIVE RESPONSE STRATEGY:

   Simple Chat (no tools needed):
     "hi" / "hello" / "thanks" / "ok" → Warm, conversational text

   Identity Questions (use get_knowledge):
     "who are you?" / "what can you do?" / "help" → topic selection

   Shopping Queries (use tools + intelligent presentation):
     "show me laptops" → search_products + BEAUTIFUL product grid
     "what categories do you have?" → get_categories + organized display
     "add to cart" → manage_cart + confirmation
     "product details" → get_product_details + comprehensive info

   CRITICAL FOR PRODUCT DISPLAY:
     • ALWAYS show products in organized, scannable layouts
     • Include key information: price, rating, image, availability
     • Use appropriate layout based on number of products
     • Add relevant sorting and filtering options
     • Ensure high readability and professional appearance

   Complex Operations (multi-step intelligence):
     "find a phone and add to cart" → search + cart addition
     "compare similar products" → analyze + show differences

3. PROACTIVE INTELLIGENCE:
   • After product view → Suggest similar or complementary items
   • After cart addition → Show related accessories
   • After category browse → Highlight popular items
   • After search → Offer filter refinements

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 DYNAMIC VISUAL INTELLIGENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL: Use structured data presentation, NOT HTML!

PRODUCT DISPLAY RULES:
┌────────────────────────────────────────────────────────────────┐
│ Step 1: Analyze Product Type                                  │
│   • Electronics → Emphasize specs, ratings, features          │
│   • Fashion → Highlight images, sizes, colors, style          │
│   • Home Goods → Focus on dimensions, materials, usage        │
│   • Beauty → Stress ingredients, benefits, reviews            │
│                                                                │
│ Step 2: Check User Preferences                                │
│   • If user mentions priority → Emphasize that aspect         │
│   • If user shows brand preference → Filter by brand          │
│   • If no preference → Show balanced product information      │
│                                                                │
│ Step 3: Ensure Clear Presentation                             │
│   • Consistent product card layout                            │
│   • Clear pricing and discount information                    │
│   • Prominent rating displays                                 │
│   • Stock availability status                                 │
└────────────────────────────────────────────────────────────────┘

LAYOUT SELECTION RULES:
┌────────────────────────────────────────────────────────────────┐
│ Analyze Product Quantity & User Intent:                       │
│                                                                │
│ Single Product (1):                                            │
│   → Detailed layout (images, specs, reviews, description)     │
│   → Focus on complete information and purchase decision       │
│                                                                │
│ Few Products (2-8):                                            │
│   → Grid layout (balanced, equal emphasis)                    │
│   → Card layout (image, key info, quick actions)              │
│                                                                │
│ Many Products (9+):                                            │
│   → List layout (compact, scannable)                          │
│   → Emphasize filtering and sorting options                   │
│                                                                │
│ Mixed Data:                                                    │
│   → Organized sections (categories → products)                │
└────────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 TOOL SELECTION MASTERY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IDENTITY vs SHOPPING Disambiguation (CRITICAL):

┌─ AI IDENTITY (use get_knowledge) ─────────────────────────────┐
│ "who are you?" / "what are you?" → topic="about"             │
│ "what can you do?" / "capabilities?" → topic="capabilities"   │
│ "help" / "how to use this?" → topic="help"                   │
│ "about this app" / "features" → topic="capabilities"         │
└────────────────────────────────────────────────────────────────┘

┌─ SHOPPING OPERATIONS (use shopping tools) ────────────────────┐
│ "show me products" / "search for X" → search_products        │
│ "what categories?" / "browse Y" → get_categories             │
│ "tell me about product Z" → get_product_details              │
│ "add to cart" / "my cart" → manage_cart                      │
│ "recommend products" → get_recommendations                   │
│ "navigate to X" → navigate_to_page                           │
└────────────────────────────────────────────────────────────────┘

SEARCH INTELLIGENCE - DummyJSON API Mastery:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯 YOU ARE A SEARCH EXPERT WITH API INTELLIGENCE
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CRITICAL API KNOWLEDGE:
  • Use DummyJSON API for ALL product searches
  • Support text search across titles and descriptions
  • Filter by category, price, rating, brand, availability
  • Sort by price, rating, popularity
  • Handle pagination with limit parameter

  INTELLIGENT SEARCH MAPPING:

  1️⃣ UNDERSTAND USER INTENT:
     • "show me laptops" → query="laptop" OR category="laptops"
     • "phones under $500" → query="phone" + maxPrice=500
     • "high rated dresses" → category="womens-dresses" + minRating=4.0
     • "Apple products" → brand="Apple"
     • "in stock items" → inStock=true

  2️⃣ MAP TO API PARAMETERS:
     User says: "gaming laptops with 4+ stars under $1000"
     ↓ You think: "Need laptops category, min rating 4, max price 1000"
     ↓ You call: search_products(category="laptops", minRating=4.0, maxPrice=1000)

     User says: "red women dresses"
     ↓ You think: "Search for red dresses in women's category"
     ↓ You call: search_products(query="red dress", category="womens-dresses")

     User says: "popular smartphones"
     ↓ You think: "Smartphones category sorted by rating"
     ↓ You call: search_products(category="smartphones", sortBy="rating")

  3️⃣ HANDLE CATEGORY MAPPING:
     • "electronics" → "smartphones"
     • "clothing" → "mens-shirts" or "womens-dresses"
     • "shoes" → "mens-shoes" or "womens-shoes"
     • "home" → "home-decoration"
     • "beauty" → "skincare" or "fragrances"

  4️⃣ SMART FALLBACKS:
     • If no results → broaden search or remove filters
     • If too many results → suggest additional filters
     • If ambiguous → ask clarifying questions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 ADVANCED SHOPPING CAPABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. MULTI-STEP SHOPPING INTELLIGENCE:
   Example: "find a gaming laptop and add to cart"

   Your Process:
     1. Execute search_products for gaming laptops
     2. Show results in beautiful grid
     3. When user selects, execute manage_cart to add
     4. Present confirmation with cart summary

2. COMPARATIVE ANALYSIS:
   Example: "compare iPhone vs Samsung phones"

   Your Process:
     1. Search both product categories
     2. Extract key comparison points (price, features, ratings)
     3. Present side-by-side comparison
     4. Highlight differences and recommendations

3. PERSONALIZED RECOMMENDATIONS:
   Example: "suggest products based on my last search"

   Your Process:
     1. Analyze user's search history and preferences
     2. Use get_recommendations with personalized parameters
     3. Present curated product selections
     4. Explain why these items were chosen

4. SMART DEFAULTS:
   • No category specified → Show trending products
   • No price specified → Show full range with sorting options
   • No brand specified → Include all relevant brands
   • Ambiguous request → Ask clarifying questions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎭 PERSONALITY & TONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Adaptive Tone Selection:

Greeting → Warm & Welcoming
  "Hello! Ready to find some amazing products today?"

Product Discovery → Excited & Helpful
  "Great choice! I found these fantastic options for you..."

Success → Celebratory & Positive
  "✓ Added to cart! Your item is waiting for you."

Recommendations → Insightful & Personal
  "Based on your interest in X, I think you'll love these..."

Error → Helpful & Solution-Focused
  "I couldn't find that exact product, but here are some great alternatives..."

Comparison → Professional & Balanced
  "Here's how these products compare across key features:"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 SAFETY & PRIVACY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Safe Communications:
   • NEVER make false claims about products
   • ALWAYS base recommendations on actual product data
   • NEVER expose user personal information
   • ALWAYS respect user preferences and boundaries

2. Data Handling:
   • ONLY access product data through provided APIs
   • NEVER make up product specifications or prices
   • CLEAR distinction between actual data and suggestions
   • RESPECT API rate limits and handle errors gracefully

3. User Experience Safety:
   • PROVIDE clear navigation and undo options
   • CONFIRM destructive actions (cart clearance)
   • MAINTAIN consistent, predictable behavior
   • OFFER help when users seem confused or stuck

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PERFORMANCE PRINCIPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• ONE tool call when possible (not multiple)
• COMBINE related search parameters efficiently
• REMEMBER context from previous shopping sessions
• ANTICIPATE follow-up questions and needs
• BALANCE completeness with performance

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REMEMBER: You're providing a PREMIUM shopping experience. Every interaction should feel:
  ✓ Intelligent (understand shopping context)
  ✓ Personalized (adapt to user preferences)
  ✓ Beautiful (organized product displays)
  ✓ Helpful (proactive recommendations)
  ✓ Safe (respect privacy and boundaries)

Make every shopping interaction delightful and efficient!''',
        },
      ],
    };
  }
}
