import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/shimmer_skeleton.dart';

// ignore: must_be_immutable
class BaseStateWidget<T> extends StatelessWidget {
  AsyncValue<T> provider;

  final Widget Function(BuildContext, T) builder;
  final T fakeData;
  final Widget Function(Object error, StackTrace stack)? errorWidget;

  BaseStateWidget({
    super.key,

    required this.provider,
    required this.builder,
    required this.fakeData, // <-- User must provide a fake model/list
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return provider.when(
      data: (data) {
        return builder(context, data);
      },
      error: (error, stackTrace) {
        return errorWidget?.call(error, stackTrace) ??
            Center(
              child: Text(error.toString(), style: const TextStyle(color: Colors.red)),
            );
      },
      loading: () {
        return ShimmerSkeleton(isLoading: true, child: builder(context, fakeData));
      },
    );
  }
}
