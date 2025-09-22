import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'logger.dart';

class SharedPreference {
  static SharedPreferences? _prefs;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.infoGlobal('SharedPreference', 'SharedPreferences initialized');
  }
  
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call initialize() first.');
    }
    return _prefs!;
  }
  
  // String operations
  static Future<bool> setString(String key, String value) async {
    try {
      return await instance.setString(key, value);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set string for key $key: $e');
      return false;
    }
  }
  
  static String? getString(String key, {String? defaultValue}) {
    try {
      return instance.getString(key) ?? defaultValue;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get string for key $key: $e');
      return defaultValue;
    }
  }
  
  // Integer operations
  static Future<bool> setInt(String key, int value) async {
    try {
      return await instance.setInt(key, value);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set int for key $key: $e');
      return false;
    }
  }
  
  static int? getInt(String key, {int? defaultValue}) {
    try {
      return instance.getInt(key) ?? defaultValue;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get int for key $key: $e');
      return defaultValue;
    }
  }
  
  // Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    try {
      return await instance.setBool(key, value);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set bool for key $key: $e');
      return false;
    }
  }
  
  static bool? getBool(String key, {bool? defaultValue}) {
    try {
      return instance.getBool(key) ?? defaultValue;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get bool for key $key: $e');
      return defaultValue;
    }
  }
  
  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    try {
      return await instance.setDouble(key, value);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set double for key $key: $e');
      return false;
    }
  }
  
  static double? getDouble(String key, {double? defaultValue}) {
    try {
      return instance.getDouble(key) ?? defaultValue;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get double for key $key: $e');
      return defaultValue;
    }
  }
  
  // List operations
  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await instance.setStringList(key, value);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set string list for key $key: $e');
      return false;
    }
  }
  
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      return instance.getStringList(key) ?? defaultValue;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get string list for key $key: $e');
      return defaultValue;
    }
  }
  
  // JSON operations
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to set JSON for key $key: $e');
      return false;
    }
  }
  
  static Map<String, dynamic>? getJson(String key, {Map<String, dynamic>? defaultValue}) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return defaultValue;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get JSON for key $key: $e');
      return defaultValue;
    }
  }
  
  // Remove operations
  static Future<bool> remove(String key) async {
    try {
      return await instance.remove(key);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to remove key $key: $e');
      return false;
    }
  }
  
  static Future<bool> clear() async {
    try {
      return await instance.clear();
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to clear preferences: $e');
      return false;
    }
  }
  
  // Check if key exists
  static bool containsKey(String key) {
    try {
      return instance.containsKey(key);
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to check if key $key exists: $e');
      return false;
    }
  }
  
  // Get all keys
  static Set<String> getKeys() {
    try {
      return instance.getKeys();
    } catch (e) {
      Logger.errorGlobal('SharedPreference', 'Failed to get all keys: $e');
      return <String>{};
    }
  }
}