import 'dart:convert';
import 'dart:typed_data';
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

  Future<int> saveGame(int id, Map<String, dynamic> settings,
      Map<String, dynamic> current) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = await _getGameIds(prefs);

    if (id == -1) {
      // Generate a new id
      id = ids.isEmpty
          ? 1
          : (ids.map(int.parse).reduce((a, b) => a > b ? a : b) + 1);
      ids.add(id.toString());
      await _setGameIds(prefs, ids);
    }

    // Process image data for storage
    var processedCurrent = Map<String, dynamic>.from(current);

    // Convert image tiles to base64 strings for storage
    if (current['currentImage'] != null &&
        current['currentImage'] is List<Uint8List>) {
      List<String> base64Images = [];
      for (var imgData in current['currentImage']) {
        if (imgData is Uint8List) {
          base64Images.add(base64Encode(imgData));
        }
      }
      processedCurrent['currentImage'] = base64Images;
    }

    final key = 'game-$id';
    final data = {
      'settings': settings,
      'current': processedCurrent,
    };

    final dataString = json.encode(data);
    await prefs.setString(key, dataString);
    return id;
  }

  Future<void> deleteGame(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game-$id';
    await prefs.remove(key);

    List<String> ids = await _getGameIds(prefs);
    ids.remove(id.toString());
    await _setGameIds(prefs, ids);
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
    try {
      final data = json.decode(dataString) as Map<String, dynamic>;
      return data;
    } catch (e) {
      print('Error decoding game data: $e');
      return {};
    }
  }

  Future<String?> getImage(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game-$id';
    final dataString = prefs.getString(key);
    if (dataString == null) {
      return null;
    }
    final data = json.decode(dataString) as Map<String, dynamic>;
    return data['settings']['image'] as String?;
  }
}
