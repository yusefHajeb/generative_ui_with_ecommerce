import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/chip_button.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/category_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/recommendations_data.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/knowledge_widget.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/product_card.dart'
    show ProductCardWidget;
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/product_grid_widget.dart'
    show ProductGridWidget;
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/wellcom_widget.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/providers/ai_chat_providers.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart' show Cart;
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/base_provider_widget.dart';
import '../../../cart/data/models/cart_product.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/card_body_widget.dart';
import '../data/models/chat_message.dart';
import 'html_chat_display.dart';
import 'product_details_card.dart';

class ChatDataDisplay extends ConsumerWidget {
  final ChatMessageData data;

  const ChatDataDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartTotalPrice = ref.watch(cartTotalPriceProvider);
    switch (data.type) {
      case 'product_grid':
        return ProductGridWidget(productGrid: data.asProductGrid);
      case 'product_details':
        return ProductDetailsCard(ref: ref, product: data.asProductDetails);
      case 'categories':
        return _buildCategories(context, ref, data.asCategories);
      case 'cart':
        return BaseStateWidget(
          provider: cartAsync,
          fakeData: Cart(
            discountedTotal: 243,
            id: 2,
            products: List.generate(
              3,
              (g) => CartProduct(
                id: 1,
                title: 'title',
                price: 2323.323,
                quantity: 3,
                total: 42.3,
                discountPercentage: 33.4,
                discountedTotal: 43,
                thumbnail: '',
              ),
            ),
            total: 232.3,
            userId: 2,
            totalProducts: 23,
            totalQuantity: 23,
          ), // Use your helper
          errorWidget: (error, stackTrace) => Text(error.toString()),
          builder: (context, cart) {
            if (cart.products.isEmpty) {
              return Text('data');
            }
            return CartBodyWidget(  
              cart: cart,
              totalPrice: cartTotalPrice,
              onQuantityChanged: (productId, quantity) {
                ref.read(cartProvider.notifier).updateQuantity(productId, quantity);
              },
              onRemove: (productId) {
                ref.read(cartProvider.notifier).removeFromCart(productId);
              },
              onCheckout: () {
                context.push('/dialoge-test');
              },
              onClear: () => Icon(Icons.clear_all), // Optional
              showSummary: false,
            );
          },
        );
      case 'recommendations':
        return _buildRecommendations(context, ref, data.asRecommendations);
      case 'cart_update':
        return _buildCartUpdate(context, ref, data.content);
      case 'html':
        return HtmlChatDisplay(htmlContent: data.content as String);
      case 'knowledge':
        return KnowledgeWidget(chatMessageData: data);
      case 'wellcom':
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary10),
          child: WellcomWidget(),
        );
      case 'theme_change':
      case 'navigation':
        final page = data.pageName ?? '';
        // support a "directory:" prefix to navigate to a directory route with path as query param
        // context.push(page);
        return TextButton.icon(
          onPressed: page.isNotEmpty ? () => context.push('/$page') : null,
          icon: const Icon(Icons.open_in_new),
          label: Text(page.isNotEmpty ? 'Open page' : 'Invalid page'),
        );
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary500,
              ),
            ),
          ),
          const Gap(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 4,
              children:
                  categories?.map((category) {
                    return ChipButton(
                      onPressed: () {
                        ref.read(aiChatProvider.notifier).sendMessage(category.name);
                      },
                      label: category.name.toString(),
                      textColor: AppColors.primary50,
                      backgroundColor: AppColors.primary400,
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
            ...sampleProducts.map(
              (product) => ProductCardWidget(product: product, ref: ref, isInChatbot: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, WidgetRef ref, RecommendationData? content) {
    final products = content?.products;

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
              return ProductCardWidget(ref: ref, product: products?[index], isInChatbot: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartUpdate(BuildContext context, WidgetRef ref, dynamic products) {
    log('build cart update $products');
    final product = (products['product'] is ProductModel)
        ? (products['product'] as ProductModel)
        : ProductModel.fromJson(products['product']);
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
              'Added "${product.title}" to cart!',
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
