import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import '../../../../core/utiles/animated_fade_scale.dart';

class ProductPricing extends StatelessWidget {
  final ProductModel product;

  const ProductPricing({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountedPrice = product.price - (product.price * product.discountPercentage / 100);

    return SliverAnimatedFadeScale(
      duration: const Duration(milliseconds: 200),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Current Price
              Text(
                '\$${discountedPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),

              // Original Price
              if (product.discountPercentage > 0)
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const SizedBox(width: 8),

              // Discount Badge
              if (product.discountPercentage > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discountPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
