import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_in.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/icon_widget.dart';

class ProductBottomActionBar extends StatefulWidget {
  const ProductBottomActionBar({super.key});

  @override
  State<ProductBottomActionBar> createState() => _ProductBottomActionBarState();
}

class _ProductBottomActionBarState extends State<ProductBottomActionBar> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedFadeIn(
      duration: const Duration(milliseconds: 1100),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity Selector (using IconWidget like CartItem)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.black38
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    offset: const Offset(1, 1),
                    blurRadius: 1.2,
                    spreadRadius: 0.3,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconWidget(
                    padding: const EdgeInsets.all(1),
                    radius: 4,
                    backgroundColor: context.isDark
                        ? const Color.fromARGB(230, 23, 22, 22)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    isHaveBackgroundColor: _quantity > 1,
                    icon: IconButton(
                      onPressed: _quantity > 1 ? _decrementQuantity : null,
                      icon: Icon(
                        Icons.remove,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 26,
                        maxWidth: 27,
                        minHeight: 26,
                        maxHeight: 27,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconWidget(
                    backgroundColor: context.isDark
                        ? const Color.fromARGB(230, 23, 22, 22)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    isHaveBackgroundColor: true,
                    radius: 4,
                    padding: const EdgeInsets.all(1),
                    icon: IconButton(
                      onPressed: _incrementQuantity,
                      icon: Icon(
                        Icons.add,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 26,
                        maxWidth: 27,
                        minHeight: 26,
                        maxHeight: 27,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {},
              ),
            ),
            const Gap(12),

            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }
}
