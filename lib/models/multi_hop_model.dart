import 'package:flutter/material.dart';

class MultiHopConnection {
  final String id;
  final String connectionName;
  final String userId;
  final List<MultiHopNode> nodes;
  final String connectionProtocol;
  final String encryptionLevel;
  final String routingStrategy;
  final String performancePriority;
  final String securityLevel;
  final bool autoOptimize;
  final bool failoverEnabled;
  final int connectionTimeout;
  final int retryAttempts;
  final bool isActive;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;
  final int totalDataTransferred;
  final double averageLatency;
  final double averageSpeed;
  final int connectionAttempts;
  final int successfulConnections;
  final int failedConnections;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MultiHopConnection({
    required this.id,
    required this.connectionName,
    required this.userId,
    required this.nodes,
    this.connectionProtocol = 'auto',
    this.encryptionLevel = 'high',
    this.routingStrategy = 'optimal',
    this.performancePriority = 'balanced',
    this.securityLevel = 'high',
    this.autoOptimize = true,
    this.failoverEnabled = true,
    this.connectionTimeout = 30,
    this.retryAttempts = 3,
    this.isActive = false,
    this.connectedAt,
    this.disconnectedAt,
    this.totalDataTransferred = 0,
    this.averageLatency = 0.0,
    this.averageSpeed = 0.0,
    this.connectionAttempts = 0,
    this.successfulConnections = 0,
    this.failedConnections = 0,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory MultiHopConnection.fromJson(Map<String, dynamic> json) {
    return MultiHopConnection(
      id: json['id'] ?? '',
      connectionName: json['connection_name'] ?? '',
      userId: json['user_id'] ?? '',
      nodes: (json['nodes'] as List<dynamic>? ?? [])
          .map((nodeJson) => MultiHopNode.fromJson(nodeJson))
          .toList(),
      connectionProtocol: json['connection_protocol'] ?? 'auto',
      encryptionLevel: json['encryption_level'] ?? 'high',
      routingStrategy: json['routing_strategy'] ?? 'optimal',
      performancePriority: json['performance_priority'] ?? 'balanced',
      securityLevel: json['security_level'] ?? 'high',
      autoOptimize: json['auto_optimize'] ?? true,
      failoverEnabled: json['failover_enabled'] ?? true,
      connectionTimeout: json['connection_timeout'] ?? 30,
      retryAttempts: json['retry_attempts'] ?? 3,
      isActive: json['is_active'] ?? false,
      connectedAt: json['connected_at'] != null 
          ? DateTime.parse(json['connected_at']) 
          : null,
      disconnectedAt: json['disconnected_at'] != null 
          ? DateTime.parse(json['disconnected_at']) 
          : null,
      totalDataTransferred: json['total_data_transferred'] ?? 0,
      averageLatency: (json['average_latency'] ?? 0.0).toDouble(),
      averageSpeed: (json['average_speed'] ?? 0.0).toDouble(),
      connectionAttempts: json['connection_attempts'] ?? 0,
      successfulConnections: json['successful_connections'] ?? 0,
      failedConnections: json['failed_connections'] ?? 0,
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_name': connectionName,
      'user_id': userId,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'connection_protocol': connectionProtocol,
      'encryption_level': encryptionLevel,
      'routing_strategy': routingStrategy,
      'performance_priority': performancePriority,
      'security_level': securityLevel,
      'auto_optimize': autoOptimize,
      'failover_enabled': failoverEnabled,
      'connection_timeout': connectionTimeout,
      'retry_attempts': retryAttempts,
      'is_active': isActive,
      'connected_at': connectedAt?.toIso8601String(),
      'disconnected_at': disconnectedAt?.toIso8601String(),
      'total_data_transferred': totalDataTransferred,
      'average_latency': averageLatency,
      'average_speed': averageSpeed,
      'connection_attempts': connectionAttempts,
      'successful_connections': successfulConnections,
      'failed_connections': failedConnections,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters
  int get totalHops => nodes.length;
  
  double get successRate {
    if (connectionAttempts == 0) return 0.0;
    return (successfulConnections / connectionAttempts) * 100;
  }
  
  String get statusText {
    if (isActive) {
      return 'Connected';
    } else if (failedConnections > successfulConnections) {
      return 'Connection Issues';
    } else {
      return 'Disconnected';
    }
  }
  
  Color get statusColor {
    if (isActive) {
      return Colors.green;
    } else if (failedConnections > successfulConnections) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
  
  Duration? get connectionDuration {
    if (connectedAt == null) return null;
    final endTime = disconnectedAt ?? DateTime.now();
    return endTime.difference(connectedAt!);
  }
  
  List<String> get serverLocations {
    return nodes.map((node) => node.serverLocation).toList();
  }
  
  String get routePath {
    return serverLocations.join(' → ');
  }
}

class MultiHopNode {
  final String id;
  final String connectionId;
  final String serverId;
  final String serverName;
  final String serverLocation;
  final String serverCountry;
  final int hopOrder;
  final String nodeProtocol;
  final String encryptionMethod;
  final int connectionPort;
  final String connectionStatus;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;
  final double latency;
  final double bandwidth;
  final int dataTransferred;
  final int packetsSent;
  final int packetsReceived;
  final int packetsLost;
  final String? lastError;
  final DateTime? lastErrorAt;
  final int retryCount;
  final int maxRetries;
  final bool failoverEnabled;
  final String? failoverServerId;
  final String healthStatus;
  final DateTime? lastHealthCheck;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> failoverConfig;
  final DateTime createdAt;
  final DateTime updatedAt;

  MultiHopNode({
    required this.id,
    required this.connectionId,
    required this.serverId,
    required this.serverName,
    required this.serverLocation,
    required this.serverCountry,
    required this.hopOrder,
    this.nodeProtocol = 'auto',
    this.encryptionMethod = 'AES-256',
    this.connectionPort = 1194,
    this.connectionStatus = 'disconnected',
    this.connectedAt,
    this.disconnectedAt,
    this.latency = 0.0,
    this.bandwidth = 0.0,
    this.dataTransferred = 0,
    this.packetsSent = 0,
    this.packetsReceived = 0,
    this.packetsLost = 0,
    this.lastError,
    this.lastErrorAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.failoverEnabled = true,
    this.failoverServerId,
    this.healthStatus = 'unknown',
    this.lastHealthCheck,
    this.performanceMetrics = const {},
    this.failoverConfig = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory MultiHopNode.fromJson(Map<String, dynamic> json) {
    return MultiHopNode(
      id: json['id'] ?? '',
      connectionId: json['connection_id'] ?? '',
      serverId: json['server_id'] ?? '',
      serverName: json['server_name'] ?? '',
      serverLocation: json['server_location'] ?? '',
      serverCountry: json['server_country'] ?? '',
      hopOrder: json['hop_order'] ?? 0,
      nodeProtocol: json['node_protocol'] ?? 'auto',
      encryptionMethod: json['encryption_method'] ?? 'AES-256',
      connectionPort: json['connection_port'] ?? 1194,
      connectionStatus: json['connection_status'] ?? 'disconnected',
      connectedAt: json['connected_at'] != null 
          ? DateTime.parse(json['connected_at']) 
          : null,
      disconnectedAt: json['disconnected_at'] != null 
          ? DateTime.parse(json['disconnected_at']) 
          : null,
      latency: (json['latency'] ?? 0.0).toDouble(),
      bandwidth: (json['bandwidth'] ?? 0.0).toDouble(),
      dataTransferred: json['data_transferred'] ?? 0,
      packetsSent: json['packets_sent'] ?? 0,
      packetsReceived: json['packets_received'] ?? 0,
      packetsLost: json['packets_lost'] ?? 0,
      lastError: json['last_error'],
      lastErrorAt: json['last_error_at'] != null 
          ? DateTime.parse(json['last_error_at']) 
          : null,
      retryCount: json['retry_count'] ?? 0,
      maxRetries: json['max_retries'] ?? 3,
      failoverEnabled: json['failover_enabled'] ?? true,
      failoverServerId: json['failover_server_id'],
      healthStatus: json['health_status'] ?? 'unknown',
      lastHealthCheck: json['last_health_check'] != null 
          ? DateTime.parse(json['last_health_check']) 
          : null,
      performanceMetrics: json['performance_metrics'] ?? {},
      failoverConfig: json['failover_config'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_id': connectionId,
      'server_id': serverId,
      'server_name': serverName,
      'server_location': serverLocation,
      'server_country': serverCountry,
      'hop_order': hopOrder,
      'node_protocol': nodeProtocol,
      'encryption_method': encryptionMethod,
      'connection_port': connectionPort,
      'connection_status': connectionStatus,
      'connected_at': connectedAt?.toIso8601String(),
      'disconnected_at': disconnectedAt?.toIso8601String(),
      'latency': latency,
      'bandwidth': bandwidth,
      'data_transferred': dataTransferred,
      'packets_sent': packetsSent,
      'packets_received': packetsReceived,
      'packets_lost': packetsLost,
      'last_error': lastError,
      'last_error_at': lastErrorAt?.toIso8601String(),
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'failover_enabled': failoverEnabled,
      'failover_server_id': failoverServerId,
      'health_status': healthStatus,
      'last_health_check': lastHealthCheck?.toIso8601String(),
      'performance_metrics': performanceMetrics,
      'failover_config': failoverConfig,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters
  bool get isConnected => connectionStatus == 'connected';
  
  bool get hasError => lastError != null;
  
  double get packetLossRate {
    if (packetsSent == 0) return 0.0;
    return (packetsLost / packetsSent) * 100;
  }
  
  Color get statusColor {
    switch (connectionStatus) {
      case 'connected':
        return Colors.green;
      case 'connecting':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'disconnected':
      default:
        return Colors.grey;
    }
  }
  
  IconData get statusIcon {
    switch (connectionStatus) {
      case 'connected':
        return Icons.check_circle;
      case 'connecting':
        return Icons.sync;
      case 'error':
        return Icons.error;
      case 'disconnected':
      default:
        return Icons.radio_button_unchecked;
    }
  }
  
  String get healthStatusText {
    switch (healthStatus) {
      case 'healthy':
        return 'Healthy';
      case 'degraded':
        return 'Degraded';
      case 'unhealthy':
        return 'Unhealthy';
      case 'unknown':
      default:
        return 'Unknown';
    }
  }
  
  Color get healthStatusColor {
    switch (healthStatus) {
      case 'healthy':
        return Colors.green;
      case 'degraded':
        return Colors.orange;
      case 'unhealthy':
        return Colors.red;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }
}

class MultiHopLog {
  final String id;
  final String? connectionId;
  final String? nodeId;
  final String logLevel;
  final String eventType;
  final String message;
  final String? userId;
  final String? userAction;
  final String? sourceIp;
  final String? destinationIp;
  final int? sourcePort;
  final int? destinationPort;
  final String? protocol;
  final double? latency;
  final double? bandwidth;
  final int? dataSize;
  final String status;
  final String? errorCode;
  final String? errorMessage;
  final String? sessionId;
  final String? correlationId;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DateTime occurredAt;
  final DateTime createdAt;

  MultiHopLog({
    required this.id,
    this.connectionId,
    this.nodeId,
    required this.logLevel,
    required this.eventType,
    required this.message,
    this.userId,
    this.userAction,
    this.sourceIp,
    this.destinationIp,
    this.sourcePort,
    this.destinationPort,
    this.protocol,
    this.latency,
    this.bandwidth,
    this.dataSize,
    this.status = 'info',
    this.errorCode,
    this.errorMessage,
    this.sessionId,
    this.correlationId,
    this.metadata = const {},
    this.tags = const [],
    required this.occurredAt,
    required this.createdAt,
  });

  factory MultiHopLog.fromJson(Map<String, dynamic> json) {
    return MultiHopLog(
      id: json['id'] ?? '',
      connectionId: json['connection_id'],
      nodeId: json['node_id'],
      logLevel: json['log_level'] ?? 'info',
      eventType: json['event_type'] ?? '',
      message: json['message'] ?? '',
      userId: json['user_id'],
      userAction: json['user_action'],
      sourceIp: json['source_ip'],
      destinationIp: json['destination_ip'],
      sourcePort: json['source_port'],
      destinationPort: json['destination_port'],
      protocol: json['protocol'],
      latency: json['latency']?.toDouble(),
      bandwidth: json['bandwidth']?.toDouble(),
      dataSize: json['data_size'],
      status: json['status'] ?? 'info',
      errorCode: json['error_code'],
      errorMessage: json['error_message'],
      sessionId: json['session_id'],
      correlationId: json['correlation_id'],
      metadata: json['metadata'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      occurredAt: DateTime.parse(json['occurred_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_id': connectionId,
      'node_id': nodeId,
      'log_level': logLevel,
      'event_type': eventType,
      'message': message,
      'user_id': userId,
      'user_action': userAction,
      'source_ip': sourceIp,
      'destination_ip': destinationIp,
      'source_port': sourcePort,
      'destination_port': destinationPort,
      'protocol': protocol,
      'latency': latency,
      'bandwidth': bandwidth,
      'data_size': dataSize,
      'status': status,
      'error_code': errorCode,
      'error_message': errorMessage,
      'session_id': sessionId,
      'correlation_id': correlationId,
      'metadata': metadata,
      'tags': tags,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getters
  Color get logLevelColor {
    switch (logLevel) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'debug':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
  
  IconData get logLevelIcon {
    switch (logLevel) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'debug':
        return Icons.bug_report;
      default:
        return Icons.circle;
    }
  }
  
  bool get isError => logLevel == 'error';
  bool get isWarning => logLevel == 'warning';
  bool get isInfo => logLevel == 'info';
  bool get isDebug => logLevel == 'debug';
}

class MultiHopPerformanceMetrics {
  final String connectionId;
  final double overallLatency;
  final double overallSpeed;
  final double overallPacketLoss;
  final int totalDataTransferred;
  final Duration connectionDuration;
  final List<NodePerformanceMetrics> nodeMetrics;
  final double securityScore;
  final double stabilityScore;
  final double efficiencyScore;
  final Map<String, dynamic> detailedMetrics;
  final DateTime lastUpdated;

  MultiHopPerformanceMetrics({
    required this.connectionId,
    this.overallLatency = 0.0,
    this.overallSpeed = 0.0,
    this.overallPacketLoss = 0.0,
    this.totalDataTransferred = 0,
    this.connectionDuration = Duration.zero,
    this.nodeMetrics = const [],
    this.securityScore = 0.0,
    this.stabilityScore = 0.0,
    this.efficiencyScore = 0.0,
    this.detailedMetrics = const {},
    required this.lastUpdated,
  });

  factory MultiHopPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return MultiHopPerformanceMetrics(
      connectionId: json['connection_id'] ?? '',
      overallLatency: (json['overall_latency'] ?? 0.0).toDouble(),
      overallSpeed: (json['overall_speed'] ?? 0.0).toDouble(),
      overallPacketLoss: (json['overall_packet_loss'] ?? 0.0).toDouble(),
      totalDataTransferred: json['total_data_transferred'] ?? 0,
      connectionDuration: Duration(
        seconds: json['connection_duration_seconds'] ?? 0,
      ),
      nodeMetrics: (json['node_metrics'] as List<dynamic>? ?? [])
          .map((nodeJson) => NodePerformanceMetrics.fromJson(nodeJson))
          .toList(),
      securityScore: (json['security_score'] ?? 0.0).toDouble(),
      stabilityScore: (json['stability_score'] ?? 0.0).toDouble(),
      efficiencyScore: (json['efficiency_score'] ?? 0.0).toDouble(),
      detailedMetrics: json['detailed_metrics'] ?? {},
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_id': connectionId,
      'overall_latency': overallLatency,
      'overall_speed': overallSpeed,
      'overall_packet_loss': overallPacketLoss,
      'total_data_transferred': totalDataTransferred,
      'connection_duration_seconds': connectionDuration.inSeconds,
      'node_metrics': nodeMetrics.map((metric) => metric.toJson()).toList(),
      'security_score': securityScore,
      'stability_score': stabilityScore,
      'efficiency_score': efficiencyScore,
      'detailed_metrics': detailedMetrics,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Getters
  double get overallScore {
    return (securityScore + stabilityScore + efficiencyScore) / 3;
  }
  
  String get performanceGrade {
    final score = overallScore;
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
  
  Color get performanceGradeColor {
    final score = overallScore;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class NodePerformanceMetrics {
  final String nodeId;
  final int hopOrder;
  final double latency;
  final double bandwidth;
  final double packetLoss;
  final int dataTransferred;
  final double uptime;
  final int errorCount;
  final DateTime lastUpdated;

  NodePerformanceMetrics({
    required this.nodeId,
    required this.hopOrder,
    this.latency = 0.0,
    this.bandwidth = 0.0,
    this.packetLoss = 0.0,
    this.dataTransferred = 0,
    this.uptime = 0.0,
    this.errorCount = 0,
    required this.lastUpdated,
  });

  factory NodePerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return NodePerformanceMetrics(
      nodeId: json['node_id'] ?? '',
      hopOrder: json['hop_order'] ?? 0,
      latency: (json['latency'] ?? 0.0).toDouble(),
      bandwidth: (json['bandwidth'] ?? 0.0).toDouble(),
      packetLoss: (json['packet_loss'] ?? 0.0).toDouble(),
      dataTransferred: json['data_transferred'] ?? 0,
      uptime: (json['uptime'] ?? 0.0).toDouble(),
      errorCount: json['error_count'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'hop_order': hopOrder,
      'latency': latency,
      'bandwidth': bandwidth,
      'packet_loss': packetLoss,
      'data_transferred': dataTransferred,
      'uptime': uptime,
      'error_count': errorCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Getters
  double get performanceScore {
    double score = 100.0;
    
    // Deduct points for high latency
    if (latency > 100) score -= 20;
    else if (latency > 50) score -= 10;
    
    // Deduct points for packet loss
    score -= (packetLoss * 2);
    
    // Deduct points for low uptime
    if (uptime < 95) score -= (95 - uptime);
    
    // Deduct points for errors
    score -= (errorCount * 5);
    
    return score.clamp(0, 100);
  }
  
  Color get performanceColor {
    final score = performanceScore;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

// Default instances for testing and initialization
class MultiHopDefaults {
  static MultiHopConnection get defaultConnection {
    return MultiHopConnection(
      id: 'default',
      connectionName: 'Default Multi-Hop',
      userId: 'user123',
      nodes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  static MultiHopPerformanceMetrics get defaultMetrics {
    return MultiHopPerformanceMetrics(
      connectionId: 'default',
      lastUpdated: DateTime.now(),
    );
  }
  
  static List<String> get availableProtocols {
    return ['auto', 'openvpn', 'ikev2', 'wireguard', 'sstp'];
  }
  
  static List<String> get availableEncryptionLevels {
    return ['medium', 'high', 'maximum'];
  }
  
  static List<String> get availableRoutingStrategies {
    return ['fastest', 'optimal', 'secure', 'balanced'];
  }
  
  static List<String> get availablePerformancePriorities {
    return ['speed', 'balanced', 'security', 'stability'];
  }
  
  static List<String> get availableSecurityLevels {
    return ['medium', 'high', 'maximum'];
  }
}