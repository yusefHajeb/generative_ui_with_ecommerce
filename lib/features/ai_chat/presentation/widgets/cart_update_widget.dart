import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

class CartUpdateWidget extends ConsumerWidget {
  final ProductModel product;
  final String action;

  const CartUpdateWidget({super.key, required this.product, required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (action == 'add') {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const Gap(8),
            Expanded(
              child: Text(
                'Added "${product.title}" to cart!',
                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    } else if (action == 'remove') {
      return SizedBox();
    }
    return SizedBox.shrink();
  }
}
