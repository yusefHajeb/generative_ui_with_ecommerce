import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import '../../providers/ai_chat_providers.dart';
import 'chat_history_drwer.dart';
import 'chat_input_area.dart';
import 'chat_message_list.dart';

class DynamicChatWidget extends ConsumerStatefulWidget {
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;
  final VoidCallback? onClose;

  const DynamicChatWidget({
    super.key,
    this.isFullScreen = false,
    this.onToggleFullScreen,
    this.onClose,
  });

  @override
  ConsumerState<DynamicChatWidget> createState() => _DynamicChatWidgetState();
}

class _DynamicChatWidgetState extends ConsumerState<DynamicChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(aiChatProvider.notifier).sendMessage(message);
      _messageController.clear();
      _focusNode.requestFocus();
    }
  }

  void _clearChat() {
    ref.read(aiChatProvider.notifier).clearChat();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? const Color.fromARGB(230, 23, 22, 22) : Colors.white,
        borderRadius: widget.isFullScreen
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: widget.isFullScreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          if (widget.isFullScreen)
            _buildFullScreenHeader(context)
          else
            _buildBottomSheetHeader(context),

          // Messages List
          Expanded(
            child: ChatMessageList(messages: messages, scrollController: _scrollController),
          ),

          if (messages.where((m) => m.isUser && !m.isLoading).toList().length >= 12)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.iconColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryColor, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat limit reached',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'You\'ve reached the maximum of 3 messages. Start a new chat to continue.',
                          style: context.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).clearChat();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          ChatInputArea(
            isChatLimitReached:
                messages.where((m) => m.isUser && !m.isLoading).toList().length >= 12,
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            onClear: _clearChat,
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
          const SizedBox(width: 8),
          const Text(
            'AI Shopping Assistant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(onPressed: _clearChat, icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            tooltip: 'More options',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary400),
                    SizedBox(width: 12),
                    Text('New Chat', style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary400),
                    SizedBox(width: 12),
                    Text('Chat History', style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'new':
                  ref.read(aiChatProvider.notifier).clearChat();
                  break;
                case 'history':
                  showGeneralDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 200),
                    pageBuilder: (_, __, ___) => ChatHistoryMenu(
                      onSessionChanged: () {
                        setState(() {});
                      },
                    ),
                    transitionBuilder: (_, anim, __, child) {
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(0.1, -0.05),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                  );
                  break;
                case 'clear':
                  ref.read(aiChatProvider.notifier).clearChat();
                  break;
              }
            },
          ),
          const Text('AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(
            onPressed: widget.onToggleFullScreen,
            icon: const Icon(Icons.open_in_full),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
