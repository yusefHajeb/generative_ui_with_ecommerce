import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/meta.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/review_model.dart'
    show Review;

class ProductModel extends BaseModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final int weight;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final Meta meta;
  final List<String> images;
  final String thumbnail;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? "",
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      tags: (json['tags'] as List).cast<String>(),
      brand: json['brand']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      weight: json['weight'] as int,
      warrantyInformation: json['warrantyInformation']?.toString() ?? '',
      shippingInformation: json['shippingInformation']?.toString() ?? '',
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList(),
      returnPolicy: json['returnPolicy']?.toString() ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] as int,
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      images: (json['images'] as List).cast<String>(),
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'meta': meta.toJson(),
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ProductModel.fromJson(json);
  }

  // Helper methods
  double get discountedPrice {
    return price - (price * discountPercentage / 100);
  }

  bool get isInStock => availabilityStatus.toLowerCase().contains('in stock');

  bool get hasDiscount => discountPercentage > 0;

  int get reviewCount => reviews.length;

  double get averageRating {
    if (reviews.isEmpty) return rating;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }
}
