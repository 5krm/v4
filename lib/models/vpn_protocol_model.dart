// ignore_for_file: curly_braces_in_flow_control_structures

class VpnProtocolSettings {
  final String selectedProtocol;
  final bool autoSelectionEnabled;
  final Map<String, int> protocolPreferences;
  final Map<String, dynamic> connectionSettings;
  final Map<String, dynamic> performanceMetrics;
  final String? lastProtocolUsed;
  final int protocolSwitchCount;
  final bool optimizationEnabled;
  final List<String> fallbackProtocols;
  final Map<String, dynamic> customSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VpnProtocolSettings({
    required this.selectedProtocol,
    required this.autoSelectionEnabled,
    required this.protocolPreferences,
    required this.connectionSettings,
    required this.performanceMetrics,
    this.lastProtocolUsed,
    required this.protocolSwitchCount,
    required this.optimizationEnabled,
    required this.fallbackProtocols,
    required this.customSettings,
    this.createdAt,
    this.updatedAt,
  });

  factory VpnProtocolSettings.fromJson(Map<String, dynamic> json) {
    return VpnProtocolSettings(
      selectedProtocol: json['selected_protocol'] ?? 'auto',
      autoSelectionEnabled: json['auto_selection_enabled'] ?? true,
      protocolPreferences: Map<String, int>.from(json['protocol_preferences'] ?? {}),
      connectionSettings: Map<String, dynamic>.from(json['connection_settings'] ?? {}),
      performanceMetrics: Map<String, dynamic>.from(json['performance_metrics'] ?? {}),
      lastProtocolUsed: json['last_protocol_used'],
      protocolSwitchCount: json['protocol_switch_count'] ?? 0,
      optimizationEnabled: json['optimization_enabled'] ?? true,
      fallbackProtocols: List<String>.from(json['fallback_protocols'] ?? []),
      customSettings: Map<String, dynamic>.from(json['custom_settings'] ?? {}),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_protocol': selectedProtocol,
      'auto_selection_enabled': autoSelectionEnabled,
      'protocol_preferences': protocolPreferences,
      'connection_settings': connectionSettings,
      'performance_metrics': performanceMetrics,
      'last_protocol_used': lastProtocolUsed,
      'protocol_switch_count': protocolSwitchCount,
      'optimization_enabled': optimizationEnabled,
      'fallback_protocols': fallbackProtocols,
      'custom_settings': customSettings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  VpnProtocolSettings copyWith({
    String? selectedProtocol,
    bool? autoSelectionEnabled,
    Map<String, int>? protocolPreferences,
    Map<String, dynamic>? connectionSettings,
    Map<String, dynamic>? performanceMetrics,
    String? lastProtocolUsed,
    int? protocolSwitchCount,
    bool? optimizationEnabled,
    List<String>? fallbackProtocols,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VpnProtocolSettings(
      selectedProtocol: selectedProtocol ?? this.selectedProtocol,
      autoSelectionEnabled: autoSelectionEnabled ?? this.autoSelectionEnabled,
      protocolPreferences: protocolPreferences ?? this.protocolPreferences,
      connectionSettings: connectionSettings ?? this.connectionSettings,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      lastProtocolUsed: lastProtocolUsed ?? this.lastProtocolUsed,
      protocolSwitchCount: protocolSwitchCount ?? this.protocolSwitchCount,
      optimizationEnabled: optimizationEnabled ?? this.optimizationEnabled,
      fallbackProtocols: fallbackProtocols ?? this.fallbackProtocols,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static VpnProtocolSettings get defaultSettings => const VpnProtocolSettings(
    selectedProtocol: 'auto',
    autoSelectionEnabled: true,
    protocolPreferences: {},
    connectionSettings: {},
    performanceMetrics: {},
    protocolSwitchCount: 0,
    optimizationEnabled: true,
    fallbackProtocols: ['openvpn_udp', 'openvpn_tcp', 'ikev2'],
    customSettings: {},
  );
}

class VpnProtocol {
  final String key;
  final String name;
  final String description;
  final String speed;
  final String security;
  final String compatibility;
  final String batteryUsage;
  final List<String> features;
  final List<String> recommendedFor;

  const VpnProtocol({
    required this.key,
    required this.name,
    required this.description,
    required this.speed,
    required this.security,
    required this.compatibility,
    required this.batteryUsage,
    required this.features,
    required this.recommendedFor,
  });

  factory VpnProtocol.fromJson(String key, Map<String, dynamic> json) {
    return VpnProtocol(
      key: key,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      speed: json['speed'] ?? '',
      security: json['security'] ?? '',
      compatibility: json['compatibility'] ?? '',
      batteryUsage: json['battery_usage'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      recommendedFor: List<String>.from(json['recommended_for'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'speed': speed,
      'security': security,
      'compatibility': compatibility,
      'battery_usage': batteryUsage,
      'features': features,
      'recommended_for': recommendedFor,
    };
  }

  // Get protocol icon based on key
  String get icon {
    switch (key) {
      case 'auto':
        return '🤖';
      case 'openvpn_udp':
        return '🚀';
      case 'openvpn_tcp':
        return '🔒';
      case 'ikev2':
        return '📱';
      case 'wireguard':
        return '⚡';
      case 'l2tp':
        return '🔧';
      default:
        return '🔐';
    }
  }

  // Get protocol color based on characteristics
  String get colorHex {
    switch (key) {
      case 'auto':
        return '#6366F1'; // Indigo
      case 'openvpn_udp':
        return '#10B981'; // Emerald
      case 'openvpn_tcp':
        return '#3B82F6'; // Blue
      case 'ikev2':
        return '#8B5CF6'; // Violet
      case 'wireguard':
        return '#F59E0B'; // Amber
      case 'l2tp':
        return '#6B7280'; // Gray
      default:
        return '#374151'; // Gray
    }
  }

  // Get speed rating (1-5)
  int get speedRating {
    switch (speed.toLowerCase()) {
      case 'fastest':
        return 5;
      case 'very fast':
        return 4;
      case 'fast':
        return 3;
      case 'medium':
        return 2;
      case 'slow':
        return 1;
      default:
        return 3;
    }
  }

  // Get security rating (1-5)
  int get securityRating {
    switch (security.toLowerCase()) {
      case 'very high':
        return 5;
      case 'high':
        return 4;
      case 'medium':
        return 3;
      case 'low':
        return 2;
      case 'very low':
        return 1;
      default:
        return 4;
    }
  }

  // Get battery efficiency rating (1-5)
  int get batteryRating {
    switch (batteryUsage.toLowerCase()) {
      case 'very low':
        return 5;
      case 'low':
        return 4;
      case 'medium':
        return 3;
      case 'high':
        return 2;
      case 'very high':
        return 1;
      case 'optimized':
        return 4;
      default:
        return 3;
    }
  }
}

class ProtocolRecommendation {
  final String protocol;
  final int score;
  final String reason;
  final VpnProtocol details;

  const ProtocolRecommendation({
    required this.protocol,
    required this.score,
    required this.reason,
    required this.details,
  });

  factory ProtocolRecommendation.fromJson(Map<String, dynamic> json) {
    return ProtocolRecommendation(
      protocol: json['protocol'] ?? '',
      score: json['score'] ?? 0,
      reason: json['reason'] ?? '',
      details: VpnProtocol.fromJson(json['protocol'], json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'score': score,
      'reason': reason,
      'details': details.toJson(),
    };
  }

  // Get recommendation level based on score
  String get recommendationLevel {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Not Recommended';
  }

  // Get recommendation color
  String get recommendationColor {
    if (score >= 80) return '#10B981'; // Green
    if (score >= 60) return '#F59E0B'; // Amber
    if (score >= 40) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }
}

class ProtocolStats {
  final String protocol;
  final String name;
  final int usageCount;
  final double successRate;
  final double avgSpeed;
  final int totalDuration;
  final DateTime? lastUsed;

  const ProtocolStats({
    required this.protocol,
    required this.name,
    required this.usageCount,
    required this.successRate,
    required this.avgSpeed,
    required this.totalDuration,
    this.lastUsed,
  });

  factory ProtocolStats.fromJson(String protocol, Map<String, dynamic> json) {
    return ProtocolStats(
      protocol: protocol,
      name: json['name'] ?? '',
      usageCount: json['usage_count'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
      avgSpeed: (json['avg_speed'] ?? 0).toDouble(),
      totalDuration: json['total_duration'] ?? 0,
      lastUsed: json['last_used'] != null ? DateTime.parse(json['last_used']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage_count': usageCount,
      'success_rate': successRate,
      'avg_speed': avgSpeed,
      'total_duration': totalDuration,
      'last_used': lastUsed?.toIso8601String(),
    };
  }

  // Get formatted success rate
  String get formattedSuccessRate => '${successRate.toStringAsFixed(1)}%';

  // Get formatted average speed
  String get formattedAvgSpeed {
    if (avgSpeed >= 1000) {
      return '${(avgSpeed / 1000).toStringAsFixed(1)} Gbps';
    }
    return '${avgSpeed.toStringAsFixed(1)} Mbps';
  }

  // Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalDuration}s';
    }
  }

  // Get formatted last used
  String get formattedLastUsed {
    if (lastUsed == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastUsed!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Get performance rating based on success rate and speed
  int get performanceRating {
    final successScore = (successRate / 100) * 3; // Max 3 points
    final speedScore = (avgSpeed / 100).clamp(0, 2); // Max 2 points
    return (successScore + speedScore).round().clamp(1, 5);
  }
}

class ProtocolTestResult {
  final String protocol;
  final String status;
  final int connectionTime;
  final SpeedTestResult speedTest;
  final ServerInfo serverInfo;
  final DateTime timestamp;

  const ProtocolTestResult({
    required this.protocol,
    required this.status,
    required this.connectionTime,
    required this.speedTest,
    required this.serverInfo,
    required this.timestamp,
  });

  factory ProtocolTestResult.fromJson(Map<String, dynamic> json) {
    return ProtocolTestResult(
      protocol: json['protocol'] ?? '',
      status: json['status'] ?? '',
      connectionTime: json['connection_time'] ?? 0,
      speedTest: SpeedTestResult.fromJson(json['speed_test'] ?? {}),
      serverInfo: ServerInfo.fromJson(json['server_info'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'status': status,
      'connection_time': connectionTime,
      'speed_test': speedTest.toJson(),
      'server_info': serverInfo.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Get formatted connection time
  String get formattedConnectionTime {
    if (connectionTime >= 1000) {
      return '${(connectionTime / 1000).toStringAsFixed(1)}s';
    }
    return '${connectionTime}ms';
  }

  // Get overall test score
  int get testScore {
    int score = 0;
    
    // Connection time score (faster is better)
    if (connectionTime < 1000) score += 25;
    else if (connectionTime < 3000) score += 15;
    else if (connectionTime < 5000) score += 5;
    
    // Speed score
    if (speedTest.download > 50) score += 25;
    else if (speedTest.download > 25) score += 15;
    else if (speedTest.download > 10) score += 5;
    
    // Latency score (lower is better)
    if (speedTest.latency < 50) score += 25;
    else if (speedTest.latency < 100) score += 15;
    else if (speedTest.latency < 200) score += 5;
    
    // Packet loss score
    if (speedTest.packetLoss == 0) score += 25;
    else if (speedTest.packetLoss < 1) score += 15;
    else if (speedTest.packetLoss < 5) score += 5;
    
    return score.clamp(0, 100);
  }

  bool get isSuccessful => status == 'success';
}

class SpeedTestResult {
  final double download;
  final double upload;
  final int latency;
  final double packetLoss;

  const SpeedTestResult({
    required this.download,
    required this.upload,
    required this.latency,
    required this.packetLoss,
  });

  factory SpeedTestResult.fromJson(Map<String, dynamic> json) {
    return SpeedTestResult(
      download: (json['download'] ?? 0).toDouble(),
      upload: (json['upload'] ?? 0).toDouble(),
      latency: json['latency'] ?? 0,
      packetLoss: (json['packet_loss'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'download': download,
      'upload': upload,
      'latency': latency,
      'packet_loss': packetLoss,
    };
  }

  String get formattedDownload => '${download.toStringAsFixed(1)} Mbps';
  String get formattedUpload => '${upload.toStringAsFixed(1)} Mbps';
  String get formattedLatency => '${latency}ms';
  String get formattedPacketLoss => '${packetLoss.toStringAsFixed(1)}%';
}

class ServerInfo {
  final String location;
  final int load;
  final int ping;

  const ServerInfo({
    required this.location,
    required this.load,
    required this.ping,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      location: json['location'] ?? '',
      load: json['load'] ?? 0,
      ping: json['ping'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'load': load,
      'ping': ping,
    };
  }

  String get formattedLoad => '${load}%';
  String get formattedPing => '${ping}ms';
  
  String get loadStatus {
    if (load < 30) return 'Low';
    if (load < 70) return 'Medium';
    return 'High';
  }
}

class ProtocolComparison {
  final Map<String, ProtocolComparisonData> protocols;
  final List<String> criteria;
  final int protocolsCount;

  const ProtocolComparison({
    required this.protocols,
    required this.criteria,
    required this.protocolsCount,
  });

  factory ProtocolComparison.fromJson(Map<String, dynamic> json) {
    final protocolsData = <String, ProtocolComparisonData>{};
    final comparison = json['comparison'] ?? {};
    
    for (final entry in comparison.entries) {
      protocolsData[entry.key] = ProtocolComparisonData.fromJson(entry.key, entry.value);
    }
    
    return ProtocolComparison(
      protocols: protocolsData,
      criteria: List<String>.from(json['criteria'] ?? []),
      protocolsCount: json['protocols_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final protocolsJson = <String, dynamic>{};
    for (final entry in protocols.entries) {
      protocolsJson[entry.key] = entry.value.toJson();
    }
    
    return {
      'comparison': protocolsJson,
      'criteria': criteria,
      'protocols_count': protocolsCount,
    };
  }

  List<ProtocolComparisonData> get sortedProtocols {
    final list = protocols.values.toList();
    list.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return list;
  }
}

class ProtocolComparisonData {
  final String protocol;
  final String name;
  final String description;
  final Map<String, String> characteristics;
  final ProtocolPerformance performance;
  final List<String> features;
  final List<String> recommendedFor;

  const ProtocolComparisonData({
    required this.protocol,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.performance,
    required this.features,
    required this.recommendedFor,
  });

  factory ProtocolComparisonData.fromJson(String protocol, Map<String, dynamic> json) {
    return ProtocolComparisonData(
      protocol: protocol,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      characteristics: Map<String, String>.from(json['characteristics'] ?? {}),
      performance: ProtocolPerformance.fromJson(json['performance'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      recommendedFor: List<String>.from(json['recommended_for'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'characteristics': characteristics,
      'performance': performance.toJson(),
      'features': features,
      'recommended_for': recommendedFor,
    };
  }

  // Calculate overall score based on characteristics and performance
  int get overallScore {
    int score = 0;
    
    // Performance score (40% weight)
    score += (performance.overallScore * 0.4).round();
    
    // Characteristics score (60% weight)
    final charScore = _calculateCharacteristicsScore();
    score += (charScore * 0.6).round();
    
    return score.clamp(0, 100);
  }

  int _calculateCharacteristicsScore() {
    int score = 0;
    int count = 0;
    
    for (final value in characteristics.values) {
      switch (value.toLowerCase()) {
        case 'fastest':
        case 'very high':
        case 'excellent':
        case 'universal':
        case 'very low':
        case 'optimized':
          score += 100;
          break;
        case 'very fast':
        case 'high':
        case 'good':
        case 'low':
          score += 80;
          break;
        case 'fast':
        case 'medium':
        case 'modern devices':
          score += 60;
          break;
        case 'variable':
          score += 70;
          break;
        default:
          score += 40;
      }
      count++;
    }
    
    return count > 0 ? (score / count).round() : 50;
  }
}

class ProtocolPerformance {
  final int usageCount;
  final double successRate;
  final double avgSpeed;

  const ProtocolPerformance({
    required this.usageCount,
    required this.successRate,
    required this.avgSpeed,
  });

  factory ProtocolPerformance.fromJson(Map<String, dynamic> json) {
    return ProtocolPerformance(
      usageCount: json['usage_count'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
      avgSpeed: (json['avg_speed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usage_count': usageCount,
      'success_rate': successRate,
      'avg_speed': avgSpeed,
    };
  }

  int get overallScore {
    int score = 0;
    
    // Success rate score (50% weight)
    score += (successRate * 0.5).round();
    
    // Speed score (30% weight)
    final speedScore = (avgSpeed / 100 * 100).clamp(0, 100);
    score += (speedScore * 0.3).round();
    
    // Usage count score (20% weight)
    final usageScore = usageCount > 0 ? (usageCount.clamp(0, 10) * 10) : 0;
    score += (usageScore * 0.2).round();
    
    return score.clamp(0, 100);
  }
}

class VpnProtocolResponse {
  final bool success;
  final String? message;
  final VpnProtocolData? data;
  final Map<String, dynamic>? errors;

  const VpnProtocolResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory VpnProtocolResponse.fromJson(Map<String, dynamic> json) {
    return VpnProtocolResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? VpnProtocolData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

class VpnProtocolData {
  final VpnProtocolSettings? settings;
  final Map<String, VpnProtocol>? availableProtocols;
  final Map<String, ProtocolStats>? protocolStats;
  final List<ProtocolRecommendation>? recommendations;
  final String? bestProtocol;
  final String? currentProtocol;
  final ProtocolTestResult? testResults;
  final ProtocolComparison? comparison;

  const VpnProtocolData({
    this.settings,
    this.availableProtocols,
    this.protocolStats,
    this.recommendations,
    this.bestProtocol,
    this.currentProtocol,
    this.testResults,
    this.comparison,
  });

  factory VpnProtocolData.fromJson(Map<String, dynamic> json) {
    Map<String, VpnProtocol>? availableProtocols;
    if (json['available_protocols'] != null) {
      availableProtocols = {};
      for (final entry in (json['available_protocols'] as Map).entries) {
        availableProtocols[entry.key] = VpnProtocol.fromJson(entry.key, entry.value);
      }
    }

    Map<String, ProtocolStats>? protocolStats;
    if (json['protocol_stats'] != null) {
      protocolStats = {};
      for (final entry in (json['protocol_stats'] as Map).entries) {
        protocolStats[entry.key] = ProtocolStats.fromJson(entry.key, entry.value);
      }
    }

    List<ProtocolRecommendation>? recommendations;
    if (json['recommendations'] != null) {
      recommendations = (json['recommendations'] as List)
          .map((item) => ProtocolRecommendation.fromJson(item))
          .toList();
    }

    return VpnProtocolData(
      settings: json['settings'] != null ? VpnProtocolSettings.fromJson(json['settings']) : null,
      availableProtocols: availableProtocols,
      protocolStats: protocolStats,
      recommendations: recommendations,
      bestProtocol: json['best_protocol'],
      currentProtocol: json['current_protocol'],
      testResults: json['test_results'] != null ? ProtocolTestResult.fromJson(json['test_results']) : null,
      comparison: json['comparison'] != null ? ProtocolComparison.fromJson(json['comparison']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final availableProtocolsJson = <String, dynamic>{};
    if (availableProtocols != null) {
      for (final entry in availableProtocols!.entries) {
        availableProtocolsJson[entry.key] = entry.value.toJson();
      }
    }

    final protocolStatsJson = <String, dynamic>{};
    if (protocolStats != null) {
      for (final entry in protocolStats!.entries) {
        protocolStatsJson[entry.key] = entry.value.toJson();
      }
    }

    return {
      'settings': settings?.toJson(),
      'available_protocols': availableProtocolsJson.isNotEmpty ? availableProtocolsJson : null,
      'protocol_stats': protocolStatsJson.isNotEmpty ? protocolStatsJson : null,
      'recommendations': recommendations?.map((r) => r.toJson()).toList(),
      'best_protocol': bestProtocol,
      'current_protocol': currentProtocol,
      'test_results': testResults?.toJson(),
      'comparison': comparison?.toJson(),
    };
  }
}

// Context for protocol recommendations
class ProtocolContext {
  final String? deviceType;
  final String? networkType;
  final String? useCase;
  final int? batteryLevel;
  final String? networkStability;
  final String? location;
  final String? platform;

  const ProtocolContext({
    this.deviceType,
    this.networkType,
    this.useCase,
    this.batteryLevel,
    this.networkStability,
    this.location,
    this.platform,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (deviceType != null) json['device_type'] = deviceType;
    if (networkType != null) json['network_type'] = networkType;
    if (useCase != null) json['use_case'] = useCase;
    if (batteryLevel != null) json['battery_level'] = batteryLevel;
    if (networkStability != null) json['network_stability'] = networkStability;
    if (location != null) json['location'] = location;
    if (platform != null) json['platform'] = platform;
    return json;
  }

  factory ProtocolContext.fromJson(Map<String, dynamic> json) {
    return ProtocolContext(
      deviceType: json['device_type'],
      networkType: json['network_type'],
      useCase: json['use_case'],
      batteryLevel: json['battery_level'],
      networkStability: json['network_stability'],
      location: json['location'],
      platform: json['platform'],
    );
  }
}