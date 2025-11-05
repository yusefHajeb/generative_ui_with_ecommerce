import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/constants/constantnts.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/base_provider_widget.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/dynamic_chat_widget.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/providers/cart_provider.dart';

import '../../../../core/theme/app_color.dart';
import '../../data/models/cart_product.dart';
import '../widgets/card_body_widget.dart';

// cart_screen.dart
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartTotalPrice = ref.watch(cartTotalPriceProvider);
    final cartItemsCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(color: AppColors.primary10)),
        centerTitle: true,
        actions: [
          if (cartItemsCount > 0)
            TextButton.icon(
              onPressed: () => _showClearCartDialog(context, ref),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      body: BaseStateWidget(
        provider: cartAsync,
        fakeData: Cart(
          discountedTotal: 243,
          id: 2,
          products: List.generate(
            10,
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
        errorWidget: (error, stackTrace) => _buildErrorState(context, error),
        builder: (context, cart) {
          if (cart.products.isEmpty) {
            return EmptCartWidget(
              context: context,
              continueOnnPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  constraints: BoxConstraints(maxHeight: 760, maxWidth: double.infinity),
                  backgroundColor: Colors.transparent,
                  builder: (context) => DynamicChatWidget(
                    isFullScreen: true,
                    onClose: () => log('object'),
                    onToggleFullScreen: () => log('onLogTogel'),
                  ),
                );
              },
            );
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
            onCheckout: () => _handleCheckout(context),
            onClear: () => _showClearCartDialog(context, ref), // Optional
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const Gap(16),
          Text('Failed to load cart', style: Theme.of(context).textTheme.headlineSmall),
          const Gap(8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh cart - this will be handled by the provider
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  // ... rest of your methods (_buildErrorState, _buildEmptyState, etc.)

  void _handleCheckout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checkout functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class EmptCartWidget extends StatelessWidget {
  final void Function()? continueOnnPressed;
  const EmptCartWidget({super.key, required this.context, required this.continueOnnPressed});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Constantnts.cartIcon, width: 360),
                  const Gap(16),
                  Text('Your cart is empty', style: Theme.of(context).textTheme.headlineSmall),
                  const Gap(8),
                  Text(
                    'Add some products to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(32),
                  ElevatedButton.icon(
                    onPressed: continueOnnPressed,
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Continue Shopping'),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 500.ms),
    );
  }
}
