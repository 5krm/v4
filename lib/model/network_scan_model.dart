class NetworkScanSettings {
  final String scanType;
  final String? networkName;
  final String? networkSsid;
  final String? gatewayIp;
  final String? subnetMask;
  final List<String> dnsServers;
  final String? targetRange;
  final bool scanPorts;
  final bool scanVulnerabilities;
  final bool scanDevices;

  // Additional properties for UI
  final List<String> scanTypes;
  final String intensity;
  final bool autoScan;
  final String scanSchedule;

  NetworkScanSettings({
    required this.scanType,
    this.networkName,
    this.networkSsid,
    this.gatewayIp,
    this.subnetMask,
    this.dnsServers = const [],
    this.targetRange,
    this.scanPorts = true,
    this.scanVulnerabilities = true,
    this.scanDevices = true,
    this.scanTypes = const ['port_scan', 'vulnerability_scan'],
    this.intensity = 'normal',
    this.autoScan = false,
    this.scanSchedule = 'daily',
  });

  factory NetworkScanSettings.fromJson(Map<String, dynamic> json) {
    return NetworkScanSettings(
      scanType: json['scan_type'] ?? 'full',
      networkName: json['network_name'],
      networkSsid: json['network_ssid'],
      gatewayIp: json['gateway_ip'],
      subnetMask: json['subnet_mask'],
      dnsServers: List<String>.from(json['dns_servers'] ?? []),
      targetRange: json['target_range'],
      scanPorts: json['scan_ports'] ?? true,
      scanVulnerabilities: json['scan_vulnerabilities'] ?? true,
      scanDevices: json['scan_devices'] ?? true,
      scanTypes: List<String>.from(
          json['scan_types'] ?? ['port_scan', 'vulnerability_scan']),
      intensity: json['intensity'] ?? 'normal',
      autoScan: json['auto_scan'] ?? false,
      scanSchedule: json['scan_schedule'] ?? 'daily',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_type': scanType,
      'network_name': networkName,
      'network_ssid': networkSsid,
      'gateway_ip': gatewayIp,
      'subnet_mask': subnetMask,
      'dns_servers': dnsServers,
      'target_range': targetRange,
      'scan_ports': scanPorts,
      'scan_vulnerabilities': scanVulnerabilities,
      'scan_devices': scanDevices,
      'scan_types': scanTypes,
      'intensity': intensity,
      'auto_scan': autoScan,
      'scan_schedule': scanSchedule,
    };
  }

  NetworkScanSettings copyWith({
    String? scanType,
    String? networkName,
    String? networkSsid,
    String? gatewayIp,
    String? subnetMask,
    List<String>? dnsServers,
    String? targetRange,
    bool? scanPorts,
    bool? scanVulnerabilities,
    bool? scanDevices,
    List<String>? scanTypes,
    String? intensity,
    bool? autoScan,
    String? scanSchedule,
  }) {
    return NetworkScanSettings(
      scanType: scanType ?? this.scanType,
      networkName: networkName ?? this.networkName,
      networkSsid: networkSsid ?? this.networkSsid,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      subnetMask: subnetMask ?? this.subnetMask,
      dnsServers: dnsServers ?? this.dnsServers,
      targetRange: targetRange ?? this.targetRange,
      scanPorts: scanPorts ?? this.scanPorts,
      scanVulnerabilities: scanVulnerabilities ?? this.scanVulnerabilities,
      scanDevices: scanDevices ?? this.scanDevices,
      scanTypes: scanTypes ?? this.scanTypes,
      intensity: intensity ?? this.intensity,
      autoScan: autoScan ?? this.autoScan,
      scanSchedule: scanSchedule ?? this.scanSchedule,
    );
  }

  static NetworkScanSettings get defaultSettings => NetworkScanSettings(
        scanType: 'full',
        scanPorts: true,
        scanVulnerabilities: true,
        scanDevices: true,
        scanTypes: ['port_scan', 'vulnerability_scan'],
        intensity: 'normal',
        autoScan: false,
        scanSchedule: 'daily',
      );
}

class NetworkScan {
  final int id;
  final int userId;
  final String scanType;
  final String? networkName;
  final String? networkSsid;
  final String? gatewayIp;
  final String? subnetMask;
  final List<String> dnsServers;
  final String scanStatus;
  final int scanProgress;
  final List<NetworkDevice> devicesFound;
  final List<Vulnerability> vulnerabilitiesFound;
  final List<Threat> threatsDetected;
  final int securityScore;
  final Map<String, dynamic> scanResults;
  final List<Recommendation> recommendations;
  final int? scanDuration;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NetworkScan({
    required this.id,
    required this.userId,
    required this.scanType,
    this.networkName,
    this.networkSsid,
    this.gatewayIp,
    this.subnetMask,
    this.dnsServers = const [],
    required this.scanStatus,
    required this.scanProgress,
    this.devicesFound = const [],
    this.vulnerabilitiesFound = const [],
    this.threatsDetected = const [],
    required this.securityScore,
    this.scanResults = const {},
    this.recommendations = const [],
    this.scanDuration,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NetworkScan.fromJson(Map<String, dynamic> json) {
    return NetworkScan(
      id: json['id'],
      userId: json['user_id'],
      scanType: json['scan_type'],
      networkName: json['network_name'],
      networkSsid: json['network_ssid'],
      gatewayIp: json['gateway_ip'],
      subnetMask: json['subnet_mask'],
      dnsServers: List<String>.from(json['dns_servers'] ?? []),
      scanStatus: json['scan_status'],
      scanProgress: json['scan_progress'],
      devicesFound: (json['devices_found'] as List? ?? [])
          .map((device) => NetworkDevice.fromJson(device))
          .toList(),
      vulnerabilitiesFound: (json['vulnerabilities_found'] as List? ?? [])
          .map((vuln) => Vulnerability.fromJson(vuln))
          .toList(),
      threatsDetected: (json['threats_detected'] as List? ?? [])
          .map((threat) => Threat.fromJson(threat))
          .toList(),
      securityScore: json['security_score'],
      scanResults: Map<String, dynamic>.from(json['scan_results'] ?? {}),
      recommendations: (json['recommendations'] as List? ?? [])
          .map((rec) => Recommendation.fromJson(rec))
          .toList(),
      scanDuration: json['scan_duration'],
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'scan_type': scanType,
      'network_name': networkName,
      'network_ssid': networkSsid,
      'gateway_ip': gatewayIp,
      'subnet_mask': subnetMask,
      'dns_servers': dnsServers,
      'scan_status': scanStatus,
      'scan_progress': scanProgress,
      'devices_found': devicesFound.map((device) => device.toJson()).toList(),
      'vulnerabilities_found':
          vulnerabilitiesFound.map((vuln) => vuln.toJson()).toList(),
      'threats_detected':
          threatsDetected.map((threat) => threat.toJson()).toList(),
      'security_score': securityScore,
      'scan_results': scanResults,
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'scan_duration': scanDuration,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isInProgress => ['pending', 'running'].contains(scanStatus);
  bool get isCompleted => scanStatus == 'completed';
  bool get isFailed => scanStatus == 'failed';
  bool get isStopped => scanStatus == 'stopped';
  bool get isActive => ['pending', 'running'].contains(scanStatus);

  // Additional getters for UI
  int get threatsFound => threatsDetected.length;
  int get devices => devicesFound.length;
  List<Threat> get threats => threatsDetected;
  List<NetworkDevice> get devicesList => devicesFound;

  String get statusDisplay {
    switch (scanStatus) {
      case 'pending':
        return 'Pending';
      case 'running':
        return 'Running';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'stopped':
        return 'Stopped';
      default:
        return scanStatus;
    }
  }

  String get formattedStartTime {
    if (startedAt == null) return 'Unknown';
    return '${startedAt!.year}-${startedAt!.month.toString().padLeft(2, '0')}-${startedAt!.day.toString().padLeft(2, '0')} ${startedAt!.hour.toString().padLeft(2, '0')}:${startedAt!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCompletedTime {
    if (completedAt == null) return 'Not completed';
    return '${completedAt!.year}-${completedAt!.month.toString().padLeft(2, '0')}-${completedAt!.day.toString().padLeft(2, '0')} ${completedAt!.hour.toString().padLeft(2, '0')}:${completedAt!.minute.toString().padLeft(2, '0')}';
  }

  String get duration {
    if (scanDuration == null) return 'Unknown';
    final minutes = scanDuration! ~/ 60;
    final seconds = scanDuration! % 60;
    return '${minutes}m ${seconds}s';
  }

  double get progress => scanProgress / 100.0;
}

class NetworkDevice {
  final String ip;
  final String? mac;
  final String? hostname;
  final String deviceType;
  final String? vendor;
  final String? os;
  final List<int> openPorts;
  final DateTime lastSeen;

  NetworkDevice({
    required this.ip,
    this.mac,
    this.hostname,
    required this.deviceType,
    this.vendor,
    this.os,
    this.openPorts = const [],
    required this.lastSeen,
  });

  factory NetworkDevice.fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ip: json['ip'],
      mac: json['mac'],
      hostname: json['hostname'],
      deviceType: json['device_type'],
      vendor: json['vendor'],
      os: json['os'],
      openPorts: List<int>.from(json['open_ports'] ?? []),
      lastSeen: DateTime.parse(json['last_seen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'mac': mac,
      'hostname': hostname,
      'device_type': deviceType,
      'vendor': vendor,
      'os': os,
      'open_ports': openPorts,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  String get displayName {
    if (hostname != null && hostname!.isNotEmpty) {
      return hostname!;
    }
    return ip;
  }

  String get deviceIcon {
    switch (deviceType.toLowerCase()) {
      case 'router':
        return '🌐';
      case 'computer':
      case 'desktop':
      case 'laptop':
        return '💻';
      case 'mobile':
      case 'smartphone':
      case 'tablet':
        return '📱';
      case 'printer':
        return '🖨️';
      case 'camera':
        return '📷';
      case 'smart_tv':
      case 'tv':
        return '📺';
      case 'game_console':
        return '🎮';
      case 'iot':
      case 'smart_device':
        return '🏠';
      default:
        return '📟';
    }
  }
}

class Vulnerability {
  final String type;
  final String severity;
  final String? device;
  final int? port;
  final String? service;
  final String description;
  final String recommendation;
  final double? cvssScore;

  Vulnerability({
    required this.type,
    required this.severity,
    this.device,
    this.port,
    this.service,
    required this.description,
    required this.recommendation,
    this.cvssScore,
  });

  factory Vulnerability.fromJson(Map<String, dynamic> json) {
    return Vulnerability(
      type: json['type'],
      severity: json['severity'],
      device: json['device'],
      port: json['port'],
      service: json['service'],
      description: json['description'],
      recommendation: json['recommendation'],
      cvssScore: json['cvss_score']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'device': device,
      'port': port,
      'service': service,
      'description': description,
      'recommendation': recommendation,
      'cvss_score': cvssScore,
    };
  }

  String get severityIcon {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '🔴';
      case 'high':
        return '🟠';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }
}

class Threat {
  final String type;
  final String severity;
  final String? device;
  final String description;
  final String? details;
  final DateTime? firstSeen;
  final int? confidence;

  Threat({
    required this.type,
    required this.severity,
    this.device,
    required this.description,
    this.details,
    this.firstSeen,
    this.confidence,
  });

  factory Threat.fromJson(Map<String, dynamic> json) {
    return Threat(
      type: json['type'],
      severity: json['severity'],
      device: json['device'],
      description: json['description'],
      details: json['details'],
      firstSeen: json['first_seen'] != null
          ? DateTime.parse(json['first_seen'])
          : null,
      confidence: json['confidence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'device': device,
      'description': description,
      'details': details,
      'first_seen': firstSeen?.toIso8601String(),
      'confidence': confidence,
    };
  }

  String get severityIcon {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '🔴';
      case 'high':
        return '🟠';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }

  String get confidenceText {
    if (confidence == null) return 'Unknown';
    if (confidence! >= 90) return 'Very High';
    if (confidence! >= 75) return 'High';
    if (confidence! >= 50) return 'Medium';
    if (confidence! >= 25) return 'Low';
    return 'Very Low';
  }
}

class Recommendation {
  final String type;
  final String priority;
  final String title;
  final String description;
  final String action;

  Recommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      type: json['type'],
      priority: json['priority'],
      title: json['title'],
      description: json['description'],
      action: json['action'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'priority': priority,
      'title': title,
      'description': description,
      'action': action,
    };
  }

  String get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'critical':
        return '🔴';
      case 'high':
        return '🟠';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }
}

class NetworkInfo {
  final String? networkName;
  final String? networkSsid;
  final String? gatewayIp;
  final String? subnetMask;
  final List<String> dnsServers;
  final String? localIp;
  final String? macAddress;
  final String? connectionType;
  final int? signalStrength;
  final String? encryptionType;

  NetworkInfo({
    this.networkName,
    this.networkSsid,
    this.gatewayIp,
    this.subnetMask,
    this.dnsServers = const [],
    this.localIp,
    this.macAddress,
    this.connectionType,
    this.signalStrength,
    this.encryptionType,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      networkName: json['network_name'],
      networkSsid: json['network_ssid'],
      gatewayIp: json['gateway_ip'],
      subnetMask: json['subnet_mask'],
      dnsServers: List<String>.from(json['dns_servers'] ?? []),
      localIp: json['local_ip'],
      macAddress: json['mac_address'],
      connectionType: json['connection_type'],
      signalStrength: json['signal_strength'],
      encryptionType: json['encryption_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_name': networkName,
      'network_ssid': networkSsid,
      'gateway_ip': gatewayIp,
      'subnet_mask': subnetMask,
      'dns_servers': dnsServers,
      'local_ip': localIp,
      'mac_address': macAddress,
      'connection_type': connectionType,
      'signal_strength': signalStrength,
      'encryption_type': encryptionType,
    };
  }

  String get signalStrengthText {
    if (signalStrength == null) return 'Unknown';
    if (signalStrength! >= -30) return 'Excellent';
    if (signalStrength! >= -50) return 'Good';
    if (signalStrength! >= -60) return 'Fair';
    if (signalStrength! >= -70) return 'Weak';
    return 'Very Weak';
  }
}

class NetworkScanResponse {
  final bool success;
  final String? message;
  final NetworkScan? scan;
  final List<NetworkScan>? scans;
  final NetworkInfo? networkInfo;

  NetworkScanResponse({
    required this.success,
    this.message,
    this.scan,
    this.scans,
    this.networkInfo,
  });

  factory NetworkScanResponse.fromJson(Map<String, dynamic> json) {
    return NetworkScanResponse(
      success: json['success'],
      message: json['message'],
      scan: json['data']?['scan'] != null
          ? NetworkScan.fromJson(json['data']['scan'])
          : null,
      scans: json['data']?['scans'] != null
          ? (json['data']['scans'] as List)
              .map((scan) => NetworkScan.fromJson(scan))
              .toList()
          : null,
      networkInfo: json['data'] != null &&
              json['data'] is Map<String, dynamic> &&
              !json['data'].containsKey('scan') &&
              !json['data'].containsKey('scans')
          ? NetworkInfo.fromJson(json['data'])
          : null,
    );
  }
}
