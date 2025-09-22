// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:get_storage/get_storage.dart';

class KillSwitchService {
  static final GetStorage _storage = GetStorage();
  static const String _killSwitchEnabledKey = 'kill_switch_enabled';
  static const String _autoConnectKey = 'auto_connect_enabled';
  static const String _blockOnDisconnectKey = 'block_on_disconnect';

  static bool _isKillSwitchActive = false;
  static StreamController<bool> _statusController =
      StreamController.broadcast();

  static Stream<bool> get statusStream => _statusController.stream;

  // Initialize kill switch service
  static void initialize() {
    _isKillSwitchActive = getKillSwitchEnabled();
  }

  // Enable/Disable Kill Switch
  static void setKillSwitchEnabled(bool enabled) {
    _storage.write(_killSwitchEnabledKey, enabled);
    _isKillSwitchActive = enabled;
    _statusController.add(enabled);

    if (enabled) {
      _activateKillSwitch();
    } else {
      _deactivateKillSwitch();
    }
  }

  // Get kill switch status
  static bool getKillSwitchEnabled() {
    return _storage.read(_killSwitchEnabledKey) ?? false;
  }

  // Auto connect on VPN disconnect
  static void setAutoConnectEnabled(bool enabled) {
    _storage.write(_autoConnectKey, enabled);
  }

  static bool getAutoConnectEnabled() {
    return _storage.read(_autoConnectKey) ?? false;
  }

  // Block internet on VPN disconnect
  static void setBlockOnDisconnectEnabled(bool enabled) {
    _storage.write(_blockOnDisconnectKey, enabled);
  }

  static bool getBlockOnDisconnectEnabled() {
    return _storage.read(_blockOnDisconnectKey) ?? true;
  }

  // Activate kill switch protection
  static void _activateKillSwitch() {
    // In a real implementation, this would:
    // 1. Monitor VPN connection status
    // 2. Block internet traffic when VPN disconnects
    // 3. Show notifications to user
    print('Kill Switch: Activated - Internet protection enabled');
  }

  // Deactivate kill switch protection
  static void _deactivateKillSwitch() {
    // In a real implementation, this would:
    // 1. Stop monitoring VPN connection
    // 2. Allow normal internet traffic
    print('Kill Switch: Deactivated - Normal internet access restored');
  }

  // Simulate VPN disconnect detection
  static void onVpnDisconnected() {
    if (_isKillSwitchActive) {
      if (getBlockOnDisconnectEnabled()) {
        _blockInternetTraffic();
      }

      if (getAutoConnectEnabled()) {
        _attemptAutoReconnect();
      }
    }
  }

  // Simulate VPN reconnect detection
  static void onVpnConnected() {
    if (_isKillSwitchActive) {
      _restoreInternetTraffic();
    }
  }

  // Block internet traffic (simulation)
  static void _blockInternetTraffic() {
    print('Kill Switch: Blocking internet traffic - VPN disconnected');
    // In a real implementation, this would block network access
  }

  // Restore internet traffic (simulation)
  static void _restoreInternetTraffic() {
    print('Kill Switch: Restoring internet traffic - VPN connected');
    // In a real implementation, this would restore network access
  }

  // Attempt to reconnect VPN automatically
  static void _attemptAutoReconnect() {
    print('Kill Switch: Attempting auto-reconnect...');
    // In a real implementation, this would trigger VPN reconnection
  }

  // Get kill switch status for UI
  static KillSwitchStatus getStatus() {
    return KillSwitchStatus(
      isEnabled: _isKillSwitchActive,
      autoConnectEnabled: getAutoConnectEnabled(),
      blockOnDisconnectEnabled: getBlockOnDisconnectEnabled(),
      isProtecting: _isKillSwitchActive,
    );
  }

  // Dispose resources
  static void dispose() {
    _statusController.close();
    _statusController = StreamController.broadcast();
  }
}

class KillSwitchStatus {
  final bool isEnabled;
  final bool autoConnectEnabled;
  final bool blockOnDisconnectEnabled;
  final bool isProtecting;

  KillSwitchStatus({
    required this.isEnabled,
    required this.autoConnectEnabled,
    required this.blockOnDisconnectEnabled,
    required this.isProtecting,
  });

  String get statusDescription {
    if (!isEnabled) return 'Disabled';
    if (isProtecting) return 'Active - Protected';
    return 'Enabled - Monitoring';
  }

  String get protectionLevel {
    if (!isEnabled) return 'No Protection';
    if (blockOnDisconnectEnabled && autoConnectEnabled)
      return 'Maximum Protection';
    if (blockOnDisconnectEnabled) return 'High Protection';
    if (autoConnectEnabled) return 'Medium Protection';
    return 'Basic Protection';
  }
}
