import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/auto_connect_model.dart';

class StorageHelper {
  static final GetStorage _storage = GetStorage();

  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _settingsKey = 'app_settings';
  static const String _dataUsageKey = 'data_usage';
  static const String _vpnConfigKey = 'vpn_config';
  static const String _serverListKey = 'server_list';
  static const String _lastConnectedServerKey = 'last_connected_server';
  static const String _connectionHistoryKey = 'connection_history';
  static const String _analyticsDataKey = 'analytics_data';
  static const String _preferencesKey = 'user_preferences';
  static const String _autoConnectSettingsKey = 'auto_connect_settings';

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Auth Token methods
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(_authTokenKey, token);
    if (kDebugMode) {
      print('Auth token saved');
    }
  }

  static Future<String?> getAuthToken() async {
    return _storage.read(_authTokenKey);
  }

  static Future<void> removeAuthToken() async {
    await _storage.remove(_authTokenKey);
  }

  // Alternative method name for compatibility
  static Future<String?> getToken() async {
    return getAuthToken();
  }

  // User Data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(_userDataKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return _storage.read(_userDataKey);
  }

  static Future<void> removeUserData() async {
    await _storage.remove(_userDataKey);
  }

  // Settings methods
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.write(_settingsKey, settings);
  }

  static Map<String, dynamic>? getSettings() {
    return _storage.read(_settingsKey);
  }

  // Data Usage methods
  static Future<void> saveDataUsage(Map<String, dynamic> dataUsage) async {
    await _storage.write(_dataUsageKey, dataUsage);
  }

  static Map<String, dynamic>? getDataUsage() {
    return _storage.read(_dataUsageKey);
  }

  static Future<void> updateDataUsage(String key, dynamic value) async {
    Map<String, dynamic> currentData = getDataUsage() ?? {};
    currentData[key] = value;
    await saveDataUsage(currentData);
  }

  // VPN Config methods
  static Future<void> saveVpnConfig(Map<String, dynamic> config) async {
    await _storage.write(_vpnConfigKey, config);
  }

  static Map<String, dynamic>? getVpnConfig() {
    return _storage.read(_vpnConfigKey);
  }

  // Server List methods
  static Future<void> saveServerList(List<Map<String, dynamic>> servers) async {
    await _storage.write(_serverListKey, servers);
  }

  static List<Map<String, dynamic>>? getServerList() {
    final data = _storage.read(_serverListKey);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  // Last Connected Server methods
  static Future<void> saveLastConnectedServer(
      Map<String, dynamic> server) async {
    await _storage.write(_lastConnectedServerKey, server);
  }

  static Map<String, dynamic>? getLastConnectedServer() {
    return _storage.read(_lastConnectedServerKey);
  }

  // Connection History methods
  static Future<void> saveConnectionHistory(
      List<Map<String, dynamic>> history) async {
    await _storage.write(_connectionHistoryKey, history);
  }

  static List<Map<String, dynamic>>? getConnectionHistory() {
    final data = _storage.read(_connectionHistoryKey);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  static Future<void> addToConnectionHistory(
      Map<String, dynamic> connection) async {
    List<Map<String, dynamic>> history = getConnectionHistory() ?? [];
    history.insert(0, connection); // Add to beginning

    // Keep only last 50 connections
    if (history.length > 50) {
      history = history.take(50).toList();
    }

    await saveConnectionHistory(history);
  }

  // Analytics Data methods
  static Future<void> saveAnalyticsData(Map<String, dynamic> analytics) async {
    await _storage.write(_analyticsDataKey, analytics);
  }

  static Map<String, dynamic>? getAnalyticsData() {
    return _storage.read(_analyticsDataKey);
  }

  // User Preferences methods
  static Future<void> savePreferences(Map<String, dynamic> preferences) async {
    await _storage.write(_preferencesKey, preferences);
  }

  static Map<String, dynamic>? getPreferences() {
    return _storage.read(_preferencesKey);
  }

  static Future<void> updatePreference(String key, dynamic value) async {
    Map<String, dynamic> currentPrefs = getPreferences() ?? {};
    currentPrefs[key] = value;
    await savePreferences(currentPrefs);
  }

  // Auto Connect Settings methods
  static Future<void> saveAutoConnectSettings(
      AutoConnectSettings settings) async {
    await _storage.write(_autoConnectSettingsKey, settings.toJson());
  }

  static Future<AutoConnectSettings?> getAutoConnectSettings() async {
    final data = _storage.read(_autoConnectSettingsKey);
    if (data is Map<String, dynamic>) {
      return AutoConnectSettings.fromJson(data);
    }
    return null;
  }

  // Generic string methods (for Kill Switch controller)
  static Future<void> setString(String key, String value) async {
    await _storage.write(key, value);
  }

  static Future<String?> getString(String key) async {
    return _storage.read(key);
  }

  // Generic bool methods
  static Future<void> setBool(String key, bool value) async {
    await _storage.write(key, value);
  }

  static bool? getBool(String key) {
    return _storage.read(key);
  }

  // Generic int methods
  static Future<void> setInt(String key, int value) async {
    await _storage.write(key, value);
  }

  static int? getInt(String key) {
    return _storage.read(key);
  }

  // VPN Protocol Settings methods
  static Future<void> saveVpnProtocolSettings(Map<String, dynamic> settings) async {
    await _storage.write('vpn_protocol_settings', settings);
  }

  static Map<String, dynamic>? getVpnProtocolSettings() {
    return _storage.read('vpn_protocol_settings');
  }

  // Generic methods
  static Future<void> saveData(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  static T? getData<T>(String key) {
    return _storage.read<T>(key);
  }

  static Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _storage.erase();
  }

  // Check if key exists
  static bool hasData(String key) {
    return _storage.hasData(key);
  }

  // Get all keys
  static Iterable<String> getKeys() {
    return _storage.getKeys();
  }

  // Get storage size
  static int getSize() {
    return _storage.getKeys().length;
  }
}
