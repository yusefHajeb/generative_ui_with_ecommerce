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
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
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
              height: 44,
              padding: const EdgeInsets.only(left: 16, right: 6, bottom: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFF0F0F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Align(
                      alignment: AlignmentGeometry.topLeft,
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          fillColor: Color(0xFFF5F5F5),

                          constraints: BoxConstraints(maxHeight: 30),
                          focusedBorder: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFF303030), fontSize: 14, height: 1.4),
                          hintText: 'Ask me about products...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 4,
                        minLines: 1,

                        style: TextStyle(color: const Color.fromARGB(255, 53, 50, 50)),
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
        ],
      ),
    );
  }
}
