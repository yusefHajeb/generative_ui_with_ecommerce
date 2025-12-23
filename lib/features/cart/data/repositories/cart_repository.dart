import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/network/dio_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/endpoints.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/local/cart_local_data_source_impl.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/local/i_cart_local_data_source.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/remote/i_cart_remote_data_source.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

import '../datasources/remote/cart_remote_data_source_impl.dart';
import '../models/cart_product.dart';

/// Repository for cart data operations
class CartRepository {
  final ICartLocalDataSource localDataSource;
  final ICartRemoteDataSource remoteDataSource;

  CartRepository({required this.localDataSource, required this.remoteDataSource});

  Future<Either<Failure, Cart>> getCart() async {
    // Try to get from remote first
    final remoteResult = await remoteDataSource.getCart(1); // Assuming userId = 1 for now
    return remoteResult.fold(
      (failure) async {
        log('Remote cart fetch failed, falling back to local: ${failure.message}');
        return await localDataSource.getCart();
      },
      (cart) async {
        // If remote succeeds, sync with local
        await localDataSource.saveCart(cart);
        return Right(cart);
      },
    );
  }

  /// Add product to cart
  Future<Either<Failure, Cart>> addToCart(ProductModel product, int quantity) async {
    try {
      final cartResult = await getCart();
      return cartResult.fold((failure) => Left(failure), (cart) async {
        final updatedCart = _addProductToCart(cart, product, quantity);

        final remoteResult = await remoteDataSource.addToCart(cart.userId, product.id, quantity);
        remoteResult.fold(
          (failure) => log('Failed to sync add to remote: ${failure.message}'),
          (remoteCart) => log('Successfully synced add to remote'),
        );

        // Always save locally
        final localResult = await localDataSource.saveCart(updatedCart);
        return localResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
      });
    } catch (e) {
      log('error in repository');
      return Left(CacheFailure(message: 'Failed to add product to cart: ${e.toString()}'));
    }
  }

  /// Update product quantity in cart
  Future<Either<Failure, Cart>> updateQuantity(int productId, int quantity) async {
    try {
      final cartResult = await getCart();
      return cartResult.fold((failure) => Left(failure), (cart) async {
        final updatedCart = _updateProductQuantity(cart, productId, quantity);

        final remoteResult = await remoteDataSource.updateQuantity(
          cart.userId,
          productId,
          quantity,
        );
        remoteResult.fold(
          (failure) => log('Failed to sync update to remote: ${failure.message}'),
          (remoteCart) => log('Successfully synced update to remote'),
        );

        // Always save locally
        final localResult = await localDataSource.saveCart(updatedCart);
        return localResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
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

        final remoteResult = await remoteDataSource.removeFromCart(cart.userId, productId);
        remoteResult.fold(
          (failure) => log('Failed to sync remove to remote: ${failure.message}'),
          (remoteCart) => log('Successfully synced remove to remote'),
        );

        // Always save locally
        final localResult = await localDataSource.saveCart(updatedCart);
        return localResult.fold((failure) => Left(failure), (_) => Right(updatedCart));
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

      final remoteResult = await remoteDataSource.clearCart(1);
      remoteResult.fold(
        (failure) => log('Failed to sync clear to remote: ${failure.message}'),
        (remoteCart) => log('Successfully synced clear to remote'),
      );

      // Always clear locally
      final localResult = await localDataSource.saveCart(emptyCart);
      return localResult.fold((failure) => Left(failure), (_) => Right(emptyCart));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Cart>> syncCartWithRemote() async {
    try {
      final localCartResult = await localDataSource.getCart();
      return localCartResult.fold((failure) => Left(failure), (localCart) async {
        final remoteResult = await remoteDataSource.syncCart(localCart);
        return remoteResult.fold((failure) => Left(failure), (syncedCart) async {
          // Update local with synced data
          await localDataSource.saveCart(syncedCart);
          return Right(syncedCart);
        });
      });
    } catch (e) {
      return Left(ServerFailure('Failed to sync cart with remote: ${e.toString()}'));
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
    } else {
      // Add new product
      final newCartProduct = CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: quantity,
        total: product.price * quantity,
        discountPercentage: product.discountPercentage,
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
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = DioClientFactory.createApiClient(
    baseUrl: ApiEndpoints.baseUrl,
    enableLogging: true,
    enableAuth: false,
    enableRetry: true,
    enableCache: false,
  );

  final localDataSource = CartLocalDataSourceImpl();
  final remoteDataSource = CartRemoteDataSourceImpl(apiClient);

  return CartRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource);
});
