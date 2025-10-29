import 'package:flutter/material.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback? onClear;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Clear button
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
            ),

          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  focusedBorder: InputBorder.none,

                  hintText: 'Ask me about products...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 4,
                minLines: 1,

                style: TextStyle(color: const Color.fromARGB(255, 53, 50, 50)),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
            child: IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
