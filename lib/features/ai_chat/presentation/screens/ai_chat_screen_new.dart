import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ai_chat_providers.dart';
import '../data/models/chat_message.dart';
import '../widgets/chat_data_display_new.dart';
import '../widgets/html_chat_display.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);

    debugPrint('[BUILD] Total messages: ${messages.length}');
    if (messages.isNotEmpty) {
      log('------');
      log(messages.first.data.toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopAI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary100),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearChat();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  width: 200,
                  content: const Text('New chat created'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary100),
            tooltip: 'Clear Chat',
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const Gap(16),
                        Text(
                          'Your Shopping Assistant!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Gap(8),
                        Text(
                          'Ask me to find products, browse categories,\nget recommendations, or manage your cart.',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        const Gap(24),
                        // Quick action buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildQuickActionChip('Show me trending products'),
                            _buildQuickActionChip('Browse categories'),
                            _buildQuickActionChip('Find deals'),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      log('messsage 113');
                      // log(message.text);
                      // log(message.data?.toJson().toString() ?? '');
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          _buildInputArea(messages),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String text) {
    return ActionChip(
      label: Text(text, style: TextStyle(color: Colors.red)),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    print(message.data?.content);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.smart_toy, size: 20),
                ),
                const Gap(8),
              ],

              if (message.isUser || message.isError || message.data?.type != 'html')
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.primary
                          : message.isError
                          ? Colors.red.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(color: message.isUser ? Colors.white : Colors.black87),
                        ),
                        const Gap(4),
                        Text(
                          DateFormat.jm().format(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: message.isUser ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (message.isUser) ...[
                const Gap(8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 20, color: Colors.white),
                ),
              ],
            ],
          ),

          if (message.data != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: message.isUser ? 0 : 48,
                right: message.isUser ? 48 : 0,
                top: 8,
              ),
              child: message.data?.type == 'html'
                  ? HtmlChatDisplay(
                      htmlContent: message.data!.content as String? ?? 'No HTML content',
                    )
                  : ChatDataDisplay(data: message.data!),
            ),
          ],

          if (!message.isUser && message.data != null)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  'DEBUG: type=${message.data!.type}, hasContent=${message.data!.content != null}, len=${(message.data!.content.toString() as String?)?.length ?? 0}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(List<ChatMessage> messages) {
    final userMessages = messages.where((m) => m.isUser && !m.isLoading).toList();
    final isChatLimitReached = userMessages.length >= 12;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isChatLimitReached)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat limit reached',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'You\'ve reached the maximum of 3 messages. Start a new chat to continue.',
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).clearChat();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          width: 200,
                          content: Text('New chat created'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isChatLimitReached && !_isProcessing,
                  decoration: InputDecoration(
                    hintText: isChatLimitReached
                        ? 'Chat limit reached - Start a new chat'
                        : 'Ask me about products, deals, or shopping...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    filled: isChatLimitReached,
                    fillColor: isChatLimitReached ? Colors.grey.shade200 : null,
                  ),
                  maxLines: null,
                  style: TextStyle(color: AppColors.primaryColor),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const Gap(8),
              CircleAvatar(
                radius: 24,
                backgroundColor: isChatLimitReached
                    ? Colors.grey.shade400
                    : Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: (_isProcessing || isChatLimitReached) ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isProcessing) return;

    final messages = ref.read(aiChatProvider);
    final userMessages = messages.where((m) => m.isUser && !m.isLoading).toList();
    if (userMessages.length >= 12) {
      debugPrint(
        '[CHAT_LIMIT] Blocked: Cannot send message, limit reached (${userMessages.length} user messages)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          width: 200,
          content: Text('Chat limit reached. Please start a new chat.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _messageController.clear();
    setState(() => _isProcessing = true);

    final response = await ref.read(aiChatProvider.notifier).sendMessage(message);

    setState(() => _isProcessing = false);

    if (response != null && response['type'] == 'tool_call') {
      _handleToolCall(response);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleToolCall(Map<String, dynamic> response) {
    final tool = response['tool'] as String;
    final arguments = response['arguments'] as Map<String, dynamic>;

    switch (tool) {
      case 'navigate_to_page':
        final page = arguments['page'] as String;
        context.go('/$page');
        break;
      case 'change_theme':
        // final mode = arguments['mode'] as String?;
        // Handle theme change if needed
        break;
      default:
        // Handle other tool calls
        break;
    }
  }
}
