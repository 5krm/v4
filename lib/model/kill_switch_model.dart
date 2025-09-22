class KillSwitchSettings {
  final int? id;
  final int? userId;
  final bool isEnabled;
  final bool blockLanTraffic;
  final bool blockIpv6Traffic;
  final List<String> allowedApps;
  final List<String> blockedApps;
  final bool autoReconnect;
  final int reconnectAttempts;
  final bool notificationEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KillSwitchSettings({
    this.id,
    this.userId,
    required this.isEnabled,
    required this.blockLanTraffic,
    required this.blockIpv6Traffic,
    required this.allowedApps,
    required this.blockedApps,
    required this.autoReconnect,
    required this.reconnectAttempts,
    required this.notificationEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory KillSwitchSettings.fromJson(Map<String, dynamic> json) {
    return KillSwitchSettings(
      id: json['id'],
      userId: json['user_id'],
      isEnabled: json['is_enabled'] ?? false,
      blockLanTraffic: json['block_lan_traffic'] ?? false,
      blockIpv6Traffic: json['block_ipv6_traffic'] ?? true,
      allowedApps: json['allowed_apps'] != null 
          ? List<String>.from(json['allowed_apps']) 
          : [],
      blockedApps: json['blocked_apps'] != null 
          ? List<String>.from(json['blocked_apps']) 
          : [],
      autoReconnect: json['auto_reconnect'] ?? true,
      reconnectAttempts: json['reconnect_attempts'] ?? 3,
      notificationEnabled: json['notification_enabled'] ?? true,
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
      'is_enabled': isEnabled,
      'block_lan_traffic': blockLanTraffic,
      'block_ipv6_traffic': blockIpv6Traffic,
      'allowed_apps': allowedApps,
      'blocked_apps': blockedApps,
      'auto_reconnect': autoReconnect,
      'reconnect_attempts': reconnectAttempts,
      'notification_enabled': notificationEnabled,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  KillSwitchSettings copyWith({
    int? id,
    int? userId,
    bool? isEnabled,
    bool? blockLanTraffic,
    bool? blockIpv6Traffic,
    List<String>? allowedApps,
    List<String>? blockedApps,
    bool? autoReconnect,
    int? reconnectAttempts,
    bool? notificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KillSwitchSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isEnabled: isEnabled ?? this.isEnabled,
      blockLanTraffic: blockLanTraffic ?? this.blockLanTraffic,
      blockIpv6Traffic: blockIpv6Traffic ?? this.blockIpv6Traffic,
      allowedApps: allowedApps ?? this.allowedApps,
      blockedApps: blockedApps ?? this.blockedApps,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static KillSwitchSettings getDefault() {
    return KillSwitchSettings(
      isEnabled: false,
      blockLanTraffic: false,
      blockIpv6Traffic: true,
      allowedApps: [],
      blockedApps: [],
      autoReconnect: true,
      reconnectAttempts: 3,
      notificationEnabled: true,
    );
  }
}

class KillSwitchResponse {
  final bool success;
  final String message;
  final KillSwitchSettings? data;
  final String? error;

  KillSwitchResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory KillSwitchResponse.fromJson(Map<String, dynamic> json) {
    return KillSwitchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? KillSwitchSettings.fromJson(json['data']) 
          : null,
      error: json['error'],
    );
  }
}

class KillSwitchStatus {
  final bool isEnabled;
  final DateTime? lastUpdated;

  KillSwitchStatus({
    required this.isEnabled,
    this.lastUpdated,
  });

  factory KillSwitchStatus.fromJson(Map<String, dynamic> json) {
    return KillSwitchStatus(
      isEnabled: json['is_enabled'] ?? false,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : null,
    );
  }
}