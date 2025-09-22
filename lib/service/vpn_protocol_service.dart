import 'package:get_storage/get_storage.dart';

class VpnProtocolService {
  static final GetStorage _storage = GetStorage();
  static const String _selectedProtocolKey = 'selected_vpn_protocol';
  static const String _autoSelectKey = 'auto_select_protocol';
  static const String _customConfigKey = 'custom_protocol_config';

  // Available VPN protocols
  static const List<VpnProtocol> availableProtocols = [
    VpnProtocol(
      id: 'openvpn_udp',
      name: 'OpenVPN UDP',
      description: 'Fast and reliable, good for streaming',
      speed: VpnSpeed.fast,
      security: VpnSecurity.high,
      stability: VpnStability.good,
      icon: 'shield',
      isRecommended: true,
    ),
    VpnProtocol(
      id: 'openvpn_tcp',
      name: 'OpenVPN TCP',
      description: 'More stable, works behind firewalls',
      speed: VpnSpeed.medium,
      security: VpnSecurity.high,
      stability: VpnStability.excellent,
      icon: 'security',
      isRecommended: false,
    ),
    VpnProtocol(
      id: 'ikev2',
      name: 'IKEv2/IPSec',
      description: 'Great for mobile devices, auto-reconnect',
      speed: VpnSpeed.fast,
      security: VpnSecurity.high,
      stability: VpnStability.excellent,
      icon: 'phone_android',
      isRecommended: false,
    ),
    VpnProtocol(
      id: 'wireguard',
      name: 'WireGuard',
      description: 'Modern, lightweight, and very fast',
      speed: VpnSpeed.fastest,
      security: VpnSecurity.highest,
      stability: VpnStability.good,
      icon: 'flash_on',
      isRecommended: false,
    ),
    VpnProtocol(
      id: 'shadowsocks',
      name: 'Shadowsocks',
      description: 'Good for bypassing censorship',
      speed: VpnSpeed.fast,
      security: VpnSecurity.medium,
      stability: VpnStability.good,
      icon: 'visibility_off',
      isRecommended: false,
    ),
  ];

  // Get currently selected protocol
  static VpnProtocol getSelectedProtocol() {
    final protocolId = _storage.read(_selectedProtocolKey) ?? 'openvpn_udp';
    return availableProtocols.firstWhere(
      (protocol) => protocol.id == protocolId,
      orElse: () => availableProtocols.first,
    );
  }

  // Set selected protocol
  static void setSelectedProtocol(String protocolId) {
    _storage.write(_selectedProtocolKey, protocolId);
  }

  // Get auto-select setting
  static bool getAutoSelectEnabled() {
    return _storage.read(_autoSelectKey) ?? true;
  }

  // Set auto-select setting
  static void setAutoSelectEnabled(bool enabled) {
    _storage.write(_autoSelectKey, enabled);
  }

  // Auto-select best protocol based on conditions
  static VpnProtocol autoSelectProtocol({
    bool prioritizeSpeed = false,
    bool prioritizeSecurity = false,
    bool prioritizeStability = false,
    bool isMobile = false,
  }) {
    if (isMobile) {
      return availableProtocols.firstWhere((p) => p.id == 'ikev2');
    }

    if (prioritizeSpeed) {
      return availableProtocols.firstWhere((p) => p.id == 'wireguard');
    }

    if (prioritizeSecurity) {
      return availableProtocols.firstWhere((p) => p.id == 'openvpn_tcp');
    }

    if (prioritizeStability) {
      return availableProtocols.firstWhere((p) => p.id == 'ikev2');
    }

    // Default to recommended protocol
    return availableProtocols.firstWhere((p) => p.isRecommended);
  }

  // Get custom configuration
  static Map<String, dynamic> getCustomConfig(String protocolId) {
    final config = _storage.read('${_customConfigKey}_$protocolId');
    return config != null ? Map<String, dynamic>.from(config) : {};
  }

  // Set custom configuration
  static void setCustomConfig(String protocolId, Map<String, dynamic> config) {
    _storage.write('${_customConfigKey}_$protocolId', config);
  }

  // Reset to defaults
  static void resetToDefaults() {
    _storage.remove(_selectedProtocolKey);
    _storage.remove(_autoSelectKey);
    for (final protocol in availableProtocols) {
      _storage.remove('${_customConfigKey}_${protocol.id}');
    }
  }

  // Get protocol statistics (mock implementation)
  static ProtocolStats getProtocolStats(String protocolId) {
    // In a real implementation, this would gather actual usage statistics
    return ProtocolStats(
      protocolId: protocolId,
      averageSpeed: _getMockSpeed(protocolId),
      connectionSuccess: _getMockConnectionSuccess(protocolId),
      averagePing: _getMockPing(protocolId),
      dataTransferred: _getMockDataTransferred(protocolId),
    );
  }

  static double _getMockSpeed(String protocolId) {
    switch (protocolId) {
      case 'wireguard':
        return 95.5;
      case 'openvpn_udp':
        return 87.2;
      case 'ikev2':
        return 89.1;
      case 'openvpn_tcp':
        return 78.3;
      case 'shadowsocks':
        return 82.7;
      default:
        return 80.0;
    }
  }

  static double _getMockConnectionSuccess(String protocolId) {
    switch (protocolId) {
      case 'ikev2':
        return 98.5;
      case 'openvpn_tcp':
        return 97.8;
      case 'openvpn_udp':
        return 95.2;
      case 'wireguard':
        return 94.1;
      case 'shadowsocks':
        return 92.3;
      default:
        return 95.0;
    }
  }

  static int _getMockPing(String protocolId) {
    switch (protocolId) {
      case 'wireguard':
        return 12;
      case 'openvpn_udp':
        return 18;
      case 'ikev2':
        return 15;
      case 'openvpn_tcp':
        return 22;
      case 'shadowsocks':
        return 20;
      default:
        return 18;
    }
  }

  static String _getMockDataTransferred(String protocolId) {
    return '2.4 GB';
  }
}

class VpnProtocol {
  final String id;
  final String name;
  final String description;
  final VpnSpeed speed;
  final VpnSecurity security;
  final VpnStability stability;
  final String icon;
  final bool isRecommended;

  const VpnProtocol({
    required this.id,
    required this.name,
    required this.description,
    required this.speed,
    required this.security,
    required this.stability,
    required this.icon,
    required this.isRecommended,
  });

  String get speedText {
    switch (speed) {
      case VpnSpeed.slow:
        return 'Slow';
      case VpnSpeed.medium:
        return 'Medium';
      case VpnSpeed.fast:
        return 'Fast';
      case VpnSpeed.fastest:
        return 'Fastest';
    }
  }

  String get securityText {
    switch (security) {
      case VpnSecurity.low:
        return 'Low';
      case VpnSecurity.medium:
        return 'Medium';
      case VpnSecurity.high:
        return 'High';
      case VpnSecurity.highest:
        return 'Highest';
    }
  }

  String get stabilityText {
    switch (stability) {
      case VpnStability.poor:
        return 'Poor';
      case VpnStability.fair:
        return 'Fair';
      case VpnStability.good:
        return 'Good';
      case VpnStability.excellent:
        return 'Excellent';
    }
  }
}

enum VpnSpeed { slow, medium, fast, fastest }

enum VpnSecurity { low, medium, high, highest }

enum VpnStability { poor, fair, good, excellent }

class ProtocolStats {
  final String protocolId;
  final double averageSpeed;
  final double connectionSuccess;
  final int averagePing;
  final String dataTransferred;

  ProtocolStats({
    required this.protocolId,
    required this.averageSpeed,
    required this.connectionSuccess,
    required this.averagePing,
    required this.dataTransferred,
  });

  String get averageSpeedFormatted => '${averageSpeed.toStringAsFixed(1)} Mbps';
  String get connectionSuccessFormatted =>
      '${connectionSuccess.toStringAsFixed(1)}%';
  String get averagePingFormatted => '${averagePing}ms';
}
