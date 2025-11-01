import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

class KnowledgeFeature {
  final String name;
  final String icon;
  final String description;

  KnowledgeFeature({required this.name, required this.icon, required this.description});

  factory KnowledgeFeature.fromJson(Map<String, dynamic> json) {
    return KnowledgeFeature(
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '•',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'icon': icon, 'description': description};
  }
}

class KnowledgeTip {
  final String title;
  final String icon;
  final String description;

  KnowledgeTip({required this.title, required this.icon, required this.description});

  factory KnowledgeTip.fromJson(Map<String, dynamic> json) {
    return KnowledgeTip(
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '💡',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'icon': icon, 'description': description};
  }
}

class KnowledgeData extends BaseModel {
  final String title;
  final String? tagline;
  final String? description;
  final List<KnowledgeFeature>? features;
  final List<String>? tips;

  KnowledgeData({required this.title, this.tagline, this.description, this.features, this.tips});

  factory KnowledgeData.fromJson(Map<String, dynamic> json) {
    return KnowledgeData(
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String?,
      description: json['description'] as String?,
      features: (json['features'] as List?)
          ?.map((item) => KnowledgeFeature.fromJson(item))
          .toList(),
      tips: (json['tips'] as List<dynamic>?)?.map((item) => item.toString()).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (tagline != null) 'tagline': tagline,
      if (description != null) 'description': description,
      if (features != null) 'features': features!.map((f) => f.toJson()).toList(),
      if (tips != null) 'tips': tips,
    };
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return KnowledgeData.fromJson(json);
  }
}
