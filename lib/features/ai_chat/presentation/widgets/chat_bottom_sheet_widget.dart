import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:intl/intl.dart';

import '../../providers/ai_chat_providers.dart';
import '../data/models/chat_message.dart';
import 'chat_data_display_new.dart';

class ChatBottomSheetWidget extends ConsumerStatefulWidget {
  const ChatBottomSheetWidget({super.key});

  @override
  ConsumerState<ChatBottomSheetWidget> createState() => _ChatBottomSheetWidgetState();
}

class _ChatBottomSheetWidgetState extends ConsumerState<ChatBottomSheetWidget> {
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary),
                const Gap(12),
                const Text(
                  'ShopAI Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const Gap(12),
                        Text(
                          'Your Shopping Assistant!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(8),
                        Text(
                          'Ask me about products, deals, or shopping...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Input Area
          _buildInputArea(messages),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.smart_toy, size: 16),
                ),
                const Gap(8),
              ],

              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : message.isError
                        ? Colors.red.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(2),
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
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ],
            ],
          ),

          if (message.data != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: message.isUser ? 0 : 40,
                right: message.isUser ? 40 : 0,
                top: 4,
              ),
              child: message.data?.type == 'html'
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          'HTML content preview not available in bottom sheet',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ChatDataDisplay(data: message.data!),
            ),
          ],
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
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Text(
                'Chat limit reached. Start a new chat to continue.',
                style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isChatLimitReached && !_isProcessing,
                  decoration: InputDecoration(
                    hintText: isChatLimitReached ? 'Chat limit reached' : 'Ask about products...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    filled: isChatLimitReached,
                    fillColor: isChatLimitReached ? Colors.grey.shade200 : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const Gap(8),
              CircleAvatar(
                radius: 20,
                backgroundColor: isChatLimitReached
                    ? Colors.grey.shade400
                    : Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
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
    // final arguments = response['arguments'] as Map<String, dynamic>;

    switch (tool) {
      case 'navigate_to_page':
        // Close bottom sheet and navigate
        Navigator.of(context).pop();
        // Navigation would be handled by parent widget
        break;
      default:
        break;
    }
  }
}
