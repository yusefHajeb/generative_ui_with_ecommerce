import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_chat_providers.dart';
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
        color: const Color.fromARGB(255, 249, 240, 222),
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

          // Input Area
          ChatInputArea(
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
