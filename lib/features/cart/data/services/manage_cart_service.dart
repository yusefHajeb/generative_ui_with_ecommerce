import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/ai_response.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/repositories/cart_repository.dart';

class ManageCartService {
  final CartRepository _cartRepository;

  ManageCartService(this._cartRepository);

  /// View current cart contents
  Future<AiResponse> viewCart() async {
    try {
      final cartResult = await _cartRepository.getCart();

      return cartResult.fold(
        (failure) => ErrorResponse(message: 'Failed to load cart: ${failure.message}'),
        (cart) {
          final cartItems = cart.products;
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: {'action': 'view'},
            message: cart.products.isEmpty ? 'Your cart is empty.' : 'Here\'s your current cart:',
            data: {
              'type': 'cart',
              'content': {
                'items': cartItems,
                'total': cart.total,
                'itemCount': cart.totalProducts,
                'totalQuantity': cart.totalQuantity,
              },
            },
          );
        },
      );
    } catch (e) {
      return ErrorResponse(message: 'Failed to view cart: $e');
    }
  }

  /// Add product to cart
  Future<AiResponse> addToCart(
    String productId,
    Map<String, dynamic> productData,
    int quantity,
  ) async {
    try {
      // Convert productData to ProductModel
      final product = productData['product_details'];

      final result = await _cartRepository.addToCart(product, quantity);

      return result.fold(
        (failure) => ErrorResponse(message: 'Failed to add product to cart: ${failure.message}'),
        (updatedCart) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: {'action': 'add', 'productId': productId, 'quantity': quantity},
            message: 'Product added to cart successfully!',
            data: {
              'type': 'cart_update',
              'content': {
                'action': 'add',
                'productId': productId,
                'quantity': quantity,
                'product': product.toJson(),
              },
            },
          );
        },
      );
    } catch (e) {
      return ErrorResponse(message: 'Failed to add product to cart: $e');
    }
  }

  /// Remove product from cart
  Future<AiResponse> removeFromCart(String productId) async {
    try {
      final result = await _cartRepository.removeFromCart(int.parse(productId));

      return result.fold(
        (failure) =>
            ErrorResponse(message: 'Failed to remove product from cart: ${failure.message}'),
        (updatedCart) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: {'action': 'remove', 'productId': productId},
            message: 'Product removed from cart successfully!',
            data: {
              'type': 'cart_update',
              'content': {'action': 'remove', 'productId': productId},
            },
          );
        },
      );
    } catch (e) {
      return ErrorResponse(message: 'Failed to remove product from cart: $e');
    }
  }

  /// Update product quantity in cart
  Future<AiResponse> updateCartQuantity(String productId, int quantity) async {
    try {
      final result = await _cartRepository.updateQuantity(int.parse(productId), quantity);

      return result.fold(
        (failure) => ErrorResponse(message: 'Failed to update cart: ${failure.message}'),
        (updatedCart) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: {'action': 'update', 'productId': productId, 'quantity': quantity},
            message: quantity > 0 ? 'Cart updated successfully!' : 'Product removed from cart!',
            data: {
              'type': 'cart_update',
              'content': {'action': 'update', 'productId': productId, 'quantity': quantity},
            },
          );
        },
      );
    } catch (e) {
      return ErrorResponse(message: 'Failed to update cart: $e');
    }
  }

  /// Clear entire cart
  Future<AiResponse> clearCart() async {
    try {
      final result = await _cartRepository.clearCart();

      return result.fold(
        (failure) => ErrorResponse(message: 'Failed to clear cart: ${failure.message}'),
        (emptyCart) {
          return ToolCallResponse(
            tool: 'manage_cart',
            arguments: {'action': 'clear'},
            message: 'Cart cleared successfully!',
            data: {
              'type': 'cart_update',
              'content': {'action': 'clear'},
            },
          );
        },
      );
    } catch (e) {
      return ErrorResponse(message: 'Failed to clear cart: $e');
    }
  }
}
