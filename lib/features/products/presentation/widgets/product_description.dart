import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_scale.dart';

class ProductDescription extends StatelessWidget {
  final ProductModel product;

  const ProductDescription({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedFadeScale(
      duration: const Duration(milliseconds: 900),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
