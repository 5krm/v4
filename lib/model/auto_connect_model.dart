class AutoConnectSettings {
  final int? id;
  final int userId;
  final bool enabled;
  final bool autoConnectUntrusted;
  final bool autoDisconnectTrusted;
  final List<TrustedNetwork> trustedNetworks;
  final List<UntrustedNetwork> untrustedNetworks;
  final int connectionDelay;
  final int? preferredServerId;
  final String preferredProtocol;
  final bool notificationsEnabled;
  final String? lastNetworkSsid;
  final String? lastNetworkBssid;
  final String? lastAction;
  final DateTime? lastActionTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AutoConnectSettings({
    this.id,
    required this.userId,
    required this.enabled,
    required this.autoConnectUntrusted,
    required this.autoDisconnectTrusted,
    required this.trustedNetworks,
    required this.untrustedNetworks,
    required this.connectionDelay,
    this.preferredServerId,
    required this.preferredProtocol,
    required this.notificationsEnabled,
    this.lastNetworkSsid,
    this.lastNetworkBssid,
    this.lastAction,
    this.lastActionTime,
    this.createdAt,
    this.updatedAt,
  });

  factory AutoConnectSettings.fromJson(Map<String, dynamic> json) {
    return AutoConnectSettings(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      enabled: json['enabled'] ?? true,
      autoConnectUntrusted: json['auto_connect_untrusted'] ?? true,
      autoDisconnectTrusted: json['auto_disconnect_trusted'] ?? false,
      trustedNetworks: (json['trusted_networks'] as List<dynamic>? ?? [])
          .map((network) => TrustedNetwork.fromJson(network))
          .toList(),
      untrustedNetworks: (json['untrusted_networks'] as List<dynamic>? ?? [])
          .map((network) => UntrustedNetwork.fromJson(network))
          .toList(),
      connectionDelay: json['connection_delay'] ?? 5,
      preferredServerId: json['preferred_server_id'], // Will be set to first available server from API
      preferredProtocol: json['preferred_protocol'] ?? 'auto',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      lastNetworkSsid: json['last_network_ssid'],
      lastNetworkBssid: json['last_network_bssid'],
      lastAction: json['last_action'],
      lastActionTime: json['last_action_time'] != null
          ? DateTime.parse(json['last_action_time'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'enabled': enabled,
      'auto_connect_untrusted': autoConnectUntrusted,
      'auto_disconnect_trusted': autoDisconnectTrusted,
      'trusted_networks': trustedNetworks.map((network) => network.toJson()).toList(),
      'untrusted_networks': untrustedNetworks.map((network) => network.toJson()).toList(),
      'connection_delay': connectionDelay,
      'preferred_server_id': preferredServerId,
      'preferred_protocol': preferredProtocol,
      'notifications_enabled': notificationsEnabled,
      'last_network_ssid': lastNetworkSsid,
      'last_network_bssid': lastNetworkBssid,
      'last_action': lastAction,
      'last_action_time': lastActionTime?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AutoConnectSettings copyWith({
    int? id,
    int? userId,
    bool? enabled,
    bool? autoConnectUntrusted,
    bool? autoDisconnectTrusted,
    List<TrustedNetwork>? trustedNetworks,
    List<UntrustedNetwork>? untrustedNetworks,
    int? connectionDelay,
    int? preferredServerId,
    String? preferredProtocol,
    bool? notificationsEnabled,
    String? lastNetworkSsid,
    String? lastNetworkBssid,
    String? lastAction,
    DateTime? lastActionTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutoConnectSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      autoConnectUntrusted: autoConnectUntrusted ?? this.autoConnectUntrusted,
      autoDisconnectTrusted: autoDisconnectTrusted ?? this.autoDisconnectTrusted,
      trustedNetworks: trustedNetworks ?? this.trustedNetworks,
      untrustedNetworks: untrustedNetworks ?? this.untrustedNetworks,
      connectionDelay: connectionDelay ?? this.connectionDelay,
      preferredServerId: preferredServerId ?? this.preferredServerId,
      preferredProtocol: preferredProtocol ?? this.preferredProtocol,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastNetworkSsid: lastNetworkSsid ?? this.lastNetworkSsid,
      lastNetworkBssid: lastNetworkBssid ?? this.lastNetworkBssid,
      lastAction: lastAction ?? this.lastAction,
      lastActionTime: lastActionTime ?? this.lastActionTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Default settings
  static AutoConnectSettings get defaultSettings => const AutoConnectSettings(
    userId: 0,
    enabled: true,
    autoConnectUntrusted: true,
    autoDisconnectTrusted: false,
    trustedNetworks: [],
    untrustedNetworks: [],
    connectionDelay: 5,
    preferredProtocol: 'auto',
    notificationsEnabled: true,
  );

  // Helper methods
  String get formattedConnectionDelay {
    return connectionDelay == 1 ? '1 second' : '$connectionDelay seconds';
  }

  String get lastActionDescription {
    if (lastAction == null || lastNetworkSsid == null) {
      return 'No recent activity';
    }

    final action = lastAction!.replaceAll('_', ' ');
    final actionCapitalized = action[0].toUpperCase() + action.substring(1);
    final timeAgo = lastActionTime?.timeAgo ?? 'recently';
    
    return '$actionCapitalized on $lastNetworkSsid $timeAgo';
  }

  int get trustedNetworksCount => trustedNetworks.length;
  int get untrustedNetworksCount => untrustedNetworks.length;

  bool isNetworkTrusted(String ssid, [String? bssid]) {
    return trustedNetworks.any((network) {
      if (bssid != null) {
        return network.ssid == ssid && network.bssid == bssid;
      }
      return network.ssid == ssid;
    });
  }

  bool isNetworkUntrusted(String ssid, [String? bssid]) {
    return untrustedNetworks.any((network) {
      if (bssid != null) {
        return network.ssid == ssid && network.bssid == bssid;
      }
      return network.ssid == ssid;
    });
  }

  String getNetworkClassification(String ssid, [String? bssid]) {
    if (isNetworkTrusted(ssid, bssid)) return 'trusted';
    if (isNetworkUntrusted(ssid, bssid)) return 'untrusted';
    return 'unknown';
  }
}

// Server model for API response
class Server {
  final int id;
  final String name;
  final String? country;
  final String? vpnCountry;
  final int? countryId;
  final String? protocol;
  final int status;

  const Server({
    required this.id,
    required this.name,
    this.country,
    this.vpnCountry,
    this.countryId,
    this.protocol,
    required this.status,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country']?['name'],
      vpnCountry: json['vpn_country'],
      countryId: json['country_id'],
      protocol: json['protocol'],
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'vpn_country': vpnCountry,
      'country_id': countryId,
      'protocol': protocol,
      'status': status,
    };
  }
}

// Servers API response model
class ServersResponse {
  final bool success;
  final String message;
  final List<Server>? servers;
  final int? total;
  final int? currentPage;
  final int? perPage;

  const ServersResponse({
    required this.success,
    required this.message,
    this.servers,
    this.total,
    this.currentPage,
    this.perPage,
  });

  factory ServersResponse.fromJson(Map<String, dynamic> json) {
    List<Server>? serversList;
    if (json['data'] != null) {
      serversList = (json['data'] as List)
          .map((serverJson) => Server.fromJson(serverJson))
          .toList();
    }

    return ServersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      servers: serversList,
      total: json['total'],
      currentPage: json['current_page'],
      perPage: json['per_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': servers?.map((server) => server.toJson()).toList(),
      'total': total,
      'current_page': currentPage,
      'per_page': perPage,
    };
  }
}

class TrustedNetwork {
  final String ssid;
  final String bssid;
  final String? securityType;
  final int? signalStrength;
  final int? frequency;
  final String? description;
  final DateTime? addedAt;
  final DateTime? lastConnected;

  const TrustedNetwork({
    required this.ssid,
    required this.bssid,
    this.securityType,
    this.signalStrength,
    this.frequency,
    this.description,
    this.addedAt,
    this.lastConnected,
  });

  factory TrustedNetwork.fromJson(Map<String, dynamic> json) {
    return TrustedNetwork(
      ssid: json['ssid'] ?? '',
      bssid: json['bssid'] ?? '',
      securityType: json['security_type'],
      signalStrength: json['signal_strength'],
      frequency: json['frequency'],
      description: json['description'],
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : null,
      lastConnected: json['last_connected'] != null
          ? DateTime.parse(json['last_connected'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'security_type': securityType,
      'signal_strength': signalStrength,
      'frequency': frequency,
      'description': description,
      'added_at': addedAt?.toIso8601String(),
      'last_connected': lastConnected?.toIso8601String(),
    };
  }

  TrustedNetwork copyWith({
    String? ssid,
    String? bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? description,
    DateTime? addedAt,
    DateTime? lastConnected,
  }) {
    return TrustedNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      securityType: securityType ?? this.securityType,
      signalStrength: signalStrength ?? this.signalStrength,
      frequency: frequency ?? this.frequency,
      description: description ?? this.description,
      addedAt: addedAt ?? this.addedAt,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  String get displayName => description?.isNotEmpty == true ? description! : ssid;
  String get formattedSignalStrength => signalStrength != null ? '${signalStrength}dBm' : 'Unknown';
  String get formattedFrequency => frequency != null ? '${frequency}MHz' : 'Unknown';
  String get addedTimeAgo => addedAt?.timeAgo ?? 'Unknown';
  String get lastConnectedTimeAgo => lastConnected?.timeAgo ?? 'Never';
}

class UntrustedNetwork {
  final String ssid;
  final String bssid;
  final String? securityType;
  final int? signalStrength;
  final int? frequency;
  final String? reason;
  final DateTime? addedAt;
  final DateTime? lastDetected;

  const UntrustedNetwork({
    required this.ssid,
    required this.bssid,
    this.securityType,
    this.signalStrength,
    this.frequency,
    this.reason,
    this.addedAt,
    this.lastDetected,
  });

  factory UntrustedNetwork.fromJson(Map<String, dynamic> json) {
    return UntrustedNetwork(
      ssid: json['ssid'] ?? '',
      bssid: json['bssid'] ?? '',
      securityType: json['security_type'],
      signalStrength: json['signal_strength'],
      frequency: json['frequency'],
      reason: json['reason'],
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : null,
      lastDetected: json['last_detected'] != null
          ? DateTime.parse(json['last_detected'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'security_type': securityType,
      'signal_strength': signalStrength,
      'frequency': frequency,
      'reason': reason,
      'added_at': addedAt?.toIso8601String(),
      'last_detected': lastDetected?.toIso8601String(),
    };
  }

  UntrustedNetwork copyWith({
    String? ssid,
    String? bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? reason,
    DateTime? addedAt,
    DateTime? lastDetected,
  }) {
    return UntrustedNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      securityType: securityType ?? this.securityType,
      signalStrength: signalStrength ?? this.signalStrength,
      frequency: frequency ?? this.frequency,
      reason: reason ?? this.reason,
      addedAt: addedAt ?? this.addedAt,
      lastDetected: lastDetected ?? this.lastDetected,
    );
  }

  String get displayReason => reason?.isNotEmpty == true ? reason! : 'Marked as untrusted';
  String get formattedSignalStrength => signalStrength != null ? '${signalStrength}dBm' : 'Unknown';
  String get formattedFrequency => frequency != null ? '${frequency}MHz' : 'Unknown';
  String get addedTimeAgo => addedAt?.timeAgo ?? 'Unknown';
  String get lastDetectedTimeAgo => lastDetected?.timeAgo ?? 'Unknown';
}

class AvailableNetwork {
  final String ssid;
  final String bssid;
  final String? securityType;
  final int? signalStrength;
  final int? frequency;
  final int? channel;
  final String classification;
  final bool shouldConnect;

  const AvailableNetwork({
    required this.ssid,
    required this.bssid,
    this.securityType,
    this.signalStrength,
    this.frequency,
    this.channel,
    required this.classification,
    required this.shouldConnect,
  });

  factory AvailableNetwork.fromJson(Map<String, dynamic> json) {
    return AvailableNetwork(
      ssid: json['ssid'] ?? '',
      bssid: json['bssid'] ?? '',
      securityType: json['security_type'],
      signalStrength: json['signal_strength'],
      frequency: json['frequency'],
      channel: json['channel'],
      classification: json['classification'] ?? 'unknown',
      shouldConnect: json['should_connect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'security_type': securityType,
      'signal_strength': signalStrength,
      'frequency': frequency,
      'channel': channel,
      'classification': classification,
      'should_connect': shouldConnect,
    };
  }

  String get formattedSignalStrength => signalStrength != null ? '${signalStrength}dBm' : 'Unknown';
  String get formattedFrequency => frequency != null ? '${frequency}MHz' : 'Unknown';
  String get securityDisplay => securityType ?? 'Unknown';
  
  bool get isSecure => securityType != null && securityType!.toLowerCase() != 'open';
  bool get isTrusted => classification == 'trusted';
  bool get isUntrusted => classification == 'untrusted';
  bool get isUnknown => classification == 'unknown';
}

class AutoConnectResponse {
  final bool success;
  final String message;
  final AutoConnectSettings? settings;
  final List<AvailableNetwork>? networks;
  final AutoConnectStats? stats;
  final NetworkCheckResult? checkResult;
  final String? error;

  const AutoConnectResponse({
    required this.success,
    required this.message,
    this.settings,
    this.networks,
    this.stats,
    this.checkResult,
    this.error,
  });

  factory AutoConnectResponse.fromJson(Map<String, dynamic> json) {
    return AutoConnectResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      settings: json['data']?['settings'] != null
          ? AutoConnectSettings.fromJson(json['data']['settings'])
          : null,
      networks: json['data']?['networks'] != null
          ? (json['data']['networks'] as List<dynamic>)
              .map((network) => AvailableNetwork.fromJson(network))
              .toList()
          : null,
      stats: json['data']?['stats'] != null
          ? AutoConnectStats.fromJson(json['data']['stats'])
          : null,
      checkResult: json['data'] != null
          ? NetworkCheckResult.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        if (settings != null) 'settings': settings!.toJson(),
        if (networks != null) 'networks': networks!.map((n) => n.toJson()).toList(),
        if (stats != null) 'stats': stats!.toJson(),
        if (checkResult != null) ...checkResult!.toJson(),
      },
      if (error != null) 'error': error,
    };
  }
}

class AutoConnectStats {
  final int trustedNetworksCount;
  final int untrustedNetworksCount;
  final String lastAction;

  const AutoConnectStats({
    required this.trustedNetworksCount,
    required this.untrustedNetworksCount,
    required this.lastAction,
  });

  factory AutoConnectStats.fromJson(Map<String, dynamic> json) {
    return AutoConnectStats(
      trustedNetworksCount: json['trusted_networks_count'] ?? 0,
      untrustedNetworksCount: json['untrusted_networks_count'] ?? 0,
      lastAction: json['last_action'] ?? 'No recent activity',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trusted_networks_count': trustedNetworksCount,
      'untrusted_networks_count': untrustedNetworksCount,
      'last_action': lastAction,
    };
  }
}

class NetworkCheckResult {
  final AvailableNetwork network;
  final NetworkRecommendations recommendations;
  final AutoConnectSettings settings;

  const NetworkCheckResult({
    required this.network,
    required this.recommendations,
    required this.settings,
  });

  factory NetworkCheckResult.fromJson(Map<String, dynamic> json) {
    return NetworkCheckResult(
      network: AvailableNetwork.fromJson(json['network'] ?? {}),
      recommendations: NetworkRecommendations.fromJson(json['recommendations'] ?? {}),
      settings: AutoConnectSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network': network.toJson(),
      'recommendations': recommendations.toJson(),
      'settings': settings.toJson(),
    };
  }
}

class NetworkRecommendations {
  final bool shouldConnect;
  final bool shouldDisconnect;
  final int connectionDelay;
  final int? preferredServerId;
  final String preferredProtocol;

  const NetworkRecommendations({
    required this.shouldConnect,
    required this.shouldDisconnect,
    required this.connectionDelay,
    this.preferredServerId,
    required this.preferredProtocol,
  });

  factory NetworkRecommendations.fromJson(Map<String, dynamic> json) {
    return NetworkRecommendations(
      shouldConnect: json['should_connect'] ?? false,
      shouldDisconnect: json['should_disconnect'] ?? false,
      connectionDelay: json['connection_delay'] ?? 5,
      preferredServerId: json['preferred_server_id'],
      preferredProtocol: json['preferred_protocol'] ?? 'auto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'should_connect': shouldConnect,
      'should_disconnect': shouldDisconnect,
      'connection_delay': connectionDelay,
      'preferred_server_id': preferredServerId,
      'preferred_protocol': preferredProtocol,
    };
  }
}

// Extension for DateTime formatting
extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}