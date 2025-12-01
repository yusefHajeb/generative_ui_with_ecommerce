// ai_chat_provider.dart - REFACTORED WITH DEPENDENCY INJECTION
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/providers/service_providers.dart'
    show geminiAiServiceProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart' show ApiClient;
import '../../../../core/network/dio_client.dart' show DioClientFactory;
import '../../../../features/cart/providers/cart_provider.dart';
import '../../data/models/chat_message.dart' show ChatMessage, ChatMessageData;
import '../../domain/interfaces/i_ai_chat_service.dart';
import '../../services/chat_history_service.dart';


part 'ai_chat_providers.g.dart';

@Riverpod()
class AiChat extends _$AiChat {
  late final IAiChatService _aiChatService;
  ChatHistoryService? _historyService;
  bool _isInitialized = false;

  @override
  List<ChatMessage> build() {
    // Use the AI chat service directly (no repository layer)
    _aiChatService = ref.watch(geminiAiServiceProvider);
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
      // Process through our AI chat service directly
      final aiResponse = await _aiChatService.processMessage(message, []);

      debugPrint('[PROVIDER] Response type: ${aiResponse.type}');

      // Remove loading message
      state = state.where((msg) => !msg.isLoading).toList();

      // Handle multiple tool responses - create separate messages for each
      if (aiResponse.data != null && aiResponse.data is Map<String, dynamic>) {
        final dataMap = aiResponse.data as Map<String, dynamic>;

        // Check if this is a combined response with multiple results
        if (dataMap.containsKey('results') && dataMap['results'] is List) {
          final results = dataMap['results'] as List;
          String messageText = aiResponse.message ?? 'I found some products for you!';

          // Create first message with text
          final baseTimestamp = DateTime.now();
          final firstMessage = ChatMessage(
            text: messageText,
            isUser: false,
            timestamp: baseTimestamp,
            isError: aiResponse.type == 'error',
          );
          state = [...state, firstMessage];
          _saveMessageToHistory(firstMessage);

          // Create separate messages for each result with incremental timestamps
          for (var i = 0; i < results.length; i++) {
            final result = results[i] as Map<String, dynamic>;
            final messageData = ChatMessageData.fromJson(result);

            // Create meaningful text for each result message based on type
            String resultText = '';
            if (messageData.type == 'product_grid') {
              resultText = 'Here are the products I found:';
            } else if (messageData.type == 'recommendations') {
              resultText = 'Here are my recommendations:';
            } else if (messageData.type == 'categories') {
              resultText = 'Available categories:';
            } else if (messageData.type == 'cart') {
              resultText = 'Your cart:';
            } else if (messageData.type == 'product_details') {
              resultText = 'Product details:';
            } else {
              resultText = 'Result:';
            }

            final resultMessage = ChatMessage(
              text: resultText,
              isUser: false,
              timestamp: baseTimestamp.add(
                Duration(milliseconds: i * 2),
              ), // Ensure unique timestamps
              data: messageData,
              isError: false,
            );
            state = [...state, resultMessage];
            _saveMessageToHistory(resultMessage);
          }
        } else {
          // Single response - handle normally
          ChatMessageData? messageData;
          if (aiResponse.data != null) {
            messageData = ChatMessageData.fromJson(aiResponse.data!);
            log('=========');
            // log(messageData.toJson().toString());
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
        }
      } else {
        // No data - just text response
        String messageText = aiResponse.message ?? 'I found some products for you!';

        final aiMessage = ChatMessage(
          text: messageText,
          isUser: false,
          timestamp: DateTime.now(),
          isError: aiResponse.type == 'error',
        );

        // Add AI message to state
        state = [...state, aiMessage];
        _saveMessageToHistory(aiMessage);
      }

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
      data: ChatMessageData(type: 'wellcom', content: ''),
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
    ref.read(cartProvider.notifier).addToCart(quantity: 1, product!);

    // Add a cart update message
    final cartUpdateMessage = ChatMessage(
      text: 'Added to cart!',
      isUser: false,
      timestamp: DateTime.now(),
      data: ChatMessageData(
        type: 'cart_update',
        content: {'type': 'cart_update', "action": "add", 'product': product},
      ),
    );
    state = [...state, cartUpdateMessage];
    _saveMessageToHistory(cartUpdateMessage);
  }

  void showCart() {
    // Get current cart data
    final cartAsync = ref.read(cartProvider);
    cartAsync.whenData((cart) {
      // Convert Cart to CartData for chat display
      final cartItems = cart.products.map((product) {
        return CartItem(
          productId: product.id.toString(),
          name: product.title,
          price: product.price,
          quantity: product.quantity,
          imageUrl: product.thumbnail,
        );
      }).toList();

      final cartData = CartData(items: cartItems, total: cart.total, itemCount: cart.totalQuantity);

      // Add a cart message with actual data
      final cartMessage = ChatMessage(
        text: 'Here\'s your current cart:',
        isUser: false,
        timestamp: DateTime.now(),
        data: ChatMessageData(type: 'cart', content: cartData.toJson()),
      );
      state = [...state, cartMessage];
      _saveMessageToHistory(cartMessage);
    });
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
