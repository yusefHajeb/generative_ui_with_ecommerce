/// This model is used to maintain conversation context when processing
/// new messages with the AI service.
class ConversationPair {
  final String userMessage;
  final String assistantResponse;

  final DateTime timestamp;

  ConversationPair({
    required this.userMessage,
    required this.assistantResponse,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConversationPair.fromJson(Map<String, dynamic> json) {
    return ConversationPair(
      userMessage: json['userMessage'] as String? ?? '',
      assistantResponse: json['assistantResponse'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userMessage': userMessage,
      'assistantResponse': assistantResponse,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
