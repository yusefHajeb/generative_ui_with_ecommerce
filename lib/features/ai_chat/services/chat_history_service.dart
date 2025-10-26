import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/data/models/chat_message.dart';

class ChatHistoryService {
  static const String _chatSessionsKey = 'chat_sessions';
  static const String _currentSessionKey = 'current_session_id';
  static const int _maxMessagesPerSession = 100;
  Future<void> saveMessage(ChatMessage message) async {
    final currentSessionId = await getCurrentSessionId();

    final messages = await getMessagesForSession(currentSessionId);

    messages.add(message);

    if (messages.length > _maxMessagesPerSession) {
      messages.removeRange(0, messages.length - _maxMessagesPerSession);
    }

    await _saveMessagesForSession(currentSessionId, messages);

    await _updateSessionMetadata(currentSessionId, messages);
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final currentSessionId = await getCurrentSessionId();

    await _saveMessagesForSession(currentSessionId, messages);
    await _updateSessionMetadata(currentSessionId, messages);
  }

  Future<List<ChatMessage>> loadCurrentSession() async {
    final currentSessionId = await getCurrentSessionId();
    return await getMessagesForSession(currentSessionId);
  }

  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'session_$sessionId';
    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => _messageFromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading session $sessionId: $e');
      return [];
    }
  }

  Future<void> _saveMessagesForSession(String sessionId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'session_$sessionId';
    final jsonList = messages.map((msg) => _messageToJson(msg)).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(key, jsonString);
  }

  Future<String> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_currentSessionKey);

    if (sessionId == null) {
      sessionId = _generateSessionId();
      await prefs.setString(_currentSessionKey, sessionId);
    }

    return sessionId;
  }

  Future<String> createNewSession() async {
    final prefs = await SharedPreferences.getInstance();
    final newSessionId = _generateSessionId();
    await prefs.setString(_currentSessionKey, newSessionId);

    final sessions = await getAllSessions();
    sessions.add(
      ChatSession(
        id: newSessionId,
        title: 'New Chat',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageCount: 0,
      ),
    );
    await _saveSessions(sessions);

    return newSessionId;
  }

  Future<void> switchToSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionKey, sessionId);
  }

  Future<List<ChatSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_chatSessionsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      return [];
    }
  }

  Future<void> _updateSessionMetadata(String sessionId, List<ChatMessage> messages) async {
    final sessions = await getAllSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);

    if (sessionIndex == -1) {
      sessions.add(
        ChatSession(
          id: sessionId,
          title: _generateSessionTitle(messages),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messageCount: messages.length,
        ),
      );
    } else {
      sessions[sessionIndex] = ChatSession(
        id: sessionId,
        title: sessions[sessionIndex].title == 'New Chat'
            ? _generateSessionTitle(messages)
            : sessions[sessionIndex].title,
        createdAt: sessions[sessionIndex].createdAt,
        updatedAt: DateTime.now(),
        messageCount: messages.length,
      );
    }

    await _saveSessions(sessions);
  }

  Future<void> _saveSessions(List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_chatSessionsKey, jsonString);
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('session_$sessionId');

    final sessions = await getAllSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions(sessions);

    final currentId = await getCurrentSessionId();
    if (currentId == sessionId) {
      await createNewSession();
    }
  }

  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();

    for (final session in sessions) {
      await prefs.remove('session_${session.id}');
    }

    await prefs.remove(_chatSessionsKey);
    await prefs.remove(_currentSessionKey);

    await createNewSession();
  }

  Future<List<SearchResult>> searchMessages(String query) async {
    final results = <SearchResult>[];
    final sessions = await getAllSessions();

    for (final session in sessions) {
      final messages = await getMessagesForSession(session.id);
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.text.toLowerCase().contains(query.toLowerCase())) {
          results.add(
            SearchResult(
              message: message,
              sessionId: session.id,
              sessionTitle: session.title,
              messageIndex: i,
            ),
          );
        }
      }
    }

    return results;
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateSessionTitle(List<ChatMessage> messages) {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => ChatMessage(text: 'New Chat', isUser: true, timestamp: DateTime.now()),
    );

    String title = firstUserMessage.text.trim();
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }

    return title.isEmpty ? 'New Chat' : title;
  }

  Map<String, dynamic> _messageToJson(ChatMessage message) {
    return {
      'text': message.text,
      'isUser': message.isUser,
      'timestamp': message.timestamp.toIso8601String(),
      'isError': message.isError,
      'isLoading': message.isLoading,
      'data': message.data != null
          ? {'type': message.data!.type, 'content': message.data!.content}
          : null,
    };
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
      isLoading: json['isLoading'] ?? false,
      data: json['data'] != null
          ? ChatMessageData(type: json['data']['type'] ?? 'text', content: json['data']['content'])
          : null,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messageCount: json['messageCount'] ?? 0,
    );
  }
}

class SearchResult {
  final ChatMessage message;
  final String sessionId;
  final String sessionTitle;
  final int messageIndex;

  SearchResult({
    required this.message,
    required this.sessionId,
    required this.sessionTitle,
    required this.messageIndex,
  });
}
