import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/search_result_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/product_card.dart';

class ProductGridWidget extends ConsumerWidget {
  final ProductGridData? productGrid;

  const ProductGridWidget({super.key, this.productGrid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = productGrid?.products;
    final searchCriteria = productGrid?.searchCriteria;
    if (products?.isEmpty ?? false) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.orange.shade600),
            const Gap(8),
            Text(
              'No products found',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
            const Gap(4),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchCriteria != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                  const Gap(8),
                  Text(
                    '${productGrid?.totalResults} products found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],
          GridView.builder(
            shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 19,
              mainAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemCount: products?.length,
            itemBuilder: (context, index) {
              final product = products?[index];

              return ProductCardWidget(product: product, ref: ref);
            },
          ),
        ],
      ),
    );
  }
}
