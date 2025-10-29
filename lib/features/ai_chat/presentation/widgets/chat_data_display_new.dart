import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/category_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/recommendations_data.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/knowledge_widget.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/product_card.dart'
    show ProductCardWidget;
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/product_grid_widget.dart'
    show ProductGridWidget;
import '../data/models/chat_message.dart';
import 'html_chat_display.dart';
import 'product_details_card.dart';

class ChatDataDisplay extends ConsumerWidget {
  final ChatMessageData data;

  const ChatDataDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[E-COMMERCE_DISPLAY] Building for type: ${data.type}');

    switch (data.type) {
      case 'product_grid':
        return ProductGridWidget(productGrid: data.asProductGrid);
      case 'product_details':
        return ProductDetailsCard(ref: ref, product: data.asProductDetails);
      case 'categories':
        return _buildCategories(context, ref, data.asCategories);
      case 'cart':
        return _buildCart(context, ref, data.content);
      case 'recommendations':
        return _buildRecommendations(context, ref, data.asRecommendations);
      case 'cart_update':
        return _buildCartUpdate(context, ref, data.content['product']);
      case 'html':
        return HtmlChatDisplay(htmlContent: data.content as String);
      case 'knowledge':
        return KnowledgeWidget(chatMessageData: data);
      case 'theme_change':
      case 'navigation':
        return const SizedBox.shrink();
      case 'error':
        return Container(color: Colors.red, child: Text('errors'));
      default:
        return Text(data.type);
    }
  }

  Widget _buildCategories(BuildContext context, WidgetRef ref, CategoriesData? content) {
    final categories = content?.categories;
    final sampleProducts = content?.sampleProducts;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          const Gap(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              spacing: 8,
              children:
                  categories?.map((category) {
                    return Chip(
                      label: Text(category.name.toString()),
                      backgroundColor: Colors.purple.shade100,
                    );
                  }).toList() ??
                  [],
            ),
          ),
          if (sampleProducts!.length > 1) ...[
            const Gap(16),
            Text(
              'Popular Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const Gap(8),
            ...sampleProducts.map((product) => ProductCardWidget(product: product, ref: ref)),
          ],
        ],
      ),
    );
  }

  Widget _buildCart(BuildContext context, WidgetRef ref, dynamic content) {
    final items = content['items'] as List? ?? [];
    final total = content['total'] as double? ?? 0.0;
    final itemCount = content['itemCount'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shopping Cart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                  fontSize: 18,
                ),
              ),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
          const Gap(12),

          if (items.isEmpty)
            Column(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.orange.shade400),
                const Gap(8),
                Text('Your cart is empty', style: TextStyle(color: Colors.orange.shade700)),
              ],
            )
          else ...[
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        image: (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(item['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (item['imageUrl'] == null || item['imageUrl'].toString().isEmpty)
                          ? const Icon(Icons.image, color: Colors.grey, size: 24)
                          : null,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown Product',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Gap(4),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to checkout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, WidgetRef ref, RecommendationData? content) {
    final products = content?.products;
    // if()
    // log(content.toString());
    // final recommendationType = content['recommendationType'] as String?;
    final recommendationType = 'trending';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   _getRecommendationTitle(recommendationType),
          //   style: const TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold,
          //     color: AppColors.primary50,
          //   ),
          // ),
          const Gap(8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: products?.length ?? 0,
            itemBuilder: (context, index) {
              return ProductCardWidget(ref: ref, product: products?[index]);
            },
          ),
        ],
      ),
    );
  }

  String _getRecommendationTitle(String? type) {
    switch (type) {
      case 'trending':
        return '🔥 Trending Now';
      case 'similar':
        return '🛍️ Similar Products';
      case 'personalized':
        return '⭐ Recommended For You';
      case 'featured':
        return '🌟 Featured Products';
      case 'new_arrivals':
        return '🆕 New Arrivals';
      default:
        return 'Recommended Products';
    }
  }

  Widget _buildCartUpdate(BuildContext context, WidgetRef ref, ProductModel product) {
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
              'Added "${product.title ?? 'product'}" to cart!',
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
