// chat_data_display.dart - E-commerce Version
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../providers/ai_chat_providers.dart';
import '../data/models/chat_message.dart';
import 'html_chat_display.dart';

class ChatDataDisplay extends ConsumerWidget {
  final ChatMessageData data;

  const ChatDataDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[E-COMMERCE_DISPLAY] Building for type: ${data.type}');

    switch (data.type) {
      case 'product_grid':
        return _buildProductGrid(context, ref, data.content);
      case 'product_details':
        return _buildProductDetails(context, ref, data.content);
      case 'categories':
        return _buildCategories(context, ref, data.content);
      case 'cart':
        return _buildCart(context, ref, data.content);
      case 'recommendations':
        return _buildRecommendations(context, ref, data.content);
      case 'cart_update':
        return _buildCartUpdate(context, ref, data.content);
      case 'html':
        return HtmlChatDisplay(htmlContent: data.content as String);
      case 'knowledge':
        return _buildKnowledge(context, ref, data);
      case 'theme_change':
      case 'navigation':
        return const SizedBox.shrink();
      default:
        return _buildDefaultData(context);
    }
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref, dynamic content) {
    final products = (content != null && content['products'] is List)
        ? content['products'] as List
        : [];
    final totalResults = (content != null && content['totalResults'] is int)
        ? content['totalResults'] as int
        : products.length;
    final searchCriteria = (content != null && content['searchCriteria'] is Map<String, dynamic>)
        ? content['searchCriteria'] as Map<String, dynamic>
        : null;

    if (products.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
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
                    '${totalResults} products found',
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
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, ref, product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, dynamic product) {
    // final hasDiscount = product['discountPercentage'] != null && product['discountPercentage'] > 0;
    // final originalPrice = hasDiscount
    //     ? product['price'] / (1 - product['discountPercentage'] / 100)
    //     : null;

    return GestureDetector(
      onTap: () {
        // Show product details
        ref.read(aiChatProvider.notifier).showProductDetails(product);
      },
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
            // Product Image
            // Container(
            //   height: 120,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            //     image: DecorationImage(
            //       image: NetworkImage(product['thumbnail'] ?? ''),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),

            // // Product Info
            // Padding(
            //   padding: const EdgeInsets.all(8),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       // Product Title
            //       Text(
            //         product['title'] ?? 'Unknown Product',
            //         style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //       const Gap(4),

            //       // Brand
            //       if (product['brand'] != null)
            //         Text(
            //           product['brand'],
            //           style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            //         ),

            //       const Gap(4),

            //       // Price
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
            //             style: const TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 14,
            //               color: Colors.green,
            //             ),
            //           ),
            //           if (hasDiscount && originalPrice != null) ...[
            //             Text(
            //               '\$${originalPrice.toStringAsFixed(2)}',
            //               style: TextStyle(
            //                 fontSize: 10,
            //                 color: Colors.grey.shade600,
            //                 decoration: TextDecoration.lineThrough,
            //               ),
            //             ),
            //           ],
            //         ],
            //       ),

            //       const Gap(4),

            //       // Rating
            //       Row(
            //         children: [
            //           Icon(Icons.star, color: Colors.amber, size: 12),
            //           Text(
            //             ' ${product['rating']?.toStringAsFixed(1) ?? '0.0'}',
            //             style: const TextStyle(fontSize: 10),
            //           ),
            //           const Spacer(),
            //           if (product['stock'] != null)
            //             Text(
            //               '${product['stock']} left',
            //               style: TextStyle(
            //                 fontSize: 10,
            //                 color: product['stock'] > 10 ? Colors.green : Colors.orange,
            //               ),
            //             ),
            //         ],
            //       ),

            //       const Gap(8),

            //       // Add to Cart Button
            //       SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: () {
            //             ref
            //                 .read(aiChatProvider.notifier)
            //                 .addProductToCart(product['id'].toString(), product);
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.blue.shade600,
            //             foregroundColor: Colors.white,
            //             padding: const EdgeInsets.symmetric(vertical: 6),
            //             minimumSize: const Size(0, 0),
            //           ),
            //           child: const Text('Add to Cart', style: TextStyle(fontSize: 10)),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, WidgetRef ref, dynamic product) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(product['thumbnail'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(16),

          // Product Title
          Text(
            product['title'] ?? 'Unknown Product',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(8),

          // Price and Rating
          Row(
            children: [
              Text(
                '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
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
                  Text(' ${product['rating'] ?? '0.0'}'),
                ],
              ),
            ],
          ),
          const Gap(12),

          // Description
          Text(
            product['description'] ?? 'No description available',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const Gap(16),

          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(aiChatProvider.notifier)
                    .addProductToCart(product['id'].toString(), product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, WidgetRef ref, dynamic content) {
    final categories = content['categories'] as List? ?? [];
    final sampleProducts = content['sampleProducts'] as List?;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return Chip(
                label: Text(category.toString()),
                backgroundColor: Colors.purple.shade100,
              );
            }).toList(),
          ),
          if (sampleProducts != null && sampleProducts.isNotEmpty) ...[
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
            ...sampleProducts.take(3).map((product) => _buildProductCard(context, ref, product)),
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
                        image: DecorationImage(
                          image: NetworkImage(item['imageUrl'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
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

  Widget _buildRecommendations(BuildContext context, WidgetRef ref, dynamic content) {
    final products = (content != null && content['products'] is List)
        ? content['products'] as List
        : [];
    // if()
    log(content.toString());
    // final recommendationType = content['recommendationType'] as String?;
    final recommendationType = 'trending';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getRecommendationTitle(recommendationType),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, ref, products[index]);
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

  Widget _buildCartUpdate(BuildContext context, WidgetRef ref, dynamic content) {
    // final action = content['action'] as String?;
    final product = content['product'] as Map<String, dynamic>?;

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
              'Added "${product?['title'] ?? 'product'}" to cart!',
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Keep existing knowledge widgets from your original file
  Widget _buildKnowledge(BuildContext context, WidgetRef ref, ChatMessageData data) {
    final knowledgeData = data.content as Map<String, dynamic>;
    final topic = knowledgeData['topic'] as String?;

    if (topic == 'about') {
      return _buildAboutCard(context, knowledgeData);
    } else if (topic == 'capabilities') {
      return _buildCapabilitiesCard(context, knowledgeData);
    } else if (topic == 'help') {
      return _buildHelpCard(context, knowledgeData);
    } else {
      return _buildGenericKnowledgeCard(context, knowledgeData);
    }
  }

  Widget _buildAboutCard(BuildContext context, Map<String, dynamic> content) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.purple.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content['title'] ?? 'ShopAI Assistant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (content['tagline'] != null) ...[
                      const Gap(4),
                      Text(
                        content['tagline'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (content['description'] != null) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content['description'],
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard(BuildContext context, Map<String, dynamic> content) {
    final features = content['features'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'What I Can Do',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          if (features != null)
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(feature['icon'] ?? '•', style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (feature['description'] != null) ...[
                            const Gap(4),
                            Text(
                              feature['description'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context, Map<String, dynamic> content) {
    final tips = content['tips'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'Help & Tips',
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          if (tips != null)
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(tip['icon'] ?? '💡', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (tip['description'] != null) ...[
                            const Gap(4),
                            Text(
                              tip['description'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenericKnowledgeCard(BuildContext context, Map<String, dynamic> content) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content['title'] != null) ...[
            Text(
              content['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(12),
          ],
          if (content['content'] != null)
            Text(
              content['content'],
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Type: ${data.type}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Gap(8),
          Text(
            'Content: ${data.content.toString()}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
