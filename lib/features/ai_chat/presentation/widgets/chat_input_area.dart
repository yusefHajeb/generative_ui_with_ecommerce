import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/constants/constantnts.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

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
          if (onClear != null)
            IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.primaryColor.withValues(alpha: 0.6);
                  }
                  return AppColors.primary50;
                }),
              ),
              // color: AppColors.primary10,
              onPressed: onClear,
              icon: Container(
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // color: AppColors.primary10,
                  image: DecorationImage(image: AssetImage(Constantnts.record)),
                ),
              ),
            ),

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
                        style: TextStyle(color: const Color.fromARGB(255, 53, 50, 50)),
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.multiline,
                        onFieldSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
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
