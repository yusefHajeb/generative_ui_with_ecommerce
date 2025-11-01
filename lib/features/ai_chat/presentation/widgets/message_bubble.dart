import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import '../data/models/chat_message.dart';
import 'chat_data_display_new.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLast;

  const MessageBubble({super.key, required this.message, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? theme.primaryColor : AppColors.primary500,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppColors.white,
                            fontSize: 16,
                          ),
                        ),

                      // Data display
                    ],
                  ),
                ),
                if (message.data != null) ...[
                  if (message.text.isNotEmpty) const SizedBox(height: 12),
                  ChatDataDisplay(data: message.data!),
                ],

                // Loading indicator
                if (message.isLoading) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUser ? Colors.black : theme.primaryColor,
                      ),
                    ),
                  ),
                ],

                // Error indicator
                if (message.isError) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: isUser ? Colors.white70 : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Error occurred',
                        style: TextStyle(
                          color: isUser ? Colors.white70 : theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // if (isUser) ...[
          //   const SizedBox(width: 8),
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundColor: theme.primaryColor.withOpacity(0.2),
          //     child: Icon(Icons.person, size: 16, color: theme.primaryColor),
          //   ),
          // ],
        ],
      ),
    );
  }
}
