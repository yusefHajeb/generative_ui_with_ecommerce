import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerSkeleton({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(enabled: isLoading, child: child);
  }
}
