import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

class AiResponse extends BaseModel {
  final String type;
  final String? message;
  final Map<String, dynamic>? data;

  AiResponse({required this.type, this.message, this.data});

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      type: json['type'] as String? ?? 'text',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, if (message != null) 'message': message, if (data != null) 'data': data};
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return AiResponse.fromJson(json);
  }
}

class ToolCallResponse extends AiResponse {
  final String tool;
  final Map<String, dynamic> arguments;

  ToolCallResponse({
    required this.tool,
    required this.arguments,
    String? message,
    Map<String, dynamic>? data,
  }) : super(type: tool, message: message, data: data);
  // todo : copyWith
  factory ToolCallResponse.fromJson(Map<String, dynamic> json) {
    return ToolCallResponse(
      tool: json['tool'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'tool': tool, 'arguments': arguments};
  }
}

class TextResponse extends AiResponse {
  TextResponse({required String message}) : super(type: 'text', message: message);
}

class ErrorResponse extends AiResponse {
  ErrorResponse({required String message}) : super(type: 'error', message: message);
}
