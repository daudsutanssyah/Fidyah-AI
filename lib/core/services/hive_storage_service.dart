import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fidyah_ai/features/chat/models/chat_session.dart';

class HiveStorageService {
  static const String _sessionBoxName = 'chat_sessions_box';

  /// Initializes Hive and opens the required boxes.
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_sessionBoxName);
  }

  Box<String> get _sessionBox => Hive.box<String>(_sessionBoxName);

  /// Saves a ChatSession to local storage.
  Future<void> saveSession(ChatSession session) async {
    final jsonStr = jsonEncode(session.toJson());
    await _sessionBox.put(session.id, jsonStr);
  }

  /// Retrieves all ChatSessions from local storage, sorted by latest updated.
  List<ChatSession> getAllSessions() {
    final sessions = <ChatSession>[];
    for (final jsonStr in _sessionBox.values) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        sessions.add(ChatSession.fromJson(jsonMap));
      } catch (e) {
        // Skip invalid data
        continue;
      }
    }

    // Sort by latest update descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  /// Retrieves a specific ChatSession by ID.
  ChatSession? getSession(String id) {
    final jsonStr = _sessionBox.get(id);
    if (jsonStr == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return ChatSession.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Deletes a ChatSession from local storage.
  Future<void> deleteSession(String id) async {
    await _sessionBox.delete(id);
  }

  /// Clears all ChatSessions.
  Future<void> clearAllSessions() async {
    await _sessionBox.clear();
  }
}
