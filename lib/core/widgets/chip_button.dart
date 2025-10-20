import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    this.iconWidget,

    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = Colors.white,
  });
  final Widget? iconWidget;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,

          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [Text(label), ?iconWidget],
        ),
      ),
    );
  }
}
