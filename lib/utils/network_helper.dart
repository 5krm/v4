import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'logger.dart';

class NetworkHelper {
  static final Connectivity _connectivity = Connectivity();
  static final NetworkInfo _networkInfo = NetworkInfo();
  static final Logger _logger = Logger('NetworkHelper');

  // Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.error('Internet connection check failed: $e');
      return false;
    }
  }

  // Get current connectivity status
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Handle the case where checkConnectivity returns a List<ConnectivityResult>
      return result.isNotEmpty ? result.first : ConnectivityResult.none;
    } catch (e) {
      _logger.error('Failed to get connectivity status: $e');
      return ConnectivityResult.none;
    }
  }

  // Check if connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    final status = await getConnectivityStatus();
    return status == ConnectivityResult.wifi;
  }

  // Check if connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    final status = await getConnectivityStatus();
    return status == ConnectivityResult.mobile;
  }

  // Get WiFi network name (SSID)
  static Future<String?> getWiFiName() async {
    try {
      if (await isConnectedToWiFi()) {
        return await _networkInfo.getWifiName();
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi name: $e');
      return null;
    }
  }

  // Get WiFi BSSID
  static Future<String?> getWiFiBSSID() async {
    try {
      if (await isConnectedToWiFi()) {
        return await _networkInfo.getWifiBSSID();
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi BSSID: $e');
      return null;
    }
  }

  // Get device IP address
  static Future<String?> getWiFiIP() async {
    try {
      if (await isConnectedToWiFi()) {
        return await _networkInfo.getWifiIP();
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi IP: $e');
      return null;
    }
  }

  // Get WiFi gateway IP
  static Future<String?> getWiFiGatewayIP() async {
    try {
      if (await isConnectedToWiFi()) {
        return await _networkInfo.getWifiGatewayIP();
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi gateway IP: $e');
      return null;
    }
  }

  // Get WiFi subnet mask
  static Future<String?> getWiFiSubnetMask() async {
    try {
      if (await isConnectedToWiFi()) {
        return await _networkInfo.getWifiSubmask();
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi subnet mask: $e');
      return null;
    }
  }

  // Get current network information as a Map (for compatibility with AutoConnectController)
  static Future<Map<String, dynamic>> getCurrentNetworkInfo() async {
    final status = await getConnectivityStatus();
    final hasInternet = await hasInternetConnection();

    String? ssid;
    String? bssid;
    String? ip;
    String? gateway;
    String? subnet;
    String? security;
    int? signalStrength;
    int? frequency;

    if (status == ConnectivityResult.wifi) {
      ssid = await getWiFiName();
      bssid = await getWiFiBSSID();
      ip = await getWiFiIP();
      gateway = await getWiFiGatewayIP();
      subnet = await getWiFiSubnetMask();
      // These would require platform-specific code or additional packages
      security = 'unknown';
      signalStrength = 0;
      frequency = 0;
    }

    return {
      'ssid': ssid,
      'bssid': bssid,
      'ip': ip,
      'gateway': gateway,
      'subnet': subnet,
      'security': security,
      'signal_strength': signalStrength,
      'frequency': frequency,
      'connectivity_status': status.toString(),
      'has_internet': hasInternet,
    };
  }

  // Stream of connectivity changes
  static Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  // Check if network is secure (requires platform-specific implementation)
  static Future<bool> isNetworkSecure() async {
    // This would require platform-specific code to determine network security
    // For now, return true as a safe default
    return true;
  }

  // Get network signal strength (requires platform-specific implementation)
  static Future<int> getSignalStrength() async {
    // This would require platform-specific code
    // Return 0 as default
    return 0;
  }

  // Get network frequency (requires platform-specific implementation)
  static Future<int> getFrequency() async {
    // This would require platform-specific code
    // Return 0 as default
    return 0;
  }

  // Check if network is metered
  static Future<bool> isNetworkMetered() async {
    final status = await getConnectivityStatus();
    // Mobile networks are typically metered
    return status == ConnectivityResult.mobile;
  }

  // Get network type as string
  static Future<String> getNetworkType() async {
    final status = await getConnectivityStatus();
    switch (status) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
    }
  }

  // Dispose resources (if needed)
  static void dispose() {
    // Clean up any resources if needed
  }
}
