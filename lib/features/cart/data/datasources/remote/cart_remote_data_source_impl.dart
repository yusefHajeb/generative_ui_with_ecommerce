import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_service.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/datasources/remote/i_cart_remote_data_source.dart';
import 'package:generative_ui_with_ecommerce/features/cart/data/models/cart_model.dart';

/// Implementation of remote cart data source using NetworkService
class CartRemoteDataSourceImpl extends NetworkService implements ICartRemoteDataSource {
  CartRemoteDataSourceImpl(super.apiClient);

  @override
  Future<Either<Failure, Cart>> getCart(int userId) async {
    try {
      final response = await handleListApiRequests<Cart>(
        httpMethod: HttpMethod.get,
        endPoint: '/carts/user/$userId',
        fromJson: (data) => Cart.fromJson(data as Map<String, dynamic>),
      );

      return response.fold((failure) => Left(failure), (carts) {
        if (carts.isNotEmpty) {
          return Right(carts.first);
        } else {
          // Return empty cart if no remote cart exists
          return Right(
            Cart(
              id: 1,
              products: [],
              total: 0.0,
              discountedTotal: 0.0,
              userId: userId,
              totalProducts: 0,
              totalQuantity: 0,
            ),
          );
        }
      });
    } catch (e) {
      return Left(ServerFailure('Failed to fetch cart from server: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> syncCart(Cart localCart) async {
    try {
      final response = await handleBaseModelApiRequests<Cart>(
        httpMethod: HttpMethod.post,
        endPoint: '/carts',
        fromJson: Cart.fromJson,
        data: localCart.toJson(),
      );
      return response;
    } catch (e) {
      return Left(ServerFailure('Failed to sync cart with server: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> addToCart(int userId, int productId, int quantity) async {
    try {
      final requestData = {
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      };

      final response = await handleBaseModelApiRequests<Cart>(
        httpMethod: HttpMethod.post,
        endPoint: '/carts',
        fromJson: Cart.fromJson,
        data: requestData,
      );
      return response;
    } catch (e) {
      return Left(ServerFailure('Failed to add product to remote cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateQuantity(int userId, int productId, int quantity) async {
    try {
      final requestData = {
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      };

      final response = await handleBaseModelApiRequests<Cart>(
        httpMethod: HttpMethod.put,
        endPoint: '/carts',
        fromJson: Cart.fromJson,
        data: requestData,
      );
      return response;
    } catch (e) {
      return Left(
        ServerFailure('Failed to update product quantity in remote cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(int userId, int productId) async {
    try {
      final response = await handleVoidApiRequests(
        httpMethod: HttpMethod.delete,
        endPoint: '/carts/$userId/products/$productId',
      );

      return response.fold((failure) => Left(failure), (_) async {
        // After successful deletion, fetch the updated cart
        return await getCart(userId);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to remove product from remote cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart(int userId) async {
    try {
      final response = await handleVoidApiRequests(
        httpMethod: HttpMethod.delete,
        endPoint: '/carts/$userId',
      );

      return response.fold((failure) => Left(failure), (_) {
        // Return empty cart after successful clearing
        return Right(
          Cart(
            id: 1,
            products: [],
            total: 0.0,
            discountedTotal: 0.0,
            userId: userId,
            totalProducts: 0,
            totalQuantity: 0,
          ),
        );
      });
    } catch (e) {
      return Left(ServerFailure('Failed to clear remote cart: ${e.toString()}'));
    }
  }
}
