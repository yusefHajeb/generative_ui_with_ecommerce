import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

import '../../../../core/theme/app_color.dart';

class CartCheckoutWidget extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;

  const CartCheckoutWidget({super.key, required this.cart, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Checkout'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0.0, duration: 300.ms);
  }
}
