import 'package:json_annotation/json_annotation.dart';

part 'data_usage_model.g.dart';

@JsonSerializable()
class DataUsageMonitor {
  final int id;
  final int userId;
  final bool enabled;
  final int? dailyLimitMb;
  final int? weeklyLimitMb;
  final int? monthlyLimitMb;
  final bool autoDisconnect;
  final int warningThreshold;
  final int resetDay;
  final int dailyUsageBytes;
  final int weeklyUsageBytes;
  final int monthlyUsageBytes;
  final DateTime? lastResetDaily;
  final DateTime? lastResetWeekly;
  final DateTime? lastResetMonthly;
  final List<NotificationSetting>? notifications;
  final List<String>? excludedApps;
  final List<String>? priorityApps;
  final Map<String, int>? appUsage;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataUsageMonitor({
    required this.id,
    required this.userId,
    required this.enabled,
    this.dailyLimitMb,
    this.weeklyLimitMb,
    this.monthlyLimitMb,
    required this.autoDisconnect,
    required this.warningThreshold,
    required this.resetDay,
    required this.dailyUsageBytes,
    required this.weeklyUsageBytes,
    required this.monthlyUsageBytes,
    this.lastResetDaily,
    this.lastResetWeekly,
    this.lastResetMonthly,
    this.notifications,
    this.excludedApps,
    this.priorityApps,
    this.appUsage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataUsageMonitor.fromJson(Map<String, dynamic> json) =>
      _$DataUsageMonitorFromJson(json);

  Map<String, dynamic> toJson() => _$DataUsageMonitorToJson(this);

  DataUsageMonitor copyWith({
    int? id,
    int? userId,
    bool? enabled,
    int? dailyLimitMb,
    int? weeklyLimitMb,
    int? monthlyLimitMb,
    bool? autoDisconnect,
    int? warningThreshold,
    int? resetDay,
    int? dailyUsageBytes,
    int? weeklyUsageBytes,
    int? monthlyUsageBytes,
    DateTime? lastResetDaily,
    DateTime? lastResetWeekly,
    DateTime? lastResetMonthly,
    List<NotificationSetting>? notifications,
    List<String>? excludedApps,
    List<String>? priorityApps,
    Map<String, int>? appUsage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataUsageMonitor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      dailyLimitMb: dailyLimitMb ?? this.dailyLimitMb,
      weeklyLimitMb: weeklyLimitMb ?? this.weeklyLimitMb,
      monthlyLimitMb: monthlyLimitMb ?? this.monthlyLimitMb,
      autoDisconnect: autoDisconnect ?? this.autoDisconnect,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      resetDay: resetDay ?? this.resetDay,
      dailyUsageBytes: dailyUsageBytes ?? this.dailyUsageBytes,
      weeklyUsageBytes: weeklyUsageBytes ?? this.weeklyUsageBytes,
      monthlyUsageBytes: monthlyUsageBytes ?? this.monthlyUsageBytes,
      lastResetDaily: lastResetDaily ?? this.lastResetDaily,
      lastResetWeekly: lastResetWeekly ?? this.lastResetWeekly,
      lastResetMonthly: lastResetMonthly ?? this.lastResetMonthly,
      notifications: notifications ?? this.notifications,
      excludedApps: excludedApps ?? this.excludedApps,
      priorityApps: priorityApps ?? this.priorityApps,
      appUsage: appUsage ?? this.appUsage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  int get totalUsageBytes => dailyUsageBytes + weeklyUsageBytes + monthlyUsageBytes;
  
  String get formattedDailyUsage => _formatBytes(dailyUsageBytes);
  String get formattedWeeklyUsage => _formatBytes(weeklyUsageBytes);
  String get formattedMonthlyUsage => _formatBytes(monthlyUsageBytes);
  String get formattedTotalUsage => _formatBytes(totalUsageBytes);
  
  double get dailyUsagePercentage {
    if (dailyLimitMb == null || dailyLimitMb == 0) return 0.0;
    return (dailyUsageBytes / (dailyLimitMb! * 1024 * 1024)) * 100;
  }
  
  double get weeklyUsagePercentage {
    if (weeklyLimitMb == null || weeklyLimitMb == 0) return 0.0;
    return (weeklyUsageBytes / (weeklyLimitMb! * 1024 * 1024)) * 100;
  }
  
  double get monthlyUsagePercentage {
    if (monthlyLimitMb == null || monthlyLimitMb == 0) return 0.0;
    return (monthlyUsageBytes / (monthlyLimitMb! * 1024 * 1024)) * 100;
  }
  
  bool get isNearDailyLimit => dailyUsagePercentage >= warningThreshold;
  bool get isNearWeeklyLimit => weeklyUsagePercentage >= warningThreshold;
  bool get isNearMonthlyLimit => monthlyUsagePercentage >= warningThreshold;
  
  bool get hasExceededDailyLimit => dailyUsagePercentage >= 100;
  bool get hasExceededWeeklyLimit => weeklyUsagePercentage >= 100;
  bool get hasExceededMonthlyLimit => monthlyUsagePercentage >= 100;
  
  bool get shouldShowWarning => isNearDailyLimit || isNearWeeklyLimit || isNearMonthlyLimit;
  bool get shouldAutoDisconnect => autoDisconnect && (hasExceededDailyLimit || hasExceededWeeklyLimit || hasExceededMonthlyLimit);
  
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  static DataUsageMonitor defaultSettings() {
    return DataUsageMonitor(
      id: 0,
      userId: 0,
      enabled: true,
      dailyLimitMb: 1000, // 1GB
      weeklyLimitMb: 5000, // 5GB
      monthlyLimitMb: 20000, // 20GB
      autoDisconnect: false,
      warningThreshold: 80,
      resetDay: 1,
      dailyUsageBytes: 0,
      weeklyUsageBytes: 0,
      monthlyUsageBytes: 0,
      notifications: [
        NotificationSetting(
          type: 'warning',
          enabled: true,
          threshold: 80,
        ),
        NotificationSetting(
          type: 'limit_reached',
          enabled: true,
          threshold: 100,
        ),
        NotificationSetting(
          type: 'daily_summary',
          enabled: false,
          threshold: null,
        ),
      ],
      excludedApps: [],
      priorityApps: [],
      appUsage: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@JsonSerializable()
class NotificationSetting {
  final String type;
  final bool enabled;
  final int? threshold;

  NotificationSetting({
    required this.type,
    required this.enabled,
    this.threshold,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingToJson(this);

  NotificationSetting copyWith({
    String? type,
    bool? enabled,
    int? threshold,
  }) {
    return NotificationSetting(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      threshold: threshold ?? this.threshold,
    );
  }
}

@JsonSerializable()
class DataUsageRecord {
  final int id;
  final int monitorId;
  final String appName;
  final int downloadBytes;
  final int uploadBytes;
  final String connectionType;
  final String? serverLocation;
  final String? sessionId;
  final DateTime recordedAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataUsageRecord({
    required this.id,
    required this.monitorId,
    required this.appName,
    required this.downloadBytes,
    required this.uploadBytes,
    required this.connectionType,
    this.serverLocation,
    this.sessionId,
    required this.recordedAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataUsageRecord.fromJson(Map<String, dynamic> json) =>
      _$DataUsageRecordFromJson(json);

  Map<String, dynamic> toJson() => _$DataUsageRecordToJson(this);

  DataUsageRecord copyWith({
    int? id,
    int? monitorId,
    String? appName,
    int? downloadBytes,
    int? uploadBytes,
    String? connectionType,
    String? serverLocation,
    String? sessionId,
    DateTime? recordedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataUsageRecord(
      id: id ?? this.id,
      monitorId: monitorId ?? this.monitorId,
      appName: appName ?? this.appName,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      connectionType: connectionType ?? this.connectionType,
      serverLocation: serverLocation ?? this.serverLocation,
      sessionId: sessionId ?? this.sessionId,
      recordedAt: recordedAt ?? this.recordedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  int get totalBytes => downloadBytes + uploadBytes;
  String get formattedTotal => _formatBytes(totalBytes);
  String get formattedDownload => _formatBytes(downloadBytes);
  String get formattedUpload => _formatBytes(uploadBytes);
  
  double get downloadPercentage {
    if (totalBytes == 0) return 0.0;
    return (downloadBytes / totalBytes) * 100;
  }
  
  double get uploadPercentage {
    if (totalBytes == 0) return 0.0;
    return (uploadBytes / totalBytes) * 100;
  }
  
  int? get duration => metadata?['duration'] as int?;
  
  double get downloadSpeed {
    if (duration == null || duration == 0) return 0.0;
    return downloadBytes / duration!;
  }
  
  double get uploadSpeed {
    if (duration == null || duration == 0) return 0.0;
    return uploadBytes / duration!;
  }
  
  String get formattedDownloadSpeed => '${_formatBytes(downloadSpeed.round())}/s';
  String get formattedUploadSpeed => '${_formatBytes(uploadSpeed.round())}/s';
  
  bool get isHighUsage => totalBytes > (100 * 1024 * 1024); // > 100MB
  
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }
}

@JsonSerializable()
class UsageStats {
  final UsagePeriodData currentUsage;
  final UsagePeriodData usageByPeriod;
  final List<AppUsageData> topApps;
  final List<UsageTimelineData> usageTimeline;
  final List<ServerUsageData> serverUsage;
  final List<ConnectionTypeUsageData> connectionTypeUsage;
  final String status;
  final UsageLimits limits;
  final RemainingData remainingData;
  final double usagePercentage;

  UsageStats({
    required this.currentUsage,
    required this.usageByPeriod,
    required this.topApps,
    required this.usageTimeline,
    required this.serverUsage,
    required this.connectionTypeUsage,
    required this.status,
    required this.limits,
    required this.remainingData,
    required this.usagePercentage,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);
}

@JsonSerializable()
class UsagePeriodData {
  final int totalDownload;
  final int totalUpload;
  final int totalUsage;
  final int recordCount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;

  UsagePeriodData({
    required this.totalDownload,
    required this.totalUpload,
    required this.totalUsage,
    required this.recordCount,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  factory UsagePeriodData.fromJson(Map<String, dynamic> json) =>
      _$UsagePeriodDataFromJson(json);

  Map<String, dynamic> toJson() => _$UsagePeriodDataToJson(this);
  
  String get formattedTotalDownload => _formatBytes(totalDownload);
  String get formattedTotalUpload => _formatBytes(totalUpload);
  String get formattedTotalUsage => _formatBytes(totalUsage);
  
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }
}

@JsonSerializable()
class AppUsageData {
  final String appName;
  final int totalUsage;
  final String formattedUsage;
  final int sessionCount;

  AppUsageData({
    required this.appName,
    required this.totalUsage,
    required this.formattedUsage,
    required this.sessionCount,
  });

  factory AppUsageData.fromJson(Map<String, dynamic> json) =>
      _$AppUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppUsageDataToJson(this);
}

@JsonSerializable()
class UsageTimelineData {
  final DateTime datetime;
  final String date;
  final int hour;
  final int usage;
  final String formattedUsage;

  UsageTimelineData({
    required this.datetime,
    required this.date,
    required this.hour,
    required this.usage,
    required this.formattedUsage,
  });

  factory UsageTimelineData.fromJson(Map<String, dynamic> json) =>
      _$UsageTimelineDataFromJson(json);

  Map<String, dynamic> toJson() => _$UsageTimelineDataToJson(this);
}

@JsonSerializable()
class ServerUsageData {
  final String serverLocation;
  final int totalUsage;
  final String formattedUsage;
  final int connectionCount;

  ServerUsageData({
    required this.serverLocation,
    required this.totalUsage,
    required this.formattedUsage,
    required this.connectionCount,
  });

  factory ServerUsageData.fromJson(Map<String, dynamic> json) =>
      _$ServerUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ServerUsageDataToJson(this);
}

@JsonSerializable()
class ConnectionTypeUsageData {
  final String connectionType;
  final int totalUsage;
  final String formattedUsage;
  final int sessionCount;

  ConnectionTypeUsageData({
    required this.connectionType,
    required this.totalUsage,
    required this.formattedUsage,
    required this.sessionCount,
  });

  factory ConnectionTypeUsageData.fromJson(Map<String, dynamic> json) =>
      _$ConnectionTypeUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionTypeUsageDataToJson(this);
}

@JsonSerializable()
class UsageLimits {
  final int? daily;
  final int? weekly;
  final int? monthly;

  UsageLimits({
    this.daily,
    this.weekly,
    this.monthly,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) =>
      _$UsageLimitsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageLimitsToJson(this);
}

@JsonSerializable()
class RemainingData {
  final int? daily;
  final int? weekly;
  final int? monthly;
  final String? formattedDaily;
  final String? formattedWeekly;
  final String? formattedMonthly;

  RemainingData({
    this.daily,
    this.weekly,
    this.monthly,
    this.formattedDaily,
    this.formattedWeekly,
    this.formattedMonthly,
  });

  factory RemainingData.fromJson(Map<String, dynamic> json) =>
      _$RemainingDataFromJson(json);

  Map<String, dynamic> toJson() => _$RemainingDataToJson(this);
}

@JsonSerializable()
class UsageAlert {
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  UsageAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.data,
  });

  factory UsageAlert.fromJson(Map<String, dynamic> json) =>
      _$UsageAlertFromJson(json);

  Map<String, dynamic> toJson() => _$UsageAlertToJson(this);
  
  bool get isWarning => severity == 'warning';
  bool get isError => severity == 'error';
  bool get isInfo => severity == 'info';
}

@JsonSerializable()
class RealTimeUsageData {
  final CurrentSessionData currentSession;
  final List<DataUsageRecord> recentActivity;
  final List<ActiveAppData> activeApps;
  final String status;
  final DateTime timestamp;

  RealTimeUsageData({
    required this.currentSession,
    required this.recentActivity,
    required this.activeApps,
    required this.status,
    required this.timestamp,
  });

  factory RealTimeUsageData.fromJson(Map<String, dynamic> json) =>
      _$RealTimeUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeUsageDataToJson(this);
}

@JsonSerializable()
class CurrentSessionData {
  final int downloadBytes;
  final int uploadBytes;
  final int totalBytes;
  final int duration;

  CurrentSessionData({
    required this.downloadBytes,
    required this.uploadBytes,
    required this.totalBytes,
    required this.duration,
  });

  factory CurrentSessionData.fromJson(Map<String, dynamic> json) =>
      _$CurrentSessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentSessionDataToJson(this);
  
  String get formattedDownload => _formatBytes(downloadBytes);
  String get formattedUpload => _formatBytes(uploadBytes);
  String get formattedTotal => _formatBytes(totalBytes);
  String get formattedDuration => _formatDuration(duration);
  
  double get downloadSpeed => duration > 0 ? downloadBytes / duration : 0.0;
  double get uploadSpeed => duration > 0 ? uploadBytes / duration : 0.0;
  
  String get formattedDownloadSpeed => '${_formatBytes(downloadSpeed.round())}/s';
  String get formattedUploadSpeed => '${_formatBytes(uploadSpeed.round())}/s';
  
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

@JsonSerializable()
class ActiveAppData {
  final String appName;
  final int usage;
  final DateTime lastActivity;

  ActiveAppData({
    required this.appName,
    required this.usage,
    required this.lastActivity,
  });

  factory ActiveAppData.fromJson(Map<String, dynamic> json) =>
      _$ActiveAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveAppDataToJson(this);
  
  String get formattedUsage => _formatBytes(usage);
  
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }
}