import '../../../../core/network/base_model.dart';

class CartProduct extends BaseModel {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  /// Returns a copy of this [CartProduct] with the given fields replaced by
  /// the non-null values provided.
  CartProduct copyWith({
    int? id,
    String? title,
    double? price,
    int? quantity,
    double? total,
    double? discountPercentage,
    double? discountedTotal,
    String? thumbnail,
  }) {
    return CartProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      discountedTotal: (json['discountedTotal'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
    );
  }

  // Helper methods
  double get unitSavings => (price * discountPercentage / 100);
  bool get hasDiscount => discountPercentage > 0;
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDiscountedTotal => '\$${discountedTotal.toStringAsFixed(2)}';

  double? get originalPrice {
    if (!hasDiscount) return null;
    // originalPrice = price / (1 - discountPercentage/100)
    final denom = 1 - (discountPercentage / 100);
    if (denom == 0) return null;
    return price / denom;
  }

  /// Formatted original price for display. Falls back to the formatted
  /// current price when there's no discount.
  String get formattedOriginalPrice {
    final op = originalPrice;
    return op != null ? '\$${op.toStringAsFixed(2)}' : formattedPrice;
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return CartProduct.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }
}
