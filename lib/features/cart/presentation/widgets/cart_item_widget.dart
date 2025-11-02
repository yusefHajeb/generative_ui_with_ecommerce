import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import '../../../../core/widgets/icon_widget.dart';
import '../../data/models/cart_product.dart';

class CartItemWidget extends StatefulWidget {
  final CartProduct cartProduct;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartProduct,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartProduct.quantity;
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartProduct.quantity != widget.cartProduct.quantity) {
      _quantity = widget.cartProduct.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),

          const Gap(12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cartProduct.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.1,
                    letterSpacing: 0.2,

                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: context.isDark ? Colors.black38 : Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(1, 1),
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
                            padding: EdgeInsetsGeometry.all(1),
                            radius: 4,
                            backgroundColor: context.isDark
                                ? const Color.fromARGB(230, 23, 22, 22)
                                : Colors.grey.shade300,
                            isHaveBackgroundColor: _quantity > 1 ? true : false,
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
                            padding: EdgeInsets.symmetric(horizontal: 8),
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
                                : Colors.grey.shade300,
                            isHaveBackgroundColor: true,
                            radius: 4,
                            padding: EdgeInsetsGeometry.all(1),
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
                    if (widget.cartProduct.hasDiscount) ...[
                      const Gap(4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.cartProduct.discountPercentage.toStringAsFixed(0)}% OFF',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const Gap(12),

          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: widget.cartProduct.thumbnail.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.cartProduct.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 24),
              ),
            )
          : Icon(Icons.inventory_2, size: 24),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            overflow: TextOverflow.ellipsis,
            widget.cartProduct.formattedDiscountedTotal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const Gap(2),

        if (widget.cartProduct.hasDiscount)
          Text(
            widget.cartProduct.formattedOriginalPrice,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }
}
