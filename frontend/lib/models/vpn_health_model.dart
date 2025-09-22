import 'package:flutter/material.dart';

// VPN Health Monitor Model
class VpnHealthMonitor {
  final int id;
  final int userId;
  final int? serverId;
  final String monitorName;
  final String monitorType;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final int checkInterval;
  final Map<String, dynamic> thresholds;
  final Map<String, dynamic> alertConfiguration;
  final Map<String, dynamic> autoActions;
  final String currentStatus;
  final double healthScore;
  final DateTime? lastCheckAt;
  final DateTime? lastAlertAt;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  VpnHealthMonitor({
    required this.id,
    required this.userId,
    this.serverId,
    required this.monitorName,
    required this.monitorType,
    required this.configuration,
    required this.isActive,
    required this.checkInterval,
    required this.thresholds,
    required this.alertConfiguration,
    required this.autoActions,
    required this.currentStatus,
    required this.healthScore,
    this.lastCheckAt,
    this.lastAlertAt,
    required this.statistics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VpnHealthMonitor.fromJson(Map<String, dynamic> json) {
    return VpnHealthMonitor(
      id: json['id'],
      userId: json['user_id'],
      serverId: json['server_id'],
      monitorName: json['monitor_name'],
      monitorType: json['monitor_type'],
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      isActive: json['is_active'] ?? false,
      checkInterval: json['check_interval'],
      thresholds: Map<String, dynamic>.from(json['thresholds'] ?? {}),
      alertConfiguration: Map<String, dynamic>.from(json['alert_configuration'] ?? {}),
      autoActions: Map<String, dynamic>.from(json['auto_actions'] ?? {}),
      currentStatus: json['current_status'] ?? 'unknown',
      healthScore: (json['health_score'] ?? 0.0).toDouble(),
      lastCheckAt: json['last_check_at'] != null ? DateTime.parse(json['last_check_at']) : null,
      lastAlertAt: json['last_alert_at'] != null ? DateTime.parse(json['last_alert_at']) : null,
      statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'server_id': serverId,
      'monitor_name': monitorName,
      'monitor_type': monitorType,
      'configuration': configuration,
      'is_active': isActive,
      'check_interval': checkInterval,
      'thresholds': thresholds,
      'alert_configuration': alertConfiguration,
      'auto_actions': autoActions,
      'current_status': currentStatus,
      'health_score': healthScore,
      'last_check_at': lastCheckAt?.toIso8601String(),
      'last_alert_at': lastAlertAt?.toIso8601String(),
      'statistics': statistics,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VpnHealthMonitor copyWith({
    int? id,
    int? userId,
    int? serverId,
    String? monitorName,
    String? monitorType,
    Map<String, dynamic>? configuration,
    bool? isActive,
    int? checkInterval,
    Map<String, dynamic>? thresholds,
    Map<String, dynamic>? alertConfiguration,
    Map<String, dynamic>? autoActions,
    String? currentStatus,
    double? healthScore,
    DateTime? lastCheckAt,
    DateTime? lastAlertAt,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VpnHealthMonitor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serverId: serverId ?? this.serverId,
      monitorName: monitorName ?? this.monitorName,
      monitorType: monitorType ?? this.monitorType,
      configuration: configuration ?? this.configuration,
      isActive: isActive ?? this.isActive,
      checkInterval: checkInterval ?? this.checkInterval,
      thresholds: thresholds ?? this.thresholds,
      alertConfiguration: alertConfiguration ?? this.alertConfiguration,
      autoActions: autoActions ?? this.autoActions,
      currentStatus: currentStatus ?? this.currentStatus,
      healthScore: healthScore ?? this.healthScore,
      lastCheckAt: lastCheckAt ?? this.lastCheckAt,
      lastAlertAt: lastAlertAt ?? this.lastAlertAt,
      statistics: statistics ?? this.statistics,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters
  String get statusDisplayName {
    switch (currentStatus) {
      case 'healthy':
        return 'Healthy';
      case 'degraded':
        return 'Degraded';
      case 'unhealthy':
        return 'Unhealthy';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (currentStatus) {
      case 'healthy':
        return Colors.green;
      case 'degraded':
        return Colors.orange;
      case 'unhealthy':
        return Colors.red;
      case 'error':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (currentStatus) {
      case 'healthy':
        return Icons.check_circle;
      case 'degraded':
        return Icons.warning;
      case 'unhealthy':
        return Icons.error;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.help;
    }
  }

  String get typeDisplayName {
    switch (monitorType) {
      case 'ping':
        return 'Ping Monitor';
      case 'speed':
        return 'Speed Test';
      case 'connection':
        return 'Connection Monitor';
      case 'dns':
        return 'DNS Monitor';
      case 'leak':
        return 'Leak Detection';
      default:
        return monitorType;
    }
  }

  double get uptimePercentage {
    return (statistics['uptime_percentage'] ?? 0.0).toDouble();
  }

  double get averageLatency {
    return (statistics['average_latency'] ?? 0.0).toDouble();
  }

  double get averageSpeed {
    return (statistics['average_speed'] ?? 0.0).toDouble();
  }

  int get totalChecks {
    return statistics['total_checks'] ?? 0;
  }

  int get failedChecks {
    return statistics['failed_checks'] ?? 0;
  }

  static VpnHealthMonitor empty() {
    return VpnHealthMonitor(
      id: 0,
      userId: 0,
      monitorName: '',
      monitorType: '',
      configuration: {},
      isActive: false,
      checkInterval: 300,
      thresholds: {},
      alertConfiguration: {},
      autoActions: {},
      currentStatus: 'unknown',
      healthScore: 0.0,
      statistics: {},
      metadata: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// VPN Health Check Model
class VpnHealthCheck {
  final int id;
  final int monitorId;
  final String checkType;
  final String status;
  final double? latency;
  final double? downloadSpeed;
  final double? uploadSpeed;
  final double? packetLoss;
  final String? errorMessage;
  final String? errorCode;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;

  VpnHealthCheck({
    required this.id,
    required this.monitorId,
    required this.checkType,
    required this.status,
    this.latency,
    this.downloadSpeed,
    this.uploadSpeed,
    this.packetLoss,
    this.errorMessage,
    this.errorCode,
    required this.startedAt,
    this.completedAt,
    required this.additionalData,
    required this.createdAt,
  });

  factory VpnHealthCheck.fromJson(Map<String, dynamic> json) {
    return VpnHealthCheck(
      id: json['id'],
      monitorId: json['monitor_id'],
      checkType: json['check_type'],
      status: json['status'],
      latency: json['latency']?.toDouble(),
      downloadSpeed: json['download_speed']?.toDouble(),
      uploadSpeed: json['upload_speed']?.toDouble(),
      packetLoss: json['packet_loss']?.toDouble(),
      errorMessage: json['error_message'],
      errorCode: json['error_code'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      additionalData: Map<String, dynamic>.from(json['additional_data'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monitor_id': monitorId,
      'check_type': checkType,
      'status': status,
      'latency': latency,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'packet_loss': packetLoss,
      'error_message': errorMessage,
      'error_code': errorCode,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'additional_data': additionalData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getters
  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return null;
  }

  bool get isSuccess {
    return status == 'success';
  }

  bool get hasPerformanceIssues {
    return latency != null && latency! > 200 || 
           downloadSpeed != null && downloadSpeed! < 10 ||
           packetLoss != null && packetLoss! > 1.0;
  }

  String get statusDisplayName {
    switch (status) {
      case 'success':
        return 'Success';
      case 'failed':
        return 'Failed';
      case 'timeout':
        return 'Timeout';
      case 'error':
        return 'Error';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'timeout':
        return Colors.orange;
      case 'error':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  static VpnHealthCheck empty() {
    return VpnHealthCheck(
      id: 0,
      monitorId: 0,
      checkType: '',
      status: 'unknown',
      startedAt: DateTime.now(),
      additionalData: {},
      createdAt: DateTime.now(),
    );
  }
}

// VPN Health Alert Model
class VpnHealthAlert {
  final int id;
  final int monitorId;
  final String alertType;
  final String severity;
  final String title;
  final String message;
  final String status;
  final DateTime triggeredAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final bool notificationSent;
  final bool emailSent;
  final bool autoResolved;
  final int escalationLevel;
  final String? resolutionNotes;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  VpnHealthAlert({
    required this.id,
    required this.monitorId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.status,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.resolvedAt,
    required this.notificationSent,
    required this.emailSent,
    required this.autoResolved,
    required this.escalationLevel,
    this.resolutionNotes,
    required this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VpnHealthAlert.fromJson(Map<String, dynamic> json) {
    return VpnHealthAlert(
      id: json['id'],
      monitorId: json['monitor_id'],
      alertType: json['alert_type'],
      severity: json['severity'],
      title: json['title'],
      message: json['message'],
      status: json['status'],
      triggeredAt: DateTime.parse(json['triggered_at']),
      acknowledgedAt: json['acknowledged_at'] != null ? DateTime.parse(json['acknowledged_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      notificationSent: json['notification_sent'] ?? false,
      emailSent: json['email_sent'] ?? false,
      autoResolved: json['auto_resolved'] ?? false,
      escalationLevel: json['escalation_level'] ?? 0,
      resolutionNotes: json['resolution_notes'],
      additionalData: Map<String, dynamic>.from(json['additional_data'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monitor_id': monitorId,
      'alert_type': alertType,
      'severity': severity,
      'title': title,
      'message': message,
      'status': status,
      'triggered_at': triggeredAt.toIso8601String(),
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'notification_sent': notificationSent,
      'email_sent': emailSent,
      'auto_resolved': autoResolved,
      'escalation_level': escalationLevel,
      'resolution_notes': resolutionNotes,
      'additional_data': additionalData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VpnHealthAlert copyWith({
    int? id,
    int? monitorId,
    String? alertType,
    String? severity,
    String? title,
    String? message,
    String? status,
    DateTime? triggeredAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    bool? notificationSent,
    bool? emailSent,
    bool? autoResolved,
    int? escalationLevel,
    String? resolutionNotes,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VpnHealthAlert(
      id: id ?? this.id,
      monitorId: monitorId ?? this.monitorId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      notificationSent: notificationSent ?? this.notificationSent,
      emailSent: emailSent ?? this.emailSent,
      autoResolved: autoResolved ?? this.autoResolved,
      escalationLevel: escalationLevel ?? this.escalationLevel,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters
  bool get isActive {
    return status == 'active';
  }

  bool get isAcknowledged {
    return acknowledgedAt != null;
  }

  bool get isResolved {
    return resolvedAt != null;
  }

  Duration get duration {
    final endTime = resolvedAt ?? DateTime.now();
    return endTime.difference(triggeredAt);
  }

  String get severityDisplayName {
    switch (severity) {
      case 'critical':
        return 'Critical';
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return severity;
    }
  }

  Color get severityColor {
    switch (severity) {
      case 'critical':
        return Colors.red.shade800;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  static VpnHealthAlert empty() {
    return VpnHealthAlert(
      id: 0,
      monitorId: 0,
      alertType: '',
      severity: 'low',
      title: '',
      message: '',
      status: 'active',
      triggeredAt: DateTime.now(),
      notificationSent: false,
      emailSent: false,
      autoResolved: false,
      escalationLevel: 0,
      additionalData: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// VPN Health Summary Model
class VpnHealthSummary {
  final int totalMonitors;
  final int activeMonitors;
  final int healthyMonitors;
  final int degradedMonitors;
  final int unhealthyMonitors;
  final int totalAlerts;
  final int criticalAlerts;
  final int highAlerts;
  final double overallHealthScore;
  final double averageUptime;
  final double averageLatency;
  final double averageSpeed;
  final Map<String, dynamic> trends;
  final DateTime lastUpdated;

  VpnHealthSummary({
    required this.totalMonitors,
    required this.activeMonitors,
    required this.healthyMonitors,
    required this.degradedMonitors,
    required this.unhealthyMonitors,
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.highAlerts,
    required this.overallHealthScore,
    required this.averageUptime,
    required this.averageLatency,
    required this.averageSpeed,
    required this.trends,
    required this.lastUpdated,
  });

  factory VpnHealthSummary.fromJson(Map<String, dynamic> json) {
    return VpnHealthSummary(
      totalMonitors: json['total_monitors'] ?? 0,
      activeMonitors: json['active_monitors'] ?? 0,
      healthyMonitors: json['healthy_monitors'] ?? 0,
      degradedMonitors: json['degraded_monitors'] ?? 0,
      unhealthyMonitors: json['unhealthy_monitors'] ?? 0,
      totalAlerts: json['total_alerts'] ?? 0,
      criticalAlerts: json['critical_alerts'] ?? 0,
      highAlerts: json['high_alerts'] ?? 0,
      overallHealthScore: (json['overall_health_score'] ?? 0.0).toDouble(),
      averageUptime: (json['average_uptime'] ?? 0.0).toDouble(),
      averageLatency: (json['average_latency'] ?? 0.0).toDouble(),
      averageSpeed: (json['average_speed'] ?? 0.0).toDouble(),
      trends: Map<String, dynamic>.from(json['trends'] ?? {}),
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_monitors': totalMonitors,
      'active_monitors': activeMonitors,
      'healthy_monitors': healthyMonitors,
      'degraded_monitors': degradedMonitors,
      'unhealthy_monitors': unhealthyMonitors,
      'total_alerts': totalAlerts,
      'critical_alerts': criticalAlerts,
      'high_alerts': highAlerts,
      'overall_health_score': overallHealthScore,
      'average_uptime': averageUptime,
      'average_latency': averageLatency,
      'average_speed': averageSpeed,
      'trends': trends,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Getters
  String get overallHealthStatus {
    if (overallHealthScore >= 90) return 'excellent';
    if (overallHealthScore >= 75) return 'good';
    if (overallHealthScore >= 60) return 'fair';
    if (overallHealthScore >= 40) return 'poor';
    return 'critical';
  }

  Color get overallHealthColor {
    switch (overallHealthStatus) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double get healthyPercentage {
    return totalMonitors > 0 ? (healthyMonitors / totalMonitors) * 100 : 0.0;
  }

  double get alertSeverityRatio {
    return totalAlerts > 0 ? (criticalAlerts + highAlerts) / totalAlerts : 0.0;
  }

  static VpnHealthSummary empty() {
    return VpnHealthSummary(
      totalMonitors: 0,
      activeMonitors: 0,
      healthyMonitors: 0,
      degradedMonitors: 0,
      unhealthyMonitors: 0,
      totalAlerts: 0,
      criticalAlerts: 0,
      highAlerts: 0,
      overallHealthScore: 0.0,
      averageUptime: 0.0,
      averageLatency: 0.0,
      averageSpeed: 0.0,
      trends: {},
      lastUpdated: DateTime.now(),
    );
  }
}

// Performance Metric Model
class PerformanceMetric {
  final DateTime timestamp;
  final double latency;
  final double downloadSpeed;
  final double uploadSpeed;
  final double packetLoss;
  final double jitter;

  PerformanceMetric({
    required this.timestamp,
    required this.latency,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.packetLoss,
    required this.jitter,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      timestamp: DateTime.parse(json['timestamp']),
      latency: (json['latency'] ?? 0.0).toDouble(),
      downloadSpeed: (json['download_speed'] ?? 0.0).toDouble(),
      uploadSpeed: (json['upload_speed'] ?? 0.0).toDouble(),
      packetLoss: (json['packet_loss'] ?? 0.0).toDouble(),
      jitter: (json['jitter'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'latency': latency,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'packet_loss': packetLoss,
      'jitter': jitter,
    };
  }
}

// Uptime Metric Model
class UptimeMetric {
  final DateTime timestamp;
  final double uptime;
  final int totalChecks;
  final int successfulChecks;
  final int failedChecks;

  UptimeMetric({
    required this.timestamp,
    required this.uptime,
    required this.totalChecks,
    required this.successfulChecks,
    required this.failedChecks,
  });

  factory UptimeMetric.fromJson(Map<String, dynamic> json) {
    return UptimeMetric(
      timestamp: DateTime.parse(json['timestamp']),
      uptime: (json['uptime'] ?? 0.0).toDouble(),
      totalChecks: json['total_checks'] ?? 0,
      successfulChecks: json['successful_checks'] ?? 0,
      failedChecks: json['failed_checks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'uptime': uptime,
      'total_checks': totalChecks,
      'successful_checks': successfulChecks,
      'failed_checks': failedChecks,
    };
  }
}

// Alert Trend Model
class AlertTrend {
  final DateTime timestamp;
  final int totalAlerts;
  final int criticalAlerts;
  final int highAlerts;
  final int mediumAlerts;
  final int lowAlerts;
  final int resolvedAlerts;

  AlertTrend({
    required this.timestamp,
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.highAlerts,
    required this.mediumAlerts,
    required this.lowAlerts,
    required this.resolvedAlerts,
  });

  factory AlertTrend.fromJson(Map<String, dynamic> json) {
    return AlertTrend(
      timestamp: DateTime.parse(json['timestamp']),
      totalAlerts: json['total_alerts'] ?? 0,
      criticalAlerts: json['critical_alerts'] ?? 0,
      highAlerts: json['high_alerts'] ?? 0,
      mediumAlerts: json['medium_alerts'] ?? 0,
      lowAlerts: json['low_alerts'] ?? 0,
      resolvedAlerts: json['resolved_alerts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'total_alerts': totalAlerts,
      'critical_alerts': criticalAlerts,
      'high_alerts': highAlerts,
      'medium_alerts': mediumAlerts,
      'low_alerts': lowAlerts,
      'resolved_alerts': resolvedAlerts,
    };
  }
}