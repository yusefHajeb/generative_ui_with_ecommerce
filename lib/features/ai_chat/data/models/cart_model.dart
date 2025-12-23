import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

class CartItem extends BaseModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? description;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.description,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return CartItem.fromJson(json);
  }

  CartItem copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}

class CartData {
  final List<CartItem> items;
  final double total;
  final int itemCount;

  CartData({required this.items, required this.total, required this.itemCount});

  bool get isEmpty => items.isEmpty;

  factory CartData.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)?.map((item) => CartItem.fromJson(item)).toList() ?? [];

    return CartData(
      items: items,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: json['itemCount'] as int? ?? items.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'itemCount': itemCount,
    };
  }
}

class CartUpdateData {
  final String action;
  final String? productId;
  final int? quantity;
  final CartItem? item;

  CartUpdateData({required this.action, this.productId, this.quantity, this.item});

  factory CartUpdateData.fromJson(Map<String, dynamic> json) {
    return CartUpdateData(
      action: json['action'] as String? ?? '',
      productId: json['productId'] as String?,
      quantity: json['quantity'] as int?,
      item: json['item'] != null ? CartItem.fromJson(json['item']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      if (productId != null) 'productId': productId,
      if (quantity != null) 'quantity': quantity,
      if (item != null) 'item': item!.toJson(),
    };
  }
}
