import 'package:flutter/material.dart';

class AnimatedFadeScale extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedFadeScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  _AnimatedFadeScaleState createState() => _AnimatedFadeScaleState();
}

class _AnimatedFadeScaleState extends State<AnimatedFadeScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class SliverAnimatedFadeScale extends StatefulWidget {
  final Widget sliver;
  final Duration duration;

  const SliverAnimatedFadeScale({
    Key? key,
    required this.sliver,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _SliverAnimatedFadeScaleState createState() => _SliverAnimatedFadeScaleState();
}

class _SliverAnimatedFadeScaleState extends State<SliverAnimatedFadeScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFadeTransition(opacity: _fadeAnimation, sliver: widget.sliver);
  }
}
