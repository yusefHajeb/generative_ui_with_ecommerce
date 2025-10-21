import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ErrorProviderWidget extends StatelessWidget {
  Object error;
  StackTrace stack;
  void Function()? onPressed;
  ErrorProviderWidget({super.key, required this.error, required this.stack, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load products', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onPressed, child: const Text('Retry')),
        ],
      ),
    );
  }
}
