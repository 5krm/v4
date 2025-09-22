class SplitTunnelSettings {
  final int? id;
  final int userId;
  final bool enabled;
  final String mode; // 'include' or 'exclude'
  final List<String> apps;
  final List<String> domains;
  final List<String> ipRanges;
  final bool bypassLocalNetwork;
  final bool bypassDns;
  final bool autoDetectApps;
  final bool notificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SplitTunnelSettings({
    this.id,
    required this.userId,
    required this.enabled,
    required this.mode,
    required this.apps,
    required this.domains,
    required this.ipRanges,
    required this.bypassLocalNetwork,
    required this.bypassDns,
    required this.autoDetectApps,
    required this.notificationsEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory SplitTunnelSettings.fromJson(Map<String, dynamic> json) {
    return SplitTunnelSettings(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      enabled: json['enabled'] ?? false,
      mode: json['mode'] ?? 'exclude',
      apps: List<String>.from(json['apps'] ?? []),
      domains: List<String>.from(json['domains'] ?? []),
      ipRanges: List<String>.from(json['ip_ranges'] ?? []),
      bypassLocalNetwork: json['bypass_local_network'] ?? true,
      bypassDns: json['bypass_dns'] ?? false,
      autoDetectApps: json['auto_detect_apps'] ?? true,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'enabled': enabled,
      'mode': mode,
      'apps': apps,
      'domains': domains,
      'ip_ranges': ipRanges,
      'bypass_local_network': bypassLocalNetwork,
      'bypass_dns': bypassDns,
      'auto_detect_apps': autoDetectApps,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SplitTunnelSettings copyWith({
    int? id,
    int? userId,
    bool? enabled,
    String? mode,
    List<String>? apps,
    List<String>? domains,
    List<String>? ipRanges,
    bool? bypassLocalNetwork,
    bool? bypassDns,
    bool? autoDetectApps,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitTunnelSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      apps: apps ?? this.apps,
      domains: domains ?? this.domains,
      ipRanges: ipRanges ?? this.ipRanges,
      bypassLocalNetwork: bypassLocalNetwork ?? this.bypassLocalNetwork,
      bypassDns: bypassDns ?? this.bypassDns,
      autoDetectApps: autoDetectApps ?? this.autoDetectApps,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static SplitTunnelSettings getDefault() {
    return SplitTunnelSettings(
      userId: 0,
      enabled: false,
      mode: 'exclude',
      apps: [],
      domains: [],
      ipRanges: [],
      bypassLocalNetwork: true,
      bypassDns: false,
      autoDetectApps: true,
      notificationsEnabled: true,
    );
  }
}

class SplitTunnelResponse {
  final bool success;
  final String message;
  final SplitTunnelSettings? data;
  final Map<String, dynamic>? errors;

  SplitTunnelResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory SplitTunnelResponse.fromJson(Map<String, dynamic> json) {
    return SplitTunnelResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SplitTunnelSettings.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class InstalledApp {
  final String identifier;
  final String name;
  final String? icon;
  final String category;
  final bool isSelected;

  InstalledApp({
    required this.identifier,
    required this.name,
    this.icon,
    required this.category,
    this.isSelected = false,
  });

  factory InstalledApp.fromJson(Map<String, dynamic> json) {
    return InstalledApp(
      identifier: json['identifier'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      category: json['category'] ?? 'Unknown',
      isSelected: json['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'icon': icon,
      'category': category,
      'is_selected': isSelected,
    };
  }

  InstalledApp copyWith({
    String? identifier,
    String? name,
    String? icon,
    String? category,
    bool? isSelected,
  }) {
    return InstalledApp(
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class InstalledAppsResponse {
  final bool success;
  final String message;
  final List<InstalledApp> data;
  final Map<String, dynamic>? errors;

  InstalledAppsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  factory InstalledAppsResponse.fromJson(Map<String, dynamic> json) {
    return InstalledAppsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<InstalledApp>.from(json['data'].map((x) => InstalledApp.fromJson(x)))
          : [],
      errors: json['errors'],
    );
  }
}