import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  // Factory constructor
  factory StorageService() {
    return _instance;
  }
  // Internal constructor
  StorageService._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheExpiry = {};
  final Duration cacheDuration = const Duration(hours: 1);

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('cache');
    if (cacheString != null) {
      final cacheData = json.decode(cacheString) as Map<String, dynamic>;
      _cache.addAll(cacheData);
    }
    final cacheExpiryString = prefs.getString('cacheExpiry');
    if (cacheExpiryString != null) {
      final cacheExpiryData =
          json.decode(cacheExpiryString) as Map<String, dynamic>;
      cacheExpiryData.forEach((key, value) {
        _cacheExpiry[key] = DateTime.parse(value);
      });
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache', json.encode(_cache));
    final cacheExpiryData = _cacheExpiry.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    );
    prefs.setString('cacheExpiry', json.encode(cacheExpiryData));
  }

  Future<void> saveGame(WidgetPlateau board, Duration time, int score,  ) async {
  }

  Future<dynamic> loadGame(String key) async {
  }

  
}