// cart_body_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/widgets/cart_item_widget.dart';

import '../../../../core/theme/app_color.dart';

class CartBodyWidget extends StatelessWidget {
  final Cart cart;
  final double totalPrice;
  final void Function(int productId, int quantity) onQuantityChanged;
  final void Function(int productId) onRemove;
  final void Function() onCheckout;
  final void Function()? onClear; // Optional clear callback

  const CartBodyWidget({
    super.key,
    required this.cart,
    required this.totalPrice,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onCheckout,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cart items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: cart.products.length,
              itemBuilder: (context, index) {
                final cartProduct = cart.products[index];
                return CartItemWidget(
                      cartProduct: cartProduct,
                      onQuantityChanged: (quantity) {
                        onQuantityChanged(cartProduct.id, quantity);
                      },
                      onRemove: () {
                        onRemove(cartProduct.id);
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0.0, duration: 300.ms, delay: (index * 50).ms);
              },
            ),
          ),

          // Cart summary and checkout
          _buildCartSummary(context, cart, totalPrice, onCheckout, onClear),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    Cart cart,
    double totalPrice,
    VoidCallback onCheckout,
    VoidCallback? onClear,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items (${cart.totalQuantity})', style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '\$${cart.totalOriginalPrice.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (cart.discountedTotal < cart.total) ...[
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(
                    '-\$${(cart.totalOriginalPrice - cart.discountedTotal).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const Gap(16),
            const Divider(),
            const Gap(16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.discountedTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Gap(24),

            if (onClear != null) ...[
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cart'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const Gap(12),
            ],

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: const Size(0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0.0, duration: 300.ms);
  }
}
