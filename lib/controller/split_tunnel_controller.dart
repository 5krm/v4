import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api/split_tunnel_api.dart';
import '../model/split_tunnel_model.dart';
import '../utils/shared_preference.dart';
import 'dart:convert';

class SplitTunnelController extends GetxController {
  // Observable variables
  final _isLoading = false.obs;
  final _settings = SplitTunnelSettings.getDefault().obs;
  final _installedApps = <InstalledApp>[].obs;
  final _filteredApps = <InstalledApp>[].obs;
  final _searchQuery = ''.obs;
  final _selectedCategory = 'All'.obs;
  final _isAppsLoading = false.obs;
  final _errorMessage = ''.obs;
  final _successMessage = ''.obs;

  // Text controllers
  final domainController = TextEditingController();
  final ipRangeController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading.value;
  SplitTunnelSettings get settings => _settings.value;
  List<InstalledApp> get installedApps => _installedApps;
  List<InstalledApp> get filteredApps => _filteredApps;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  bool get isAppsLoading => _isAppsLoading.value;
  String get errorMessage => _errorMessage.value;
  String get successMessage => _successMessage.value;

  // App categories
  List<String> get categories {
    final cats = ['All'];
    final uniqueCats = _installedApps.map((app) => app.category).toSet().toList();
    cats.addAll(uniqueCats);
    return cats;
  }

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadInstalledApps();
    _setupSearchListener();
  }

  @override
  void onClose() {
    domainController.dispose();
    ipRangeController.dispose();
    super.onClose();
  }

  void _setupSearchListener() {
    ever(_searchQuery, (_) => _filterApps());
    ever(_selectedCategory, (_) => _filterApps());
  }

  /// Load split tunnel settings
  Future<void> loadSettings() async {
    try {
      _isLoading.value = true;
      _clearMessages();
      
      final response = await SplitTunnelApi.getSettings();
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
      } else {
        _showError(response.message);
        await _loadSettingsLocally();
      }
    } catch (e) {
      _showError('Failed to load settings: $e');
      await _loadSettingsLocally();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update split tunnel settings
  Future<void> updateSettings(SplitTunnelSettings newSettings) async {
    try {
      _isLoading.value = true;
      _clearMessages();
      
      final response = await SplitTunnelApi.updateSettings(newSettings);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
        _showSuccess('Settings updated successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to update settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Toggle split tunneling on/off
  Future<void> toggleSplitTunnel() async {
    try {
      _clearMessages();
      
      final response = await SplitTunnelApi.toggle();
      
      if (response.success) {
        _settings.value = _settings.value.copyWith(
          enabled: !_settings.value.enabled,
        );
        await _saveSettingsLocally();
        _showSuccess(response.message);
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to toggle split tunneling: $e');
    }
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    SplitTunnelSettings updatedSettings;
    
    switch (key) {
      case 'enabled':
        updatedSettings = _settings.value.copyWith(enabled: value);
        break;
      case 'mode':
        updatedSettings = _settings.value.copyWith(mode: value);
        break;
      case 'bypass_local_network':
        updatedSettings = _settings.value.copyWith(bypassLocalNetwork: value);
        break;
      case 'bypass_dns':
        updatedSettings = _settings.value.copyWith(bypassDns: value);
        break;
      case 'auto_detect_apps':
        updatedSettings = _settings.value.copyWith(autoDetectApps: value);
        break;
      case 'notifications_enabled':
        updatedSettings = _settings.value.copyWith(notificationsEnabled: value);
        break;
      default:
        return;
    }
    
    await updateSettings(updatedSettings);
  }

  /// Load installed apps
  Future<void> loadInstalledApps() async {
    try {
      _isAppsLoading.value = true;
      
      final response = await SplitTunnelApi.getInstalledApps();
      
      if (response.success) {
        _installedApps.value = response.data.map((app) {
          return app.copyWith(
            isSelected: _settings.value.apps.contains(app.identifier),
          );
        }).toList();
        _filterApps();
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to load installed apps: $e');
    } finally {
      _isAppsLoading.value = false;
    }
  }

  /// Filter apps based on search and category
  void _filterApps() {
    List<InstalledApp> filtered = _installedApps.toList();
    
    // Filter by category
    if (_selectedCategory.value != 'All') {
      filtered = filtered.where((app) => app.category == _selectedCategory.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((app) => 
        app.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
        app.identifier.toLowerCase().contains(_searchQuery.value.toLowerCase())
      ).toList();
    }
    
    _filteredApps.value = filtered;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  /// Update selected category
  void updateSelectedCategory(String category) {
    _selectedCategory.value = category;
  }

  /// Toggle app selection
  Future<void> toggleApp(InstalledApp app) async {
    try {
      _clearMessages();
      
      if (app.isSelected) {
        final response = await SplitTunnelApi.removeApp(app.identifier);
        if (response.success && response.data != null) {
          _settings.value = response.data!;
          await _saveSettingsLocally();
          _updateAppSelection(app.identifier, false);
          _showSuccess('App removed from split tunnel list');
        } else {
          _showError(response.message);
        }
      } else {
        final response = await SplitTunnelApi.addApp(app.identifier);
        if (response.success && response.data != null) {
          _settings.value = response.data!;
          await _saveSettingsLocally();
          _updateAppSelection(app.identifier, true);
          _showSuccess('App added to split tunnel list');
        } else {
          _showError(response.message);
        }
      }
    } catch (e) {
      _showError('Failed to update app: $e');
    }
  }

  /// Update app selection in local list
  void _updateAppSelection(String identifier, bool isSelected) {
    final index = _installedApps.indexWhere((app) => app.identifier == identifier);
    if (index != -1) {
      _installedApps[index] = _installedApps[index].copyWith(isSelected: isSelected);
      _filterApps();
    }
  }

  /// Add domain
  Future<void> addDomain() async {
    final domain = domainController.text.trim();
    if (domain.isEmpty) {
      _showError('Please enter a domain');
      return;
    }
    
    try {
      _clearMessages();
      
      final response = await SplitTunnelApi.addDomain(domain);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
        domainController.clear();
        _showSuccess('Domain added successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to add domain: $e');
    }
  }

  /// Remove domain
  Future<void> removeDomain(String domain) async {
    try {
      _clearMessages();
      
      final response = await SplitTunnelApi.removeDomain(domain);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
        _showSuccess('Domain removed successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to remove domain: $e');
    }
  }

  /// Add IP range
  Future<void> addIpRange() async {
    final ipRange = ipRangeController.text.trim();
    if (ipRange.isEmpty) {
      _showError('Please enter an IP range');
      return;
    }
    
    try {
      _clearMessages();
      
      final response = await SplitTunnelApi.addIpRange(ipRange);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
        ipRangeController.clear();
        _showSuccess('IP range added successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to add IP range: $e');
    }
  }

  /// Remove IP range
  Future<void> removeIpRange(String ipRange) async {
    try {
      _clearMessages();
      
      final response = await SplitTunnelApi.removeIpRange(ipRange);
      
      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await _saveSettingsLocally();
        _showSuccess('IP range removed successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to remove IP range: $e');
    }
  }

  /// Save settings to local storage
  Future<void> _saveSettingsLocally() async {
    try {
      await SharedPreference.setString('split_tunnel_settings', jsonEncode(_settings.value.toJson()));
    } catch (e) {
      print('Failed to save settings locally: $e');
    }
  }

  /// Load settings from local storage
  Future<void> _loadSettingsLocally() async {
    try {
      final settingsJson = await SharedPreference.getString('split_tunnel_settings');
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        _settings.value = SplitTunnelSettings.fromJson(settingsMap);
      }
    } catch (e) {
      print('Failed to load settings locally: $e');
    }
  }

  /// Show error message
  void _showError(String message) {
    _errorMessage.value = message;
    _successMessage.value = '';
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    _successMessage.value = message;
    _errorMessage.value = '';
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Clear messages
  void _clearMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadSettings(),
      loadInstalledApps(),
    ]);
  }
}