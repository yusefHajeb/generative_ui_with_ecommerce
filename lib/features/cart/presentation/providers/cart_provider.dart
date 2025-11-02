import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/repositories/cart_repository.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Future<Cart> build() async {
    final cartRepository = ref.watch(cartRepositoryProvider);
    final result = await cartRepository.getCart();

    return result.fold((failure) {
      // Return empty cart on failure
      return Cart(
        id: 1,
        products: [],
        total: 0.0,
        discountedTotal: 0.0,
        userId: 1,
        totalProducts: 0,
        totalQuantity: 0,
      );
    }, (cart) => cart);
  }

  /// Add product to cart
  Future<Either<Failure, Cart>> addToCart(ProductModel product, {int quantity = 1}) async {
    log('add product');
    final cartRepository = ref.read(cartRepositoryProvider);
    final result = await cartRepository.addToCart(product, quantity);
    print(result.isLeft().toString() + result.toString());
    return result;
  }

  /// Update product quantity in cart
  Future<void> updateQuantity(int productId, int quantity) async {
    final cartRepository = ref.read(cartRepositoryProvider);
    final result = await cartRepository.updateQuantity(productId, quantity);

    result.fold(
      (failure) {
        print('Failed to update product quantity: ${failure.message}');
      },
      (updatedCart) {
        state = AsyncData(updatedCart);
      },
    );
  }

  /// Remove product from cart
  Future<void> removeFromCart(int productId) async {
    final cartRepository = ref.read(cartRepositoryProvider);
    final result = await cartRepository.removeFromCart(productId);

    result.fold(
      (failure) {
        print('Failed to remove product from cart: ${failure.message}');
      },
      (updatedCart) {
        state = AsyncData(updatedCart);
      },
    );
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    final cartRepository = ref.read(cartRepositoryProvider);
    final result = await cartRepository.clearCart();

    result.fold(
      (failure) {
        print('Failed to clear cart: ${failure.message}');
      },
      (emptyCart) {
        state = AsyncData(emptyCart);
      },
    );
  }

  /// Refresh cart data
  Future<void> refreshCart() async {
    state = const AsyncLoading();
    final cartRepository = ref.read(cartRepositoryProvider);
    final result = await cartRepository.getCart();

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (cart) {
        state = AsyncData(cart);
      },
    );
  }
}

/// Computed provider for cart total items count (for badge)
@riverpod
int cartTotalItems(Ref ref) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(data: (cart) => cart.totalQuantity, orElse: () => 0);
}

/// Computed provider for cart total price
@riverpod
double cartTotalPrice(Ref ref) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(data: (cart) => cart.total, orElse: () => 0.0);
}

/// Computed provider for cart items count
@riverpod
int cartItemsCount(Ref ref) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(data: (cart) => cart.totalProducts, orElse: () => 0);
}

typedef CartAdd = Future<Either<Failure, Cart>> Function(ProductModel product, {int quantity});

@riverpod
CartAdd cartAddOperation(Ref ref) {
  final notifier = ref.read(cartProvider.notifier);
  return (ProductModel product, {int quantity = 1}) =>
      notifier.addToCart(product, quantity: quantity);
}
