import 'package:flutter/material.dart';

class LiquidGlassWidget extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glassColor;
  final double glowRadius;

  const LiquidGlassWidget({
    super.key,
    required this.child,
    this.borderRadius = 30.0,
    this.padding = EdgeInsets.zero,
    this.glassColor,
    this.glowRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
