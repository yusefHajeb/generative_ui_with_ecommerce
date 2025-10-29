import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

class CategoryModel extends BaseModel {
  final String name;
  final String slug;
  final String? url;

  CategoryModel({required this.name, required this.slug, required this.url});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      url: json['url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug, 'url': url};
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return CategoryModel.fromJson(json);
  }
}

class CategoriesData extends BaseModel {
  final List<CategoryModel> categories;
  final List<ProductModel> sampleProducts;
  final int? total;
  final bool? showSampleProduct;

  CategoriesData({
    required this.categories,
    required this.sampleProducts,
    this.showSampleProduct,
    this.total,
  });

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    return CategoriesData(
      total: json['total'] ?? 0,
      showSampleProduct: json['showProducts'] ?? false,
      categories:
          (json['categories'] as List?)?.map((item) => CategoryModel.fromJson(item)).toList() ?? [],
      sampleProducts: (json['sampleProducts'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((c) => c.toJson()).toList(),
      'sampleProducts': sampleProducts.map((product) => product.toJson()).toList(),
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return CategoriesData.fromJson(json);
  }
}
