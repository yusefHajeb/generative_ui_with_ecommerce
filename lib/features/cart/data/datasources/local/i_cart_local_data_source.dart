import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

/// Abstract interface for local cart data operations
abstract class ICartLocalDataSource {
  /// Get cart from local storage
  Future<Either<Failure, Cart>> getCart();

  /// Save cart to local storage
  Future<Either<Failure, void>> saveCart(Cart cart);

  /// Clear cart from local storage
  Future<Either<Failure, void>> clearCart();
}
