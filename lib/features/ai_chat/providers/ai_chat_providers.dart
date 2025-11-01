// ai_chat_provider.dart - REFACTORED
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../presentation/data/models/chat_message.dart' show ChatMessage, ChatMessageData;
import '../data/repositories/ai_chat_repository.dart';
import '../services/gemini_mcp_service.dart';
import '../services/chat_history_service.dart';

part 'ai_chat_providers.g.dart';

@Riverpod()
class AiChat extends _$AiChat {
  late final AiChatRepository _aiChatRepository;
  ChatHistoryService? _historyService;
  bool _isInitialized = false;

  @override
  List<ChatMessage> build() {
    _aiChatRepository = ref.watch(aiChatRepository);
    _initializeHistory();
    return [];
  }

  Future<void> _initializeHistory() async {
    if (_isInitialized) return;

    try {
      _historyService = ChatHistoryService();
      final history = await _historyService!.loadCurrentSession();
      if (history.isNotEmpty) {
        state = history.where((msg) => !msg.isLoading).toList();
      } else {
        // Add welcome message for new sessions
        addWelcomeMessage();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing chat history: $e');
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String message) async {
    if (message.trim().isEmpty) return null;

    // Add user message
    final userMessage = ChatMessage(text: message, isUser: true, timestamp: DateTime.now());
    state = [...state, userMessage];
    _saveMessageToHistory(userMessage);

    // Add loading message
    final loadingMessage = ChatMessage(
      text: 'Searching for products...',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    state = [...state, loadingMessage];

    try {
      // Process through our e-commerce AI repository
      final aiResponse = await _aiChatRepository.processMessage(message);

      debugPrint('[PROVIDER] Response type: ${aiResponse.type}');

      // Remove loading message
      state = state.where((msg) => !msg.isLoading).toList();

      ChatMessageData? messageData;
      if (aiResponse.data != null) {
        messageData = ChatMessageData.fromJson(aiResponse.data!);
        log('=========');
      }
      String messageText = aiResponse.message ?? 'I found some products for you!';

      final aiMessage = ChatMessage(
        text: messageText,
        isUser: false,
        timestamp: DateTime.now(),
        data: messageData,
        isError: aiResponse.type == 'error',
      );

      // Add AI message to state
      state = [...state, aiMessage];
      _saveMessageToHistory(aiMessage);

      // Convert AiResponse back to Map for return
      return aiResponse.toJson();
    } catch (e, stackTrace) {
      debugPrint('Error in sendMessage: $e');
      debugPrint('Stack trace: $stackTrace');

      // Remove loading message
      state = state.where((msg) => !msg.isLoading).toList();

      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error while searching. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      state = [...state, errorMessage];
      _saveMessageToHistory(errorMessage);

      return null;
    }
  }

  void _saveMessageToHistory(ChatMessage message) {
    if (_historyService != null) {
      _historyService!.saveMessage(message).catchError((e) {
        debugPrint('Error saving message to history: $e');
      });
    }
  }

  void addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text:
          'Hello! I\'m your shopping assistant. I can help you find products, browse categories, and discover amazing deals. What would you like to shop for today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [...state, welcomeMessage];
    _saveMessageToHistory(welcomeMessage);
  }

  Future<void> clearChat() async {
    state = [];
    if (_historyService != null) {
      try {
        await _historyService!.createNewSession();
        addWelcomeMessage();
      } catch (e) {
        debugPrint('Error creating new session: $e');
      }
    }
  }

  // Existing methods remain the same...
  Future<void> loadSession(String sessionId) async {
    if (_historyService == null) return;
    try {
      await _historyService!.switchToSession(sessionId);
      final messages = await _historyService!.getMessagesForSession(sessionId);
      state = messages.where((msg) => !msg.isLoading).toList();
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    if (_historyService == null) return;
    try {
      await _historyService!.deleteSession(sessionId);
      await _initializeHistory();
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }

  Future<void> clearAllHistory() async {
    if (_historyService == null) return;
    try {
      await _historyService!.clearAllHistory();
      state = [];
      addWelcomeMessage();
    } catch (e) {
      debugPrint('Error clearing all history: $e');
    }
  }

  void showProductDetails(ProductModel? product) {
    // Add a message with product details
    final productDetailsMessage = ChatMessage(
      text: 'Here are the details for "${product?.title ?? 'this product'}":',
      isUser: false,
      timestamp: DateTime.now(),
      data: ChatMessageData(type: 'product_details', content: product?.toJson()),
    );
    state = [...state, productDetailsMessage];
    _saveMessageToHistory(productDetailsMessage);
  }

  void addProductToCart(String productId, ProductModel? product) {
    // Add a cart update message
    final cartUpdateMessage = ChatMessage(
      text: 'Added to cart!',
      isUser: false,
      timestamp: DateTime.now(),
      data: ChatMessageData(
        type: 'cart_update',
        content: {'type': 'cart_update', 'product': product},
      ),
    );
    state = [...state, cartUpdateMessage];
    _saveMessageToHistory(cartUpdateMessage);
  }
}

final searchProducts = Provider<ApiClient>((ref) {
  return DioClientFactory.createApiClient(
    baseUrl: 'https://dummyjson.com',
    enableLogging: true,
    enableAuth: false,
    enableRetry: true,
    enableCache: false,
  );
});

final giminyMCPProvider = Provider<GeminiMCPService>((ref) {
  final apiClient = ref.watch(searchProducts);
  return GeminiMCPService(apiClient);
});
