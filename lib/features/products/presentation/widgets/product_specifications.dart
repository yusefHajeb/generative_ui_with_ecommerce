import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

import '../../../../core/utiles/animated_fade_scale.dart';

class ProductSpecifications extends StatelessWidget {
  final ProductModel product;

  const ProductSpecifications({super.key, required this.product});

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
              Text(
                'Specifications',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Only show important specs, remove SKU and Weight as they might not be important
              _buildSpecItem(context, 'Brand', product.brand),
              _buildSpecItem(context, 'Category', product.category.capitalize()),
              _buildSpecItem(context, 'Shipping', product.shippingInformation),
              _buildSpecItem(context, 'Warranty', product.warrantyInformation),
              _buildSpecItem(context, 'Return Policy', product.returnPolicy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
