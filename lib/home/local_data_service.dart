import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDataService {
  static const String _personalBestKey = 'training_personal_bests';
  static const String _tierProgressKey = 'training_tier_progress';

  static Future<void> savePersonalBest(String gameId, double score) async {
    final prefs = await SharedPreferences.getInstance();
    final String? pbJson = prefs.getString(_personalBestKey);
    Map<String, double> pbs = {};
    if (pbJson != null) {
      pbs = Map<String, double>.from(jsonDecode(pbJson));
    }
    
    if (!pbs.containsKey(gameId) || score > pbs[gameId]!) {
      pbs[gameId] = score;
      await prefs.setString(_personalBestKey, jsonEncode(pbs));
    }
  }

  static Future<Map<String, double>> getPersonalBests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pbJson = prefs.getString(_personalBestKey);
    if (pbJson == null) return {};
    return Map<String, double>.from(jsonDecode(pbJson));
  }

  static Future<void> resetPersonalBests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_personalBestKey);
  }

  static Future<void> recordSessionSuccess(int tier, bool success) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_tierProgressKey}_$tier';
    List<bool> history = [];
    final String? historyJson = prefs.getString(key);
    if (historyJson != null) {
      history = List<bool>.from(jsonDecode(historyJson));
    }
    
    history.add(success);
    if (history.length > 3) {
      history.removeAt(0);
    }
    
    await prefs.setString(key, jsonEncode(history));
  }

  static Future<void> resetTierProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlocked_tier');
    // Also remove individual tier history if needed, though 'unlocked_tier' is the main one
    for (int i = 0; i < 3; i++) {
      await prefs.remove('${_tierProgressKey}_$i');
    }
  }

  static Future<bool> shouldUnlockNextTier(int currentTier) async {
    if (currentTier >= 2) return false;
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_tierProgressKey}_$currentTier';
    final String? historyJson = prefs.getString(key);
    if (historyJson == null) return false;
    
    List<bool> history = List<bool>.from(jsonDecode(historyJson));
    if (history.length < 3) return false;
    
    return history.every((element) => element == true);
  }

  static Future<int> getUnlockedTier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlocked_tier') ?? 0;
  }

  static Future<void> setUnlockedTier(int tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlocked_tier', tier);
  }
}
