// lib/features/ai_chat/services/tool_response_factory.dart
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/ai_response.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/category_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/recommendations_data.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/search_result_model.dart';

part 'tool_response_types.dart';

/// Factory for creating consistent ToolCallResponse instances
/// This reduces duplication and makes response creation more readable
class ToolResponseFactory {
  /// Creates a product grid response for search results
  static ToolCallResponse productGrid({
    required Map<String, dynamic> arguments,
    required String message,
    required ProductGridData data,
  }) {
    return ToolCallResponse(
      tool: 'search_products',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.productGrid, 'content': data.toJson()},
    );
  }

  /// Creates a categories response with optional sample products
  static ToolCallResponse categories({
    required Map<String, dynamic> arguments,
    required CategoriesData data,
    String message = 'Here are our product categories:',
  }) {
    return ToolCallResponse(
      tool: 'get_categories',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.categories, 'content': data.toJson()},
    );
  }

  /// Creates a product details response
  static ToolCallResponse productDetails({
    required Map<String, dynamic> arguments,
    required dynamic productData,
    required String productName,
  }) {
    return ToolCallResponse(
      tool: 'get_product_details',
      arguments: arguments,
      message: 'Here are the details for $productName:',
      data: {'type': ResponseTypes.productDetails, 'content': productData},
    );
  }

  /// Creates a cart management response
  static ToolCallResponse cart({
    required Map<String, dynamic> arguments,
    required String message,
    required CartData data,
  }) {
    return ToolCallResponse(
      tool: 'manage_cart',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.cart, 'content': data.toJson()},
    );
  }

  /// Creates a cart update response
  static ToolCallResponse cartUpdate({
    required Map<String, dynamic> arguments,
    required String message,
    required CartUpdateData data,
  }) {
    return ToolCallResponse(
      tool: 'manage_cart',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.cartUpdate, 'content': data.toJson()},
    );
  }

  /// Creates a product recommendations response
  static ToolCallResponse recommendations({
    required Map<String, dynamic> arguments,
    required String message,
    required RecommendationData data,
  }) {
    return ToolCallResponse(
      tool: 'get_recommendations',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.recommendations, 'content': data.toJson()},
    );
  }

  /// Creates a navigation response
  static ToolCallResponse navigation({
    required Map<String, dynamic> arguments,
    required String page,
    required String pageName,
  }) {
    return ToolCallResponse(
      tool: 'navigate_to_page',
      arguments: arguments,
      message: '✓ Navigated to $pageName page',
      data: {'type': ResponseTypes.navigation, 'content': page},
    );
  }

  /// Creates a theme change response
  static ToolCallResponse themeChange({
    required Map<String, dynamic> arguments,
    required String message,
    required String? mode,
    required String? seedColor,
  }) {
    return ToolCallResponse(
      tool: 'change_theme',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.themeChange, 'mode': mode, 'seedColor': seedColor},
    );
  }

  /// Creates a knowledge/help response
  static ToolCallResponse knowledge({
    required Map<String, dynamic> arguments,
    required String message,
    required dynamic knowledgeData,
  }) {
    return ToolCallResponse(
      tool: 'get_knowledge',
      arguments: arguments,
      message: message,
      data: {'type': ResponseTypes.knowledge, 'content': knowledgeData},
    );
  }
}
