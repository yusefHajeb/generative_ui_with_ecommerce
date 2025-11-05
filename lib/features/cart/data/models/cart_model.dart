import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

import 'cart_product.dart';

class Cart extends BaseModel {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  /// Returns a copy of this [Cart] with the given fields replaced by the
  /// non-null values provided.
  Cart copyWith({
    int? id,
    List<CartProduct>? products,
    double? total,
    double? discountedTotal,
    int? userId,
    int? totalProducts,
    int? totalQuantity,
  }) {
    return Cart(
      id: id ?? this.id,
      products: products ?? List<CartProduct>.from(this.products),
      total: total ?? this.total,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      userId: userId ?? this.userId,
      totalProducts: totalProducts ?? this.totalProducts,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      products: (json['products'] as List)
          .map((product) => CartProduct.fromJson(product as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      discountedTotal: (json['discountedTotal'] as num).toDouble(),
      userId: json['userId'] as int,
      totalProducts: json['totalProducts'] as int,
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  // Helper methods
  double get totalSavings => total - discountedTotal;
  bool get hasDiscount => discountedTotal < total;
  bool get isEmpty => products.isEmpty;
  // In Cart class
  double get totalOriginalPrice {
    return products.fold(0.0, (sum, p) => sum + ((p.originalPrice ?? p.price) * p.quantity));
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return Cart.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((p) => p.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}
