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

  Future<int> saveGame(int id, Map<String, dynamic> settings, Map<String, dynamic> current) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = await _getGameIds(prefs);

    if (id == -1) {
      // Generate a new id
      id = ids.isEmpty ? 1 : ids.length + 1;
      ids.add(id.toString());
      await _setGameIds(prefs, ids);
    }

    final key = 'game-$id';
    final data = {
      'settings': settings,
      'current': current,
    };
    final dataString = json.encode(data);
    await prefs.setString(key, dataString);
    return id;
  }

  Future<List<String>> _getGameIds(SharedPreferences prefs) async {
    return prefs.getStringList('game-ids') ?? [];
  }

  Future<void> _setGameIds(SharedPreferences prefs, List<String> ids) async {
    await prefs.setStringList('game-ids', ids);
  }

  Future<Map<String, dynamic>> loadGame(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game-$id';
    final dataString = prefs.getString(key);
    if (dataString == null) {
      return {};
    }
    final data = json.decode(dataString) as Map<String, dynamic>;
    return data;
  }
}