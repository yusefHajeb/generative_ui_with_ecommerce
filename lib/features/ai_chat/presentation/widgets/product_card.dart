import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/operation_dialog.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

import '../../../../core/theme/app_color.dart';
import '../../providers/ai_chat_providers.dart';

// ignore: must_be_immutable
class ProductCardWidget extends StatelessWidget {
  ProductCardWidget({super.key, required this.ref, required this.product});

  WidgetRef ref;
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product?.discountPercentage != null && product!.discountPercentage > 0;
    final originalPrice = hasDiscount
        ? product!.price / (1 - product!.discountPercentage / 100)
        : null;
    return GestureDetector(
      onTap: () {
        ref.read(aiChatProvider.notifier).showProductDetails(product);
      },
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.shade200,
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  imageUrl: product?.thumbnail ?? '',
                  errorWidget: (context, _, _) {
                    return Icon(Icons.image, color: Colors.grey, size: 40);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.title ?? 'Unknown Product',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(1),

                    if (product?.brand != null)
                      Text(
                        "${product?.brand}",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),

                    const Gap(2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '\$${product?.price.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                  right: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    product?.rating.toString() ?? '',
                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                  Container(color: Colors.white, height: 10, width: 1),
                                  Text(
                                    product?.averageRating.toStringAsFixed(2).toString() ?? '',
                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (hasDiscount && originalPrice != null) ...[
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Rating
                    const Gap(4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (product == null) return;

                          await OperationDialog.showCartOperationDialog(context, ref, product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
