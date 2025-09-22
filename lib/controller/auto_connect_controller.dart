import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../api/auto_connect_api.dart';
import '../model/auto_connect_model.dart';
import '../utils/logger.dart';
import '../utils/network_helper.dart';
import '../service/vpn_engine.dart';
import 'home_controller.dart';
import '../utils/storage_helper.dart';

class AutoConnectController extends GetxController {
  final AutoConnectApi _api = AutoConnectApi();
  final Logger _logger = Logger('AutoConnectController');

  // Observables
  final Rx<AutoConnectSettings> settings = AutoConnectSettings(
    userId: 0,
    enabled: false,
    autoConnectUntrusted: true,
    autoDisconnectTrusted: false,
    trustedNetworks: [],
    untrustedNetworks: [],
    connectionDelay: 5,
    preferredServerId: null, // Will be set to first available server from API
    preferredProtocol: 'auto',
    notificationsEnabled: true,
  ).obs;
  final RxBool isLoading = false.obs;
  final RxBool isEnabled = false.obs;
  final RxString error = ''.obs;
  final RxList<AvailableNetwork> availableNetworks = <AvailableNetwork>[].obs;
  final Rx<NetworkCheckResult?> lastCheckResult = Rx<NetworkCheckResult?>(null);
  final RxString currentNetworkSsid = ''.obs;
  final RxString currentNetworkBssid = ''.obs;
  final RxBool isMonitoring = false.obs;
  final RxString lastAction = 'No recent activity'.obs;
  final RxList<Map<String, dynamic>> availableServers = <Map<String, dynamic>>[].obs;

  // Timers
  Timer? _networkMonitorTimer;
  Timer? _connectionDelayTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    loadAvailableServers();
  }

  @override
  void onClose() {
    _networkMonitorTimer?.cancel();
    _connectionDelayTimer?.cancel();
    _api.dispose();
    super.onClose();
  }

  // Initialize controller
  Future<void> _initializeController() async {
    await loadSettings();
    await loadAvailableNetworks();
    _startNetworkMonitoring();
  }

  // Load settings from API
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.getSettings();

      if (response.success && response.settings != null) {
        settings.value = response.settings!;
        isEnabled.value = response.settings!.enabled;
        lastAction.value = response.settings!.lastActionDescription;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        _logger.info('Auto-connect settings loaded successfully');
      } else {
        error.value = response.message;
        _logger
            .error('Failed to load auto-connect settings: ${response.message}');

        // Try to load from local storage
        await _loadFromLocalStorage();
      }
    } catch (e) {
      error.value = 'Failed to load settings';
      _logger.error('Error loading auto-connect settings', e);
      await _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
    }
  }

  // Load settings from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final savedSettings = await StorageHelper.getAutoConnectSettings();
      if (savedSettings != null) {
        settings.value = savedSettings;
        isEnabled.value = savedSettings.enabled;
        lastAction.value = savedSettings.lastActionDescription;
        _logger.info('Loaded auto-connect settings from local storage');
      }
    } catch (e) {
      _logger.error('Error loading settings from local storage', e);
    }
  }

  // Update settings
  Future<bool> updateSettings(AutoConnectSettings newSettings) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.updateSettings(newSettings);

      if (response.success && response.settings != null) {
        settings.value = response.settings!;
        isEnabled.value = response.settings!.enabled;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        Get.snackbar(
          'Success',
          'Auto-connect settings updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        _logger.info('Auto-connect settings updated successfully');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to update settings';
      _logger.error('Error updating auto-connect settings', e);
      Get.snackbar(
        'Error',
        'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle auto-connect feature
  Future<bool> toggleAutoConnect(bool enabled) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.toggleAutoConnect(enabled);

      if (response.success && response.settings != null) {
        settings.value = response.settings!;
        isEnabled.value = response.settings!.enabled;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        if (enabled) {
          _startNetworkMonitoring();
          Get.snackbar(
            'Auto-Connect Enabled',
            'Auto-connect is now monitoring your network',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          _stopNetworkMonitoring();
          Get.snackbar(
            'Auto-Connect Disabled',
            'Auto-connect monitoring has been stopped',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        _logger.info('Auto-connect toggled: $enabled');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to toggle auto-connect';
      _logger.error('Error toggling auto-connect', e);
      Get.snackbar(
        'Error',
        'Failed to toggle auto-connect',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Add trusted network
  Future<bool> addTrustedNetwork({
    required String ssid,
    required String bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.addTrustedNetwork(
        ssid: ssid,
        bssid: bssid,
        securityType: securityType,
        signalStrength: signalStrength,
        frequency: frequency,
        description: description,
      );

      if (response.success && response.settings != null) {
        settings.value = response.settings!;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        Get.snackbar(
          'Network Added',
          'Network "$ssid" added to trusted networks',
          snackPosition: SnackPosition.BOTTOM,
        );

        _logger.info('Trusted network added: $ssid');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to add trusted network';
      _logger.error('Error adding trusted network', e);
      Get.snackbar(
        'Error',
        'Failed to add trusted network',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Remove trusted network
  Future<bool> removeTrustedNetwork(String ssid, String bssid) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.removeTrustedNetwork(ssid, bssid);

      if (response.success && response.settings != null) {
        settings.value = response.settings!;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        Get.snackbar(
          'Network Removed',
          'Network "$ssid" removed from trusted networks',
          snackPosition: SnackPosition.BOTTOM,
        );

        _logger.info('Trusted network removed: $ssid');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to remove trusted network';
      _logger.error('Error removing trusted network', e);
      Get.snackbar(
        'Error',
        'Failed to remove trusted network',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Add untrusted network
  Future<bool> addUntrustedNetwork({
    required String ssid,
    required String bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.addUntrustedNetwork(
        ssid: ssid,
        bssid: bssid,
        securityType: securityType,
        signalStrength: signalStrength,
        frequency: frequency,
        reason: reason,
      );

      if (response.success && response.settings != null) {
        settings.value = response.settings!;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        Get.snackbar(
          'Network Added',
          'Network "$ssid" added to untrusted networks',
          snackPosition: SnackPosition.BOTTOM,
        );

        _logger.info('Untrusted network added: $ssid');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to add untrusted network';
      _logger.error('Error adding untrusted network', e);
      Get.snackbar(
        'Error',
        'Failed to add untrusted network',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Remove untrusted network
  Future<bool> removeUntrustedNetwork(String ssid, String bssid) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.removeUntrustedNetwork(ssid, bssid);

      if (response.success && response.settings != null) {
        settings.value = response.settings!;

        // Save to local storage
        await StorageHelper.saveAutoConnectSettings(response.settings!);

        Get.snackbar(
          'Network Removed',
          'Network "$ssid" removed from untrusted networks',
          snackPosition: SnackPosition.BOTTOM,
        );

        _logger.info('Untrusted network removed: $ssid');
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      error.value = 'Failed to remove untrusted network';
      _logger.error('Error removing untrusted network', e);
      Get.snackbar(
        'Error',
        'Failed to remove untrusted network',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check network recommendations
  Future<void> checkCurrentNetwork() async {
    try {
      final networkInfo = await NetworkHelper.getCurrentNetworkInfo();

      if (networkInfo['ssid'] != null && networkInfo['bssid'] != null) {
        currentNetworkSsid.value = networkInfo['ssid'];
        currentNetworkBssid.value = networkInfo['bssid'];

        final response = await _api.checkNetwork(
          ssid: networkInfo['ssid'],
          bssid: networkInfo['bssid'],
          securityType: networkInfo['security'],
          signalStrength: networkInfo['signal_strength'],
          frequency: networkInfo['frequency'],
        );

        if (response.success && response.checkResult != null) {
          lastCheckResult.value = response.checkResult;

          // Handle recommendations
          await _handleNetworkRecommendations(response.checkResult!);
        }
      }
    } catch (e) {
      _logger.error('Error checking current network', e);
    }
  }

  // Handle network recommendations
  Future<void> _handleNetworkRecommendations(
      NetworkCheckResult checkResult) async {
    if (!isEnabled.value) return;

    final recommendations = checkResult.recommendations;
    final network = checkResult.network;

    if (recommendations.shouldConnect && settings.value.autoConnectUntrusted) {
      await _scheduleVpnConnection(recommendations.connectionDelay);
      await _recordAction('auto_connect', network.ssid, network.bssid);
    } else if (recommendations.shouldDisconnect &&
        settings.value.autoDisconnectTrusted) {
      await _scheduleVpnDisconnection(recommendations.connectionDelay);
      await _recordAction('auto_disconnect', network.ssid, network.bssid);
    }
  }

  // Schedule VPN connection
  Future<void> _scheduleVpnConnection(int delaySeconds) async {
    _connectionDelayTimer?.cancel();

    _connectionDelayTimer = Timer(Duration(seconds: delaySeconds), () async {
      try {
        // Integrate with VPN controller to connect
        final homeController = Get.find<HomeController>();
        
        // Only connect if VPN is not already connected
        if (homeController.vpnState.value != VpnEngine.vpnConnected) {
          homeController.connectToVpn();
          
          _logger.info('Auto-connecting to VPN after $delaySeconds seconds delay');

          Get.snackbar(
            'Auto-Connect',
            'Connecting to VPN on untrusted network',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        _logger.error('Error auto-connecting to VPN', e);
      }
    });
  }

  // Schedule VPN disconnection
  Future<void> _scheduleVpnDisconnection(int delaySeconds) async {
    _connectionDelayTimer?.cancel();

    _connectionDelayTimer = Timer(Duration(seconds: delaySeconds), () async {
      try {
        // Integrate with VPN controller to disconnect
        final homeController = Get.find<HomeController>();
        
        // Only disconnect if VPN is currently connected
        if (homeController.vpnState.value == VpnEngine.vpnConnected) {
          await VpnEngine.stopVpn(); // Direct call to stop VPN
          
          _logger.info('Auto-disconnecting from VPN after $delaySeconds seconds delay');

          Get.snackbar(
            'Auto-Disconnect',
            'Disconnecting from VPN on trusted network',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        _logger.error('Error auto-disconnecting from VPN', e);
      }
    });
  }

  // Record action
  Future<void> _recordAction(
      String action, String networkSsid, String networkBssid) async {
    try {
      await _api.recordAction(
        action: action,
        networkSsid: networkSsid,
        networkBssid: networkBssid,
      );

      lastAction.value = '$action on $networkSsid';
    } catch (e) {
      _logger.error('Error recording action', e);
    }
  }

  // Load available networks
  Future<void> loadAvailableNetworks() async {
    try {
      final response = await _api.getAvailableNetworks();

      if (response.success && response.networks != null) {
        availableNetworks.value = response.networks!;
        _logger.info('Available networks loaded: ${response.networks!.length}');
      }
    } catch (e) {
      _logger.error('Error loading available networks', e);
    }
  }

  // Start network monitoring
  void _startNetworkMonitoring() {
    if (!isEnabled.value) return;

    _networkMonitorTimer?.cancel();
    isMonitoring.value = true;

    _networkMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isEnabled.value) {
        checkCurrentNetwork();
      } else {
        timer.cancel();
        isMonitoring.value = false;
      }
    });

    // Initial check
    checkCurrentNetwork();

    _logger.info('Network monitoring started');
  }

  // Stop network monitoring
  void _stopNetworkMonitoring() {
    _networkMonitorTimer?.cancel();
    _connectionDelayTimer?.cancel();
    isMonitoring.value = false;

    _logger.info('Network monitoring stopped');
  }

  // Refresh all data
  @override
  Future<void> refresh() async {
    await Future.wait([
      loadSettings(),
      loadAvailableNetworks(),
    ]);
  }

  // Helper methods
  String get statusText {
    if (!isEnabled.value) return 'Disabled';
    if (isMonitoring.value) return 'Monitoring';
    return 'Idle';
  }

  String get networkClassificationText {
    if (currentNetworkSsid.value.isEmpty) return 'No network';

    final classification = settings.value.getNetworkClassification(
      currentNetworkSsid.value,
      currentNetworkBssid.value,
    );

    switch (classification) {
      case 'trusted':
        return 'Trusted Network';
      case 'untrusted':
        return 'Untrusted Network';
      default:
        return 'Unknown Network';
    }
  }

  bool get hasCurrentNetwork => currentNetworkSsid.value.isNotEmpty;

  bool get canAddCurrentNetworkAsTrusted {
    return hasCurrentNetwork &&
        !settings.value.isNetworkTrusted(
            currentNetworkSsid.value, currentNetworkBssid.value);
  }

  bool get canAddCurrentNetworkAsUntrusted {
    return hasCurrentNetwork &&
        !settings.value.isNetworkUntrusted(
            currentNetworkSsid.value, currentNetworkBssid.value);
  }

  // Server selection methods
  String getPreferredServerDisplay() {
    final serverId = settings.value.preferredServerId;
    if (serverId == null && availableServers.isNotEmpty) {
      return '${availableServers.first['vpn_country']} (Default)';
    }
    // Find server name from available servers
    final server = availableServers.firstWhere(
      (s) => s['id'] == serverId,
      orElse: () => availableServers.isNotEmpty ? availableServers.first : {'vpn_country': 'Auto'},
    );
    return server['vpn_country'] ?? 'Auto';
  }

  List<Map<String, String>> getServerOptions() {
    List<Map<String, String>> options = [];
    
    // Add all available servers from API
    for (var server in availableServers) {
      if (server['vpn_country'] != null) {
        options.add({
          'value': server['id'].toString(),
          'label': server['vpn_country'],
        });
      }
    }
    
    // If no servers available, add a default option
    if (options.isEmpty) {
      options.add({
        'value': 'null',
        'label': 'Auto (Default)',
      });
    }
    
    return options;
  }

  Future<bool> updatePreferredServer(String serverValue) async {
    try {
      int? serverId;
      if (serverValue != 'null') {
        serverId = int.tryParse(serverValue);
      }
      
      final updatedSettings = settings.value.copyWith(
        preferredServerId: serverId,
      );
      
      return await updateSettings(updatedSettings);
    } catch (e) {
      _logger.error('Error updating preferred server', e);
      return false;
    }
  }

  // Load available servers
  Future<void> loadAvailableServers() async {
    try {
      // Call the actual API to get servers
      final response = await _api.getAvailableServers();
      if (response.success && response.servers != null) {
        List<Map<String, dynamic>> servers = [];
        for (var server in response.servers!) {
          servers.add({
            'id': server.id,
            'vpn_country': server.country ?? server.name,
            'name': server.name,
          });
        }
        availableServers.value = servers;
        
        // Set default to first available server if current default doesn't exist
        if (servers.isNotEmpty) {
          final defaultServerId = servers.first['id'];
          if (settings.value.preferredServerId == null) {
            settings.update((val) {
              val = val?.copyWith(preferredServerId: defaultServerId);
            });
          }
        }
      }
    } catch (e) {
      _logger.error('Error loading available servers', e);
      // Fallback to default servers if API fails
      availableServers.value = [
        // {'id': 2, 'vpn_country': 'Canada', 'name': 'Canada Server 1'},
        // {'id': 3, 'vpn_country': 'United Kingdom', 'name': 'UK Server 1'},
      ];
    }
  }
}
