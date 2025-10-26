import '../../../../../core/network/base_model.dart';

class ChatMessage extends BaseModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final bool isLoading;
  final ChatMessageData? data;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.isLoading = false,
    this.data,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isError: json['isError'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      data: json['data'] != null
          ? ChatMessageData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'isLoading': isLoading,
      if (data != null) 'data': data!.toJson(),
    };
  }

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isError,
    bool? isLoading,
    ChatMessageData? data,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ChatMessage.fromJson(json);
  }
}

class ChatMessageData extends BaseModel {
  final String type;
  final dynamic content;

  ChatMessageData({required this.type, required this.content});

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(type: json['type'] as String? ?? '', content: json['content']);
  }
  dynamic getType(String type, Map<String, dynamic> json) {
    if (type == 'recommendations') {
      return json['products'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'content': content};
  }

  ChatMessageData copyWith({String? type, dynamic content}) {
    return ChatMessageData(type: type ?? this.type, content: content ?? this.content);
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ChatMessageData.fromJson(json);
  }
}
