import 'package:get/get.dart';
import '../model/kill_switch_model.dart';
import '../api/kill_switch_api.dart';
import '../utils/storage_helper.dart';
import '../utils/notification_helper.dart';

class KillSwitchController extends GetxController {
  // API instance
  final KillSwitchApi _api = KillSwitchApi();
  
  // Observable variables
  final Rx<KillSwitchSettings> _settings = KillSwitchSettings.getDefault().obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isEnabled = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isConnected = false.obs;

  // Getters
  KillSwitchSettings get settings => _settings.value;
  bool get isLoading => _isLoading.value;
  bool get isEnabled => _isEnabled.value;
  String get errorMessage => _errorMessage.value;
  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    _loadLocalSettings();
  }

  // Load settings from API
  Future<void> loadSettings() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _api.getSettings();
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        _isEnabled.value = response.data!.isEnabled;
        await _saveLocalSettings();
      } else {
        _errorMessage.value = response.message;
        // Load from local storage if API fails
        await _loadLocalSettings();
      }
    } catch (e) {
      _errorMessage.value = 'Failed to load settings: $e';
      await _loadLocalSettings();
    } finally {
      _isLoading.value = false;
    }
  }

  // Update settings
  Future<bool> updateSettings(KillSwitchSettings newSettings) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _api.updateSettings(newSettings);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        _isEnabled.value = response.data!.isEnabled;
        await _saveLocalSettings();
        
        Get.snackbar(
          'Success',
          'Kill Switch settings updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Failed to update settings: $e';
      Get.snackbar(
        'Error',
        'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Toggle Kill Switch
  Future<void> toggleKillSwitch() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _api.toggle();
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        _isEnabled.value = response.data!.isEnabled;
        await _saveLocalSettings();
        
        // Show notification if enabled
        if (_settings.value.notificationEnabled) {
          final message = _isEnabled.value 
              ? 'Kill Switch activated - Your connection is protected'
              : 'Kill Switch deactivated';
          
          Get.snackbar(
            'Kill Switch',
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        
        // Record activation if enabled
        if (_isEnabled.value) {
          await _api.recordActivation();
        }
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _errorMessage.value = 'Failed to toggle Kill Switch: $e';
      Get.snackbar(
        'Error',
        'Failed to toggle Kill Switch',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    final updatedSettings = _settings.value.copyWith();
    
    switch (key) {
      case 'isEnabled':
        final newSettings = updatedSettings.copyWith(isEnabled: value as bool);
        await updateSettings(newSettings);
        break;
      case 'blockLanTraffic':
        final newSettings = updatedSettings.copyWith(blockLanTraffic: value as bool);
        await updateSettings(newSettings);
        break;
      case 'blockIpv6Traffic':
        final newSettings = updatedSettings.copyWith(blockIpv6Traffic: value as bool);
        await updateSettings(newSettings);
        break;
      case 'autoReconnect':
        final newSettings = updatedSettings.copyWith(autoReconnect: value as bool);
        await updateSettings(newSettings);
        break;
      case 'reconnectAttempts':
        final newSettings = updatedSettings.copyWith(reconnectAttempts: value as int);
        await updateSettings(newSettings);
        break;
      case 'notificationEnabled':
        final newSettings = updatedSettings.copyWith(notificationEnabled: value as bool);
        await updateSettings(newSettings);
        break;
    }
  }

  // Add allowed app
  Future<void> addAllowedApp(String appName) async {
    final currentApps = List<String>.from(_settings.value.allowedApps);
    if (!currentApps.contains(appName)) {
      currentApps.add(appName);
      final newSettings = _settings.value.copyWith(allowedApps: currentApps);
      await updateSettings(newSettings);
    }
  }

  // Remove allowed app
  Future<void> removeAllowedApp(String appName) async {
    final currentApps = List<String>.from(_settings.value.allowedApps);
    currentApps.remove(appName);
    final newSettings = _settings.value.copyWith(allowedApps: currentApps);
    await updateSettings(newSettings);
  }

  // Add blocked app
  Future<void> addBlockedApp(String appName) async {
    final currentApps = List<String>.from(_settings.value.blockedApps);
    if (!currentApps.contains(appName)) {
      currentApps.add(appName);
      final newSettings = _settings.value.copyWith(blockedApps: currentApps);
      await updateSettings(newSettings);
    }
  }

  // Remove blocked app
  Future<void> removeBlockedApp(String appName) async {
    final currentApps = List<String>.from(_settings.value.blockedApps);
    currentApps.remove(appName);
    final newSettings = _settings.value.copyWith(blockedApps: currentApps);
    await updateSettings(newSettings);
  }

  // Check Kill Switch status
  Future<void> checkStatus() async {
    try {
      final response = await _api.getStatus();
      
      if (response['success'] == true) {
        _isEnabled.value = response['data']['is_enabled'] ?? false;
      }
    } catch (e) {
      print('Failed to check Kill Switch status: $e');
    }
  }

  // Handle VPN connection state changes
  void onVpnConnectionChanged(bool connected) {
    _isConnected.value = connected;
    
    // If Kill Switch is enabled and VPN disconnects unexpectedly
    if (_isEnabled.value && !connected) {
      _handleVpnDisconnection();
    }
  }

  // Handle VPN disconnection when Kill Switch is active
  void _handleVpnDisconnection() {
    if (_settings.value.notificationEnabled) {
      Get.snackbar(
        'Kill Switch Activated',
        'VPN disconnected - Internet access blocked for security',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
    
    // Record activation event
    _api.recordActivation();
    
    // Auto-reconnect if enabled
    if (_settings.value.autoReconnect) {
      _attemptAutoReconnect();
    }
  }

  // Attempt auto-reconnect
  void _attemptAutoReconnect() {
    // This would integrate with your VPN controller
    // For now, just show a message
    if (_settings.value.notificationEnabled) {
      Get.snackbar(
        'Auto-Reconnect',
        'Attempting to reconnect to VPN...',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Save settings to local storage
  Future<void> _saveLocalSettings() async {
    try {
      await StorageHelper.setString('kill_switch_settings', _settings.value.toJson().toString());
    } catch (e) {
      print('Failed to save local settings: $e');
    }
  }

  // Load settings from local storage
  Future<void> _loadLocalSettings() async {
    try {
      final settingsString = await StorageHelper.getString('kill_switch_settings');
      if (settingsString != null && settingsString.isNotEmpty) {
        // Parse and load settings
        // This is a simplified version - you'd need proper JSON parsing
        _isEnabled.value = settingsString.contains('"is_enabled":true');
      }
    } catch (e) {
      print('Failed to load local settings: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Reset to default settings
  Future<void> resetToDefault() async {
    final defaultSettings = KillSwitchSettings.getDefault();
    await updateSettings(defaultSettings);
  }
}