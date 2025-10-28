import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';
import '../../../products/data/models/product.dart';

class SearchCriteria {
  final String? query;
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? inStock;
  final bool? onSale;
  final String? sortBy;
  final int? limit;

  SearchCriteria({
    this.query,
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.inStock,
    this.onSale,
    this.sortBy,
    this.limit,
  });

  factory SearchCriteria.fromJson(Map<String, dynamic> json) {
    return SearchCriteria(
      query: json['query'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRating: (json['minRating'] as num?)?.toDouble(),
      inStock: json['inStock'] as bool?,
      onSale: json['onSale'] as bool?,
      sortBy: json['sortBy'] as String?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (query != null) 'query': query,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minRating != null) 'minRating': minRating,
      if (inStock != null) 'inStock': inStock,
      if (onSale != null) 'onSale': onSale,
      if (sortBy != null) 'sortBy': sortBy,
      if (limit != null) 'limit': limit,
    };
  }

  bool get hasFilters =>
      query != null ||
      category != null ||
      brand != null ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      inStock != null ||
      onSale != null;
}

class ProductGridData extends BaseModel {
  final List<Product> products;
  final int totalResults;
  final bool hasMore;
  final SearchCriteria? searchCriteria;

  ProductGridData({
    required this.products,
    required this.totalResults,
    this.hasMore = false,
    this.searchCriteria,
  });

  bool get isEmpty => products.isEmpty;

  factory ProductGridData.fromJson(Map<String, dynamic> json) {
    return ProductGridData(
      products: (json['products'] as List?)?.map((item) => Product.fromJson(item)).toList() ?? [],
      totalResults: json['totalResults'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      searchCriteria: json['searchCriteria'] != null
          ? SearchCriteria.fromJson(json['searchCriteria'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'totalResults': totalResults,
      'hasMore': hasMore,
      if (searchCriteria != null) 'searchCriteria': searchCriteria!.toJson(),
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ProductGridData.fromJson(json);
  }
}

class ProductDetailsData extends BaseModel {
  final Product product;
  final List<String>? images;
  final List<String>? reviews;
  final Map<String, dynamic>? specifications;

  ProductDetailsData({required this.product, this.images, this.reviews, this.specifications});

  factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
    return ProductDetailsData(
      product: Product.fromJson(json['product']),
      images: (json['images'] as List?)?.cast<String>(),
      reviews: (json['reviews'] as List?)?.cast<String>(),
      specifications: json['specifications'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      if (images != null) 'images': images,
      if (reviews != null) 'reviews': reviews,
      if (specifications != null) 'specifications': specifications,
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ProductDetailsData.fromJson(json);
  }
}
