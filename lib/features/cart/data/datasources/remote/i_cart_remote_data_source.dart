import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

/// Abstract interface for remote cart data operations
abstract class ICartRemoteDataSource {
  /// Get cart from remote server
  Future<Either<Failure, Cart>> getCart(int userId);

  /// Sync local cart with remote server
  Future<Either<Failure, Cart>> syncCart(Cart localCart);

  /// Add product to remote cart
  Future<Either<Failure, Cart>> addToCart(int userId, int productId, int quantity);

  /// Update product quantity in remote cart
  Future<Either<Failure, Cart>> updateQuantity(int userId, int productId, int quantity);

  /// Remove product from remote cart
  Future<Either<Failure, Cart>> removeFromCart(int userId, int productId);

  /// Clear remote cart
  Future<Either<Failure, Cart>> clearCart(int userId);
}
