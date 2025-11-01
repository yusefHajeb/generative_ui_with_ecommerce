/// Custom exceptions for AI Chat feature

class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  GeminiApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() =>
      'GeminiApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ToolExecutionException implements Exception {
  final String message;
  final String toolName;
  final Map<String, dynamic>? arguments;

  ToolExecutionException(this.message, this.toolName, {this.arguments});

  @override
  String toString() => 'ToolExecutionException: $message (Tool: $toolName)';
}

class EcommerceApiException implements Exception {
  final String message;
  final String apiName;
  final int? statusCode;

  EcommerceApiException(this.message, this.apiName, {this.statusCode});

  @override
  String toString() =>
      'EcommerceApiException: $message (API: $apiName${statusCode != null ? ', Status: $statusCode' : ''})';
}

class ChatHistoryException implements Exception {
  final String message;
  final String operation;

  ChatHistoryException(this.message, this.operation);

  @override
  String toString() => 'ChatHistoryException: $message (Operation: $operation)';
}
