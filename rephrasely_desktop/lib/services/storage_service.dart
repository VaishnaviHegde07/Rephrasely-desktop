import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }

    return AppSettings();
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  Future<bool> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_settingsKey);
    } catch (e) {
      print('Error clearing settings: $e');
      return false;
    }
  }

  // Generic data storage methods
  Future<dynamic> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(key);

      if (dataJson != null) {
        return jsonDecode(dataJson);
      }
    } catch (e) {
      print('Error loading data for key $key: $e');
    }

    return null;
  }

  Future<bool> saveData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = jsonEncode(data);
      return await prefs.setString(key, dataJson);
    } catch (e) {
      print('Error saving data for key $key: $e');
      return false;
    }
  }

  Future<bool> removeData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('Error removing data for key $key: $e');
      return false;
    }
  }
}
