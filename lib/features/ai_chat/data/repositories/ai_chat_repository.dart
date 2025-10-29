import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/ai_response.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/services/gemini_mcp_service.dart';

import '../../providers/ai_chat_providers.dart';

class AiChatRepository {
  final GeminiMCPService _geminiService;

  AiChatRepository(this._geminiService);

  Future<AiResponse> processMessage(String message) async {
    try {
      final response = await _geminiService.processToolCallingRequest(message);
      return response;
    } catch (e) {
      return ErrorResponse(message: 'Failed to process message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts({
    String? query,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
    bool? onSale,
    String? sortBy,
    int? limit,
  }) async {
    final arguments = <String, dynamic>{};
    if (query != null) arguments['query'] = query;
    if (category != null) arguments['category'] = category;
    if (brand != null) arguments['brand'] = brand;
    if (minPrice != null) arguments['minPrice'] = minPrice;
    if (maxPrice != null) arguments['maxPrice'] = maxPrice;
    if (minRating != null) arguments['minRating'] = minRating;
    if (inStock != null) arguments['inStock'] = inStock;
    if (onSale != null) arguments['onSale'] = onSale;
    if (sortBy != null) arguments['sortBy'] = sortBy;
    if (limit != null) arguments['limit'] = limit;

    final response = await _geminiService.processToolCallingRequest(
      'search_products with ${arguments.toString()}',
    );
    if (response is ToolCallResponse &&
        response.data != null &&
        response.data!['products'] != null) {
      return response.data!['products'] as List<Map<String, dynamic>>;
    }
    return [];
  }

  Future<List<String>> getCategories() async {
    final response = await _geminiService.processToolCallingRequest('show me all categories');
    if (response is ToolCallResponse &&
        response.data != null &&
        response.data!['categories'] != null) {
      return response.data!['categories'] as List<String>;
    }
    return [];
  }

  Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final response = await _geminiService.processToolCallingRequest(
      'show me product details for id $productId',
    );
    if (response is ToolCallResponse &&
        response.data != null &&
        response.data!['product'] != null) {
      return response.data!['product'] as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> getRecommendations({
    required String type,
    String? category,
    int? productId,
    int? limit,
  }) async {
    final arguments = <String, dynamic>{'type': type};
    if (category != null) arguments['category'] = category;
    if (productId != null) arguments['productId'] = productId.toString();
    if (limit != null) arguments['limit'] = limit;

    final response = await _geminiService.processToolCallingRequest(
      'get recommendations with ${arguments.toString()}',
    );
    if (response is ToolCallResponse &&
        response.data != null &&
        response.data!['products'] != null) {
      return response.data!['products'] as List<Map<String, dynamic>>;
    }
    return [];
  }

  Future<String> manageCart({
    required String action,
    int? productId,
    int? quantity,
    Map<String, dynamic>? productData,
  }) async {
    final arguments = <String, dynamic>{'action': action};
    if (productId != null) arguments['productId'] = productId.toString();
    if (quantity != null) arguments['quantity'] = quantity;
    if (productData != null) arguments['productData'] = productData;

    final response = await _geminiService.processToolCallingRequest(
      'manage cart with ${arguments.toString()}',
    );
    return response.message ?? 'Cart operation completed';
  }
}

final aiChatRepository = Provider<AiChatRepository>((ref) {
  final giminy = ref.watch(giminyMCPProvider);
  return AiChatRepository(giminy);
});
