import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_scale.dart';

class ProductHeader extends StatelessWidget {
  final ProductModel product;

  const ProductHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedFadeScale(
      duration: const Duration(milliseconds: 600),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Text(
                product.brand,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),

              // Title and AI View Button Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (_isClothingProduct(product.category))
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.smart_toy, size: 18),
                        label: const Text('AI View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          // TODO: Implement AI view functionality
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Rating and Stock
              Row(
                children: [
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Reviews Count
                  Text(
                    '${product.reviews.length} reviews',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const Spacer(),

                  // Stock Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStockColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.availabilityStatus,
                      style: TextStyle(
                        color: _getStockColor(),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isClothingProduct(String category) {
    final clothingCategories = [
      'mens-shirts',
      'mens-shoes',
      'mens-watches',
      'womens-dresses',
      'womens-shoes',
      'womens-watches',
      'womens-bags',
      'womens-jewellery',
      'tops',
    ];
    return clothingCategories.contains(category.toLowerCase());
  }

  Color _getStockColor() {
    switch (product.availabilityStatus.toLowerCase()) {
      case 'in stock':
        return Colors.green;
      case 'low stock':
        return Colors.orange;
      case 'out of stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
