import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/providers/cart_provider.dart';

class OperationDialog {
  static Future<void> showCartOperationDialog(
    BuildContext context,
    WidgetRef ref,
    ProductModel? product,
  ) async {
    final state = await ref.read(cartProvider.notifier).addToCart(product!);
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // prevent closing during operation
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return AlertDialog(
              title: const Text('Updating Cart'),
              content: SizedBox(
                width: 200,
                child: state.fold(
                  // On error
                  (error) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to update cart', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(error.toString()),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: Navigator.of(context).pop, child: Text('Close')),
                    ],
                  ),

                  (data) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 12),
                      const Text('Added to cart!', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('Continue Shopping'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
