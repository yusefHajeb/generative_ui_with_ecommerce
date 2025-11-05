import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_app_bar.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_description.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_header.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_image_gallery.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_pricing.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_reviews.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_specifications.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with back button and actions
          const ProductAppBar(),

          // Product Images Gallery with horizontal scroll
          ProductImageGallery(product: product),

          // Product Core Information with AI View button for clothes
          ProductHeader(product: product),

          // Pricing Section
          ProductPricing(product: product),

          // Description
          ProductDescription(product: product),

          // Key Specifications
          ProductSpecifications(product: product),

          // Reviews Section
          ProductReviews(product: product),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Fixed Add to Cart Button
      // bottomSheet: const ProductBottomActionBar(),
    );
  }
}
