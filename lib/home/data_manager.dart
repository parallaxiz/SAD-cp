import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FocusSession {
  final int durationSeconds;
  final DateTime timestamp;

  FocusSession({required this.durationSeconds, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'durationSeconds': durationSeconds,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    durationSeconds: json['durationSeconds'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class DataManager {
  static List<FocusSession> sessions = [];
  static final ValueNotifier<int> sessionsChangedCounter = ValueNotifier(0);
  static const String _storageKey = 'focus_sessions_logs';
  static const String _nameKey = 'user_name';
  static const String _themeKey = 'dark_mode_enabled';

  static final ValueNotifier<String> userName = ValueNotifier("Sleep Voyager");
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Name
    final String? storedName = prefs.getString(_nameKey);
    if (storedName != null) {
      userName.value = storedName;
    }

    // Load Theme
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;

    // Load Sessions
    final String? sessionsJson = prefs.getString(_storageKey);
    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        sessions = decoded.map((item) => FocusSession.fromJson(item)).toList();
        sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        sessionsChangedCounter.value++;
      } catch (e) {
        debugPrint("Error loading sessions: $e");
      }
    }
  }

  static Future<void> updateName(String newName) async {
    userName.value = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
  }

  static Future<void> toggleDarkMode(bool enabled) async {
    isDarkMode.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, enabled);
  }

  static Future<void> addSession(int seconds) async {
    if (seconds < 1) return;
    
    final newSession = FocusSession(
      durationSeconds: seconds,
      timestamp: DateTime.now(),
    );
    
    sessions.insert(0, newSession);
    sessionsChangedCounter.value++;

    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static int getStreak() {
    if (sessions.isEmpty) return 0;
    
    final sortedSessions = sessions.map((s) => 
      DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day)
    ).toSet().toList()..sort((a, b) => b.compareTo(a));

    if (sortedSessions.isEmpty) return 0;
    
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (sortedSessions.first.isBefore(today.subtract(const Duration(days: 1)))) return 0;

    int currentStreak = 1;
    for (int i = 0; i < sortedSessions.length - 1; i++) {
      if (sortedSessions[i].difference(sortedSessions[i+1]).inDays == 1) {
        currentStreak++;
      } else {
        break;
      }
    }
    return currentStreak;
  }

  static int getTotalSecondsAllTime() {
    return sessions.fold(0, (sum, s) => sum + s.durationSeconds);
  }

  static int getTotalSecondsToday() {
    final now = DateTime.now();
    return sessions.where((s) => 
      s.timestamp.year == now.year && 
      s.timestamp.month == now.month && 
      s.timestamp.day == now.day
    ).fold(0, (sum, item) => sum + item.durationSeconds);
  }

  static int getTotalSecondsMonth() {
    final now = DateTime.now();
    return sessions.where((s) => 
      s.timestamp.year == now.year && 
      s.timestamp.month == now.month
    ).fold(0, (sum, item) => sum + item.durationSeconds);
  }

  static int getTotalSecondsYear() {
    final now = DateTime.now();
    return sessions.where((s) => 
      s.timestamp.year == now.year
    ).fold(0, (sum, item) => sum + item.durationSeconds);
  }

  static int getTotalSecondsPeriod(int days) {
    final threshold = DateTime.now().subtract(Duration(days: days));
    return sessions.where((s) => s.timestamp.isAfter(threshold))
        .fold(0, (sum, item) => sum + item.durationSeconds);
  }
}
