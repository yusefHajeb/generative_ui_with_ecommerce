import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/data/models/chat_message.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/chat_data_display_new.dart';

class MessageContentWidget extends StatelessWidget {
  final bool isUser;
  final ChatMessage message;
  const MessageContentWidget({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = context.themeData;
    return Column(
      children: [
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
              valueColor: AlwaysStoppedAnimation<Color>(isUser ? Colors.black : theme.primaryColor),
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
    );
  }
}
