import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/providers/ai_chat_providers.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/routes.dart';

class ProductDetailsCard extends StatelessWidget {
  final WidgetRef ref;
  final ProductModel? product;
  const ProductDetailsCard({super.key, required this.product, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GestureDetector(
        onTap: () {
          context.push(AppRoutes.productDetails, extra: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,

              child: CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: product?.thumbnail ?? '',
                errorWidget: (context, _, _) {
                  return Icon(Icons.image, color: Colors.grey, size: 40);
                },
              ),
            ),
            const Gap(16),

            // Product Title
            Text(
              product?.title ?? 'Unknown Product',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),

            // Price and Rating
            Row(
              children: [
                Text(
                  '\$${product?.price.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${product?.rating ?? '0.0'}'),
                  ],
                ),
              ],
            ),
            const Gap(12),

            // Description
            Text(
              product?.description ?? 'No description available',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (product == null) return;
                  ref
                      .read(aiChatProvider.notifier)
                      .addProductToCart(product?.id.toString() ?? '', product);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
