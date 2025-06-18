import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage {
  static Future<Map<String, dynamic>> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return {'ids': [], 'timestamp': null};
    final parsed = jsonDecode(data);
    return {
      'ids': List<String>.from(parsed['ids']),
      'timestamp': parsed['timestamp'],
    };
  }

  static Future<void> save(String key, List<String> ids, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({'ids': ids, 'timestamp': timestamp});
    await prefs.setString(key, data);
  }
}