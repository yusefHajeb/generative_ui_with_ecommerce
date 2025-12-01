import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/constants/constantnts.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback? onClear;
  final bool isChatLimitReached;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isChatLimitReached,
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
          if (onClear != null)
            IconButton(
              iconSize: 40,
              onPressed: onClear,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.primaryColor.withValues(alpha: 0.6);
                  }
                  return AppColors.primary50;
                }),
              ),
              icon: Container(
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: AssetImage(Constantnts.record)),
                ),
              ),
            ),

          Expanded(
            child: Container(
              // height: 44,
              padding: const EdgeInsets.only(left: 16, right: 6, bottom: 0),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFF0F0F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Align(
                      alignment: AlignmentGeometry.topLeft,
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,

                        enabled: !isChatLimitReached,
                        decoration: InputDecoration(
                          fillColor: Color(0xFFF5F5F5),

                          constraints: BoxConstraints(maxHeight: 50, minHeight: 20),
                          focusedBorder: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFF303030), fontSize: 14, height: 1.4),
                          hintText: isChatLimitReached
                              ? 'Chat limit reached - Start a new chat'
                              : 'Ask me about products...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        // minLines: null,
                        maxLines: null,

                        textInputAction: TextInputAction.send,
                        style: TextStyle(color: const Color.fromARGB(255, 53, 50, 50)),
                        keyboardType: TextInputType.multiline,
                        onFieldSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  Container(
                    width: 37,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: onSend,
                      icon: Image.asset(Constantnts.send, width: 50, fit: BoxFit.cover),
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
