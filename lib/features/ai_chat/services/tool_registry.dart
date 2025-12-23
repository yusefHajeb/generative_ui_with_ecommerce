import 'tool_convert.dart';

class ToolRegistry {
  final List<Tool> _tools = [];

  ToolRegistry() {
    _initializeTools();
  }

  void _initializeTools() {
    _tools.addAll([
      _createSearchProductsTool(),
      _createGetCategoriesTool(),
      _createGetProductDetailsTool(),
      _createManageCartTool(),
      _createGetRecommendationsTool(),
      _createNavigateToPageTool(),
      _createChangeThemeTool(),
      _createGetKnowledgeTool(),
    ]);
  }

  List<Tool> get tools => List.unmodifiable(_tools);

  List<Map<String, dynamic>> toGeminiFormat() {
    return convertToolsToGemini(_tools);
  }

  Tool? getToolByName(String name) {
    try {
      return _tools.firstWhere((tool) => tool.function.name == name);
    } catch (e) {
      return null;
    }
  }

  bool hasToolNamed(String name) {
    return _tools.any((tool) => tool.function.name == name);
  }

  // Tool definitions

  Tool _createSearchProductsTool() {
    return Tool(
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
            'inStock': {'type': 'boolean', 'description': 'Only show products currently in stock'},
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
    );
  }

  Tool _createGetCategoriesTool() {
    return Tool(
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
    );
  }

  Tool _createGetProductDetailsTool() {
    return Tool(
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
    );
  }

  Tool _createManageCartTool() {
    return Tool(
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
            'productData': {'type': 'object', 'description': 'Product details when adding to cart'},
          },
          'required': ['action'],
        },
      ),
    );
  }

  Tool _createGetRecommendationsTool() {
    return Tool(
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
            'productId': {'type': 'string', 'description': 'Product ID to find similar items for'},
            'limit': {'type': 'number', 'description': 'Number of recommendations to return'},
          },
        },
      ),
    );
  }

  Tool _createNavigateToPageTool() {
    return Tool(
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
    );
  }

  Tool _createChangeThemeTool() {
    return Tool(
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
    );
  }

  Tool _createGetKnowledgeTool() {
    return Tool(
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
    );
  }
}
