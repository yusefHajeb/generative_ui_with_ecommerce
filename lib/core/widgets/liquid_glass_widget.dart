import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidGlassWidget extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glassColor;
  final double glowRadius;

  const LiquidGlassWidget({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = EdgeInsets.zero,
    this.glassColor,
    this.glowRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassGlowLayer(
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(borderRadius)),
        child: GlassGlow(
          glowColor: glassColor ?? Colors.black,
          glowRadius: glowRadius,
          child: child,
        ),
      ),
    );
  }
}
