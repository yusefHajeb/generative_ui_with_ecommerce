import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

import '../../../products/data/models/product.dart' show Product;

class RecommendationData extends BaseModel {
  final List<Product> products;
  final String type;

  RecommendationData({required this.products, required this.type});

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    final products = (json['products'] as List? ?? [])
        .map((item) => Product.fromJson(item))
        .toList();

    return RecommendationData(products: products, type: json['type']);
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return RecommendationData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
