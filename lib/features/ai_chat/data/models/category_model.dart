import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

class CategoryModel extends BaseModel {
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int? productCount;

  CategoryModel({
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      productCount: json['productCount'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (productCount != null) 'productCount': productCount,
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return CategoryModel.fromJson(json);
  }
}

class CategoriesData {
  final List<CategoryModel> categories;
  final List<dynamic> sampleProducts;

  CategoriesData({required this.categories, required this.sampleProducts});

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    return CategoriesData(
      categories:
          (json['categories'] as List?)?.map((item) => CategoryModel.fromJson(item)).toList() ?? [],
      sampleProducts: json['sampleProducts'] as List? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((c) => c.toJson()).toList(),
      'sampleProducts': sampleProducts,
    };
  }
}
