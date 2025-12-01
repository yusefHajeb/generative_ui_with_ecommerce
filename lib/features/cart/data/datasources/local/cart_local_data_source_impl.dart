import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/helper/shared_prefrence.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/local/i_cart_local_data_source.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

/// Implementation of local cart data source using SharedPreferences
class CartLocalDataSourceImpl implements ICartLocalDataSource {
  static const String _cartKey = 'cart_data';

  @override
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
      return Left(CacheFailure(message: 'Failed to load cart from local storage: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCart(Cart cart) async {
    try {
      final cartJson = jsonEncode(cart.toJson());
      await SharedPrefrenceHelper.setData(_cartKey, cartJson);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save cart to local storage: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await SharedPrefrenceHelper.remove(_cartKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cart from local storage: ${e.toString()}'));
    }
  }
}
