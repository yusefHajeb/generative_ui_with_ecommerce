import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/helper/shared_prefrence.dart';
import 'package:generative_ui_with_ecommerce/core/network/dio_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/endpoints.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_service.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

import '../models/cart_product.dart';

/// Repository for cart data operations
class CartRepository extends NetworkService {
  static const String _cartKey = 'cart_data';

  CartRepository(super.apiClient);

  /// Get cart from local storage
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final cartJson = await SharedPrefrenceHelper.getString(_cartKey);
      if (cartJson == null) {
        // Return empty cart
        return Right(
          Cart(
            id: 1,
            products: [],
            total: 0.0,
            discountedTotal: 0.0,
            userId: 1,
            totalProducts: 0,
            totalQuantity: 0,
          ),
        );
      }

      final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
      final cart = Cart.fromJson(cartData);
      return Right(cart);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load cart: ${e.toString()}'));
    }
  }

  /// Save cart to local storage
  Future<Either<Failure, void>> saveCart(Cart cart) async {
    try {
      final cartJson = jsonEncode(cart.toJson());
      await SharedPrefrenceHelper.setData(_cartKey, cartJson);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save cart: ${e.toString()}'));
    }
  }

  /// Add product to cart
  Future<Either<Failure, Cart>> addToCart(ProductModel product, int quantity) async {
    // add to remote cart or if there network issuse use this code : 
    try {
      final cartResult = await getCart();
      return cartResult.fold((failure) => Left(failure), (cart) async {
        final updatedCart = _addProductToCart(cart, product, quantity);
        final saveResult = await saveCart(updatedCart);
        return saveResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
      });
    } catch (e) {
      log('error in repository');
      return Left(CacheFailure(message: 'Failed to add product to cart: ٠٠${e.toString()}'));
    }
  }

  /// Update product quantity in cart
  Future<Either<Failure, Cart>> updateQuantity(int productId, int quantity) async {
    try {
      final cartResult = await getCart();
      return cartResult.fold((failure) => Left(failure), (cart) async {
        final updatedCart = _updateProductQuantity(cart, productId, quantity);
        final saveResult = await saveCart(updatedCart);
        return saveResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
      });
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update product quantity: ${e.toString()}'));
    }
  }

  /// Remove product from cart
  Future<Either<Failure, Cart>> removeFromCart(int productId) async {
    try {
      final cartResult = await getCart();
      return cartResult.fold((failure) => Left(failure), (cart) async {
        final updatedCart = _removeProductFromCart(cart, productId);
        final saveResult = await saveCart(updatedCart);
        return saveResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
      });
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to remove product from cart: ${e.toString()}'));
    }
  }

  /// Clear cart
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      final emptyCart = Cart(
        id: 1,
        products: [],
        total: 0.0,
        discountedTotal: 0.0,
        userId: 1,
        totalProducts: 0,
        totalQuantity: 0,
      );
      final saveResult = await saveCart(emptyCart);
      return saveResult.fold((failure) => Left(failure), (_) => Right(emptyCart));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  /// Helper method to add product to cart
  Cart _addProductToCart(Cart cart, ProductModel product, int quantity) {
    final existingProductIndex = cart.products.indexWhere(
      (cartProduct) => cartProduct.id == product.id,
    );

    List<CartProduct> updatedProducts;
    if (existingProductIndex != -1) {
      // Update existing product quantity
      updatedProducts = List.from(cart.products);
      final existingProduct = updatedProducts[existingProductIndex];
      final newQuantity = existingProduct.quantity + quantity;
      updatedProducts[existingProductIndex] = updatedProducts[existingProductIndex].copyWith(
        quantity: newQuantity,
        total: existingProduct.price * newQuantity,
        discountedTotal:
            (existingProduct.price * newQuantity) * (1 - existingProduct.discountPercentage / 100),
      );

      CartProduct(
        id: existingProduct.id,
        title: existingProduct.title,
        price: existingProduct.price,
        quantity: newQuantity,
        total: existingProduct.price * newQuantity,
        discountPercentage: existingProduct.discountPercentage,
        discountedTotal:
            (existingProduct.price * newQuantity) * (1 - existingProduct.discountPercentage / 100),
        thumbnail: existingProduct.thumbnail,
      );
    } else {
      // Add new product
      final newCartProduct = CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: quantity,
        total: product.price * quantity,
        discountPercentage: product.discountPercentage, // No discount for now
        discountedTotal: product.price * quantity,
        thumbnail: product.thumbnail,
      );
      updatedProducts = [...cart.products, newCartProduct];
    }

    // Calculate totals
    final total = updatedProducts.fold<double>(0.0, (sum, product) => sum + product.total);
    final discountedTotal = updatedProducts.fold<double>(
      0.0,
      (sum, product) => sum + product.discountedTotal,
    );
    final totalQuantity = updatedProducts.fold<int>(0, (sum, product) => sum + product.quantity);

    return Cart(
      id: cart.id,
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      userId: cart.userId,
      totalProducts: updatedProducts.length,
      totalQuantity: totalQuantity,
    );
  }

  /// Helper method to update product quantity
  Cart _updateProductQuantity(Cart cart, int productId, int quantity) {
    final updatedProducts = cart.products.map((cartProduct) {
      if (cartProduct.id == productId) {
        return CartProduct(
          id: cartProduct.id,
          title: cartProduct.title,
          price: cartProduct.price,
          quantity: quantity,
          total: cartProduct.price * quantity,
          discountPercentage: cartProduct.discountPercentage,
          discountedTotal:
              (cartProduct.price * quantity) * (1 - cartProduct.discountPercentage / 100),
          thumbnail: cartProduct.thumbnail,
        );
      }
      return cartProduct;
    }).toList();

    // Remove product if quantity is 0
    final filteredProducts = updatedProducts.where((product) => product.quantity > 0).toList();

    // Calculate totals
    final total = filteredProducts.fold<double>(0.0, (sum, product) => sum + product.total);
    final discountedTotal = filteredProducts.fold<double>(
      0.0,
      (sum, product) => sum + product.discountedTotal,
    );
    final totalQuantity = filteredProducts.fold<int>(0, (sum, product) => sum + product.quantity);

    return Cart(
      id: cart.id,
      products: filteredProducts,
      total: total,
      discountedTotal: discountedTotal,
      userId: cart.userId,
      totalProducts: filteredProducts.length,
      totalQuantity: totalQuantity,
    );
  }

  Cart _removeProductFromCart(Cart cart, int productId) {
    final updatedProducts = cart.products.where((product) => product.id != productId).toList();

    // Calculate totals
    final total = updatedProducts.fold<double>(0.0, (sum, product) => sum + product.total);
    final discountedTotal = updatedProducts.fold<double>(
      0.0,
      (sum, product) => sum + product.discountedTotal,
    );
    final totalQuantity = updatedProducts.fold<int>(0, (sum, product) => sum + product.quantity);

    return Cart(
      id: cart.id,
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      userId: cart.userId,
      totalProducts: updatedProducts.length,
      totalQuantity: totalQuantity,
    );
  }

  Future<Either<Failure, Cart>> getCartFromRemote() async {
    return Left(ServerFailure('Remote cart fetching not implemented yet'));
  }

  Future<Either<Failure, Cart>> syncCartWithRemote(Cart localCart) async {
    return Left(ServerFailure('Cart synchronization not implemented yet'));
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  // For now, using a basic API client. In future, can use specific cart API client
  final apiClient = DioClientFactory.createApiClient(
    baseUrl: ApiEndpoints.baseUrl,
    enableLogging: true,
    enableAuth: false,
    enableRetry: true,
    enableCache: false,
  );
  return CartRepository(apiClient);
});
