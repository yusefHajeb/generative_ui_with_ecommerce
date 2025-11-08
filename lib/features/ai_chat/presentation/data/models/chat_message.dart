import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

import '../../../../../core/network/base_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/search_result_model.dart';
import '../../../data/models/knowledge_model.dart';
import '../../../data/models/recommendations_data.dart';

class ChatMessage extends BaseModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final bool isLoading;
  final ChatMessageData? data;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.isLoading = false,
    this.data,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isError: json['isError'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      data: json['data'] != null
          ? ChatMessageData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'isLoading': isLoading,
      if (data != null) 'data': data!.toJson(),
    };
  }

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isError,
    bool? isLoading,
    ChatMessageData? data,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ChatMessage.fromJson(json);
  }
}

class ChatMessageData extends BaseModel {
  final String type;
  final dynamic content;

  ChatMessageData({required this.type, required this.content});

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(type: json['type'] as String? ?? '', content: json['content']);
  }

  // Type-safe content getters
  ProductGridData? get asProductGrid {
    if (type == 'product_grid' && content is Map<String, dynamic>) {
      return ProductGridData.fromJson(content);
    }
    return null;
  }

  ProductModel? get asProductDetails {
    if (type == 'product_details' && content is Map<String, dynamic>) {
      return ProductModel.fromJson(content);
    }
    return null;
  }

  CategoriesData? get asCategories {
    if (type == 'categories' && content is Map<String, dynamic>) {
      return CategoriesData.fromJson(content);
    }
    return null;
  }

  CartData? get asCart {
    if (type == 'cart' && content is Map<String, dynamic>) {
      return CartData.fromJson(content);
    }
    return null;
  }

  CartUpdateData? get asCartUpdate {
    if (type == 'cart_update' && content is Map<String, dynamic>) {
      return CartUpdateData.fromJson(content);
    }
    return null;
  }

  RecommendationData? get asRecommendations {
    if (type == 'recommendations' && content is Map<String, dynamic>) {
      return RecommendationData.fromJson(content);
    }
    return null;
  }

  KnowledgeData? get asKnowledge {
    if (type == 'knowledge' && content is Map<String, dynamic>) {
      return KnowledgeData.fromJson(content);
    }
    return null;
  }

  String? get pageName {
    if (type == 'navigation' && content is String) {
      return content;
    }
    return null;
  }

  // Legacy support for dynamic content
  dynamic get legacyContent => content;

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'content': content};
  }

  ChatMessageData copyWith({String? type, dynamic content}) {
    return ChatMessageData(type: type ?? this.type, content: content ?? this.content);
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ChatMessageData.fromJson(json);
  }
}
