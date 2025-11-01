import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';

class RecommendationData extends BaseModel {
  final List<ProductModel> products;
  final String type;

  RecommendationData({required this.products, required this.type});

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    final products = (json['products'] as List? ?? [])
        .map((item) => ProductModel.fromJson(item))
        .toList();

    return RecommendationData(products: products, type: json['type']);
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return RecommendationData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"products": products.map((product) => product.toJson()).toList(), "type": type};
  }
}
