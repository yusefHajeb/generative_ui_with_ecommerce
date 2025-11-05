// cart_body_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/widgets/cart_checkout_widget.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/widgets/cart_summary_widget.dart';

class CartBodyWidget extends StatelessWidget {
  final Cart cart;
  final double totalPrice;
  final void Function(int productId, int quantity) onQuantityChanged;
  final void Function(int productId) onRemove;
  final void Function() onCheckout;
  final void Function()? onClear; // Optional clear callback
  final bool showSummary; // New parameter to control summary visibility

  const CartBodyWidget({
    super.key,
    required this.cart,
    required this.totalPrice,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onCheckout,
    this.onClear,
    this.showSummary = true, // Default to true for backward compatibility
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
          if (showSummary) ...[
            CartSummaryWidget(cart: cart, onCheckout: onCheckout, onClear: onClear),
          ] else ...[
            CartCheckoutWidget(cart: cart, onCheckout: onCheckout),
          ],
        ],
      ),
    );
  }
}
