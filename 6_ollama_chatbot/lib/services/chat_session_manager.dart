import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

class ChatSessionManager {
  static const String _sessionsKey = 'chat_sessions_list_v2';
  static const String _currentSessionKey = 'current_session_id_v2';

  // Load all sessions
  Future<List<ChatSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      return sessionsJson
          .map((json) => ChatSession.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  // Save all sessions
  Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_sessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving sessions: $e');
    }
  }

  // Create a new session
  Future<ChatSession> createNewSession(
    List<ChatSession> existingSessions,
  ) async {
    final sessionNumber = existingSessions.length + 1;
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Chat $sessionNumber',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    final updatedSessions = [...existingSessions, newSession];
    await saveSessions(updatedSessions);
    await setCurrentSessionId(newSession.id);

    return newSession;
  }

  // Update an existing session
  Future<void> updateSession(
    ChatSession session,
    List<ChatSession> allSessions,
  ) async {
    final index = allSessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      // If the session contains no non-empty text messages, remove it from persisted list
      final hasNonEmpty = session.messages.any(
        (m) => m.content.trim().isNotEmpty,
      );
      if (hasNonEmpty) {
        allSessions[index] = session.copyWith(updatedAt: DateTime.now());
      } else {
        allSessions.removeAt(index);
      }

      await saveSessions(allSessions);
    }
  }

  // Get current session ID
  Future<String?> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentSessionKey);
  }

  // Set current session ID
  Future<void> setCurrentSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionKey, sessionId);
  }

  // Delete a session
  Future<void> deleteSession(
    String sessionId,
    List<ChatSession> allSessions,
  ) async {
    allSessions.removeWhere((s) => s.id == sessionId);
    await saveSessions(allSessions);
  }
}
