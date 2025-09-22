// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'dart:async';
import '../models/vpn_protocol_model.dart';
import '../services/vpn_protocol_api.dart';
import '../utils/storage_helper.dart';

class VpnProtocolController extends GetxController {
  final VpnProtocolApi _api = VpnProtocolApi();

  // Observable state
  final _settings = Rx<VpnProtocolSettings?>(null);
  final _availableProtocols = RxMap<String, VpnProtocol>({});
  final _protocolStats = RxMap<String, ProtocolStats>({});
  final _recommendations = RxList<ProtocolRecommendation>([]);
  final _testResults = RxMap<String, ProtocolTestResult>({});
  final _comparison = Rx<ProtocolComparison?>(null);
  
  // Loading states
  final _isLoading = false.obs;
  final _isSwitching = false.obs;
  final _isTesting = false.obs;
  final _isLoadingRecommendations = false.obs;
  final _isLoadingStats = false.obs;
  
  // Error handling
  final _error = Rx<String?>(null);
  final _lastError = Rx<String?>(null);
  
  // Current context
  final _currentContext = Rx<ProtocolContext?>(null);
  
  // Auto-refresh timer
  Timer? _refreshTimer;
  
  // Getters
  VpnProtocolSettings? get settings => _settings.value;
  Map<String, VpnProtocol> get availableProtocols => _availableProtocols;
  Map<String, ProtocolStats> get protocolStats => _protocolStats;
  List<ProtocolRecommendation> get recommendations => _recommendations;
  Map<String, ProtocolTestResult> get testResults => _testResults;
  ProtocolComparison? get comparison => _comparison.value;
  
  bool get isLoading => _isLoading.value;
  bool get isSwitching => _isSwitching.value;
  bool get isTesting => _isTesting.value;
  bool get isLoadingRecommendations => _isLoadingRecommendations.value;
  bool get isLoadingStats => _isLoadingStats.value;
  
  String? get error => _error.value;
  String? get lastError => _lastError.value;
  ProtocolContext? get currentContext => _currentContext.value;
  
  String get currentProtocol => settings?.selectedProtocol ?? 'auto';
  bool get autoSelectionEnabled => settings?.autoSelectionEnabled ?? true;
  bool get optimizationEnabled => settings?.optimizationEnabled ?? true;
  
  @override
  void onInit() {
    super.onInit();
    _api.initialize();
    _initializeFromStorage();
    _startAutoRefresh();
  }
  
  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
  
  // Initialize from stored settings
  Future<void> _initializeFromStorage() async {
    try {
      final storedSettings = StorageHelper.getVpnProtocolSettings();
      if (storedSettings != null) {
        _settings.value = VpnProtocolSettings.fromJson(storedSettings);
      }
      
      // Load initial data
      await loadSettings();
    } catch (e) {
      print('Failed to initialize from storage: $e');
    }
  }
  
  // Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!isLoading) {
        refreshStats();
      }
    });
  }
  
  // Load protocol settings
  Future<void> loadSettings() async {
    try {
      _isLoading.value = true;
      _error.value = null;
      
      final response = await _api.getSettings();
      
      if (response.success && response.data != null) {
        final data = response.data!;
        
        if (data.settings != null) {
          _settings.value = data.settings;
          await _saveSettingsToStorage(data.settings!);
        }
        
        if (data.availableProtocols != null) {
          _availableProtocols.assignAll(data.availableProtocols!);
        }
        
        if (data.protocolStats != null) {
          _protocolStats.assignAll(data.protocolStats!);
        }
      } else {
        _error.value = response.message ?? 'Failed to load settings';
      }
    } catch (e) {
      _error.value = 'Failed to load settings: $e';
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update protocol settings
  Future<bool> updateSettings({
    String? selectedProtocol,
    bool? autoSelectionEnabled,
    bool? optimizationEnabled,
    Map<String, int>? protocolPreferences,
    Map<String, dynamic>? connectionSettings,
    List<String>? fallbackProtocols,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      
      final response = await _api.updateSettings(
        selectedProtocol: selectedProtocol ?? currentProtocol,
        autoSelectionEnabled: autoSelectionEnabled,
        optimizationEnabled: optimizationEnabled,
        protocolPreferences: protocolPreferences,
        connectionSettings: connectionSettings,
        fallbackProtocols: fallbackProtocols,
        customSettings: customSettings,
      );
      
      if (response.success && response.data?.settings != null) {
        _settings.value = response.data!.settings;
        await _saveSettingsToStorage(response.data!.settings!);
        
        if (response.data!.protocolStats != null) {
          _protocolStats.assignAll(response.data!.protocolStats!);
        }
        
        Get.snackbar(
          'Success',
          'Protocol settings updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to update settings';
        
        Get.snackbar(
          'Error',
          _error.value!,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return false;
      }
    } catch (e) {
      _error.value = 'Failed to update settings: $e';
      
      Get.snackbar(
        'Error',
        _error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Switch to a specific protocol
  Future<bool> switchProtocol(String protocol, {String? reason}) async {
    try {
      _isSwitching.value = true;
      _error.value = null;
      
      final response = await _api.switchProtocol(
        protocol: protocol,
        reason: reason,
        context: _currentContext.value,
      );
      
      if (response.success) {
        // Update local settings
        if (_settings.value != null) {
          _settings.value = _settings.value!.copyWith(
            selectedProtocol: protocol,
            protocolSwitchCount: _settings.value!.protocolSwitchCount + 1,
          );
          await _saveSettingsToStorage(_settings.value!);
        }
        
        // Record performance metrics
        await _recordProtocolSwitch(protocol, reason);
        
        Get.snackbar(
          'Protocol Switched',
          'Successfully switched to ${VpnProtocolApi.getProtocolDisplayName(protocol)}',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to switch protocol';
        
        Get.snackbar(
          'Error',
          _error.value!,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return false;
      }
    } catch (e) {
      _error.value = 'Failed to switch protocol: $e';
      
      Get.snackbar(
        'Error',
        _error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      _isSwitching.value = false;
    }
  }
  
  // Get protocol recommendations
  Future<void> getRecommendations({
    ProtocolContext? context,
  }) async {
    try {
      _isLoadingRecommendations.value = true;
      _error.value = null;
      
      final contextToUse = context ?? _getCurrentDeviceContext();
      _currentContext.value = contextToUse;
      
      final response = await _api.getRecommendations(context: contextToUse);
      
      if (response.success && response.data != null) {
        if (response.data!.recommendations != null) {
          _recommendations.assignAll(response.data!.recommendations!);
        }
      } else {
        _error.value = response.message ?? 'Failed to get recommendations';
      }
    } catch (e) {
      _error.value = 'Failed to get recommendations: $e';
    } finally {
      _isLoadingRecommendations.value = false;
    }
  }
  
  // Test protocol connectivity
  Future<void> testProtocol(String protocol, {String? serverId}) async {
    try {
      _isTesting.value = true;
      _error.value = null;
      
      final response = await _api.testProtocol(
        protocol: protocol,
        serverId: serverId,
      );
      
      if (response.success && response.data?.testResults != null) {
        _testResults[protocol] = response.data!.testResults!;
        
        // Update performance metrics
        await _updatePerformanceMetrics(
          protocol,
          response.data!.testResults!,
        );
        
        Get.snackbar(
          'Test Complete',
          'Protocol test completed for ${VpnProtocolApi.getProtocolDisplayName(protocol)}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        _error.value = response.message ?? 'Failed to test protocol';
        
        Get.snackbar(
          'Test Failed',
          _error.value!,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _error.value = 'Failed to test protocol: $e';
      
      Get.snackbar(
        'Error',
        _error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isTesting.value = false;
    }
  }
  
  // Compare protocols
  Future<void> compareProtocols(List<String> protocols, {List<String>? criteria}) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      
      final response = await _api.compareProtocols(
        protocols: protocols,
        criteria: criteria,
      );
      
      if (response.success && response.data?.comparison != null) {
        _comparison.value = response.data!.comparison;
      } else {
        _error.value = response.message ?? 'Failed to compare protocols';
      }
    } catch (e) {
      _error.value = 'Failed to compare protocols: $e';
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Refresh protocol statistics
  Future<void> refreshStats() async {
    try {
      _isLoadingStats.value = true;
      
      final response = await _api.getProtocolStats();
      
      if (response.success && response.data?.protocolStats != null) {
        _protocolStats.assignAll(response.data!.protocolStats!);
      }
    } catch (e) {
      print('Failed to refresh stats: $e');
    } finally {
      _isLoadingStats.value = false;
    }
  }
  
  // Reset protocol statistics
  Future<void> resetStats() async {
    try {
      _isLoading.value = true;
      _error.value = null;
      
      final response = await _api.resetStats();
      
      if (response.success) {
        _protocolStats.clear();
        _testResults.clear();
        
        if (response.data?.protocolStats != null) {
          _protocolStats.assignAll(response.data!.protocolStats!);
        }
        
        Get.snackbar(
          'Statistics Reset',
          'Protocol statistics have been reset',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        _error.value = response.message ?? 'Failed to reset statistics';
        
        Get.snackbar(
          'Error',
          _error.value!,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _error.value = 'Failed to reset statistics: $e';
      
      Get.snackbar(
        'Error',
        _error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Toggle auto selection
  Future<void> toggleAutoSelection() async {
    final newValue = !autoSelectionEnabled;
    await updateSettings(autoSelectionEnabled: newValue);
  }
  
  // Toggle optimization
  Future<void> toggleOptimization() async {
    final newValue = !optimizationEnabled;
    await updateSettings(optimizationEnabled: newValue);
  }
  
  // Set protocol preferences
  Future<void> setProtocolPreferences(Map<String, int> preferences) async {
    await updateSettings(protocolPreferences: preferences);
  }
  
  // Set fallback protocols
  Future<void> setFallbackProtocols(List<String> protocols) async {
    await updateSettings(fallbackProtocols: protocols);
  }
  
  // Get best protocol for current context
  String getBestProtocol({ProtocolContext? context}) {
    if (!autoSelectionEnabled) {
      return currentProtocol;
    }
    
    final contextToUse = context ?? _getCurrentDeviceContext();
    
    // If we have recommendations, use the top one
    if (_recommendations.isNotEmpty) {
      return _recommendations.first.protocol;
    }
    
    // Fallback to current protocol
    return currentProtocol;
  }
  
  // Get protocol by key
  VpnProtocol? getProtocol(String key) {
    return _availableProtocols[key];
  }
  
  // Get protocol stats by key
  ProtocolStats? getProtocolStats(String key) {
    return _protocolStats[key];
  }
  
  // Get test result by protocol
  ProtocolTestResult? getTestResult(String protocol) {
    return _testResults[protocol];
  }
  
  // Check if protocol is available
  bool isProtocolAvailable(String protocol) {
    return _availableProtocols.containsKey(protocol);
  }
  
  // Get sorted protocols by recommendation score
  List<VpnProtocol> getSortedProtocols() {
    final protocols = _availableProtocols.values.toList();
    
    // Sort by recommendation score if available
    if (_recommendations.isNotEmpty) {
      final scoreMap = <String, int>{};
      for (final rec in _recommendations) {
        scoreMap[rec.protocol] = rec.score;
      }
      
      protocols.sort((a, b) {
        final scoreA = scoreMap[a.key] ?? 0;
        final scoreB = scoreMap[b.key] ?? 0;
        return scoreB.compareTo(scoreA);
      });
    }
    
    return protocols;
  }
  
  // Get protocol usage summary
  Map<String, dynamic> getUsageSummary() {
    int totalUsage = 0;
    String mostUsedProtocol = 'auto';
    int highestUsage = 0;
    double avgSuccessRate = 0;
    
    for (final entry in _protocolStats.entries) {
      final stats = entry.value;
      totalUsage += stats.usageCount;
      
      if (stats.usageCount > highestUsage) {
        highestUsage = stats.usageCount;
        mostUsedProtocol = entry.key;
      }
      
      avgSuccessRate += stats.successRate;
    }
    
    if (_protocolStats.isNotEmpty) {
      avgSuccessRate /= _protocolStats.length;
    }
    
    return {
      'total_usage': totalUsage,
      'most_used_protocol': mostUsedProtocol,
      'avg_success_rate': avgSuccessRate,
      'total_switches': settings?.protocolSwitchCount ?? 0,
      'current_protocol': currentProtocol,
      'auto_selection_enabled': autoSelectionEnabled,
    };
  }
  
  // Clear error
  void clearError() {
    _error.value = null;
  }
  
  // Update context
  void updateContext(ProtocolContext context) {
    _currentContext.value = context;
  }
  
  // Private helper methods
  
  ProtocolContext _getCurrentDeviceContext() {
    return VpnProtocolApi.getCurrentContext();
  }
  
  Future<void> _saveSettingsToStorage(VpnProtocolSettings settings) async {
    try {
      await StorageHelper.saveVpnProtocolSettings(settings.toJson());
    } catch (e) {
      print('Failed to save settings to storage: $e');
    }
  }
  
  Future<void> _recordProtocolSwitch(String protocol, String? reason) async {
    try {
      await _api.updatePerformanceMetrics(
        protocol: protocol,
        metrics: {
          'connection_attempt': true,
          'switch_reason': reason ?? 'manual',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to record protocol switch: $e');
    }
  }
  
  Future<void> _updatePerformanceMetrics(
    String protocol,
    ProtocolTestResult testResult,
  ) async {
    try {
      await _api.updatePerformanceMetrics(
        protocol: protocol,
        metrics: {
          'connection_attempt': true,
          'successful_connection': testResult.isSuccessful,
          'speed': testResult.speedTest.download,
          'latency': testResult.speedTest.latency,
          'packet_loss': testResult.speedTest.packetLoss,
          'connection_time': testResult.connectionTime,
        },
      );
      
      // Refresh stats to get updated data
      await refreshStats();
    } catch (e) {
      print('Failed to update performance metrics: $e');
    }
  }
  
  // Helper methods for UI
  
  String getProtocolDisplayName(String protocol) {
    return VpnProtocolApi.getProtocolDisplayName(protocol);
  }
  
  String getProtocolIcon(String protocol) {
    return VpnProtocolApi.getProtocolIcon(protocol);
  }
  
  String getProtocolColor(String protocol) {
    return VpnProtocolApi.getProtocolColor(protocol);
  }
  
  String formatSpeed(double speed) {
    return VpnProtocolApi.formatSpeed(speed);
  }
  
  String formatDuration(int seconds) {
    return VpnProtocolApi.formatDuration(seconds);
  }
  
  String formatPercentage(double value) {
    return VpnProtocolApi.formatPercentage(value);
  }
  
  String getRecommendationColor(int score) {
    return VpnProtocolApi.getRecommendationColor(score);
  }
  
  String getRecommendationLevel(int score) {
    return VpnProtocolApi.getRecommendationLevel(score);
  }
}