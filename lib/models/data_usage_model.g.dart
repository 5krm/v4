// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_usage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataUsageMonitor _$DataUsageMonitorFromJson(Map<String, dynamic> json) =>
    DataUsageMonitor(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      enabled: json['enabled'] as bool,
      dailyLimitMb: (json['dailyLimitMb'] as num?)?.toInt(),
      weeklyLimitMb: (json['weeklyLimitMb'] as num?)?.toInt(),
      monthlyLimitMb: (json['monthlyLimitMb'] as num?)?.toInt(),
      autoDisconnect: json['autoDisconnect'] as bool,
      warningThreshold: (json['warningThreshold'] as num).toInt(),
      resetDay: (json['resetDay'] as num).toInt(),
      dailyUsageBytes: (json['dailyUsageBytes'] as num).toInt(),
      weeklyUsageBytes: (json['weeklyUsageBytes'] as num).toInt(),
      monthlyUsageBytes: (json['monthlyUsageBytes'] as num).toInt(),
      lastResetDaily: json['lastResetDaily'] == null
          ? null
          : DateTime.parse(json['lastResetDaily'] as String),
      lastResetWeekly: json['lastResetWeekly'] == null
          ? null
          : DateTime.parse(json['lastResetWeekly'] as String),
      lastResetMonthly: json['lastResetMonthly'] == null
          ? null
          : DateTime.parse(json['lastResetMonthly'] as String),
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationSetting.fromJson(e as Map<String, dynamic>))
          .toList(),
      excludedApps: (json['excludedApps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      priorityApps: (json['priorityApps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      appUsage: (json['appUsage'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DataUsageMonitorToJson(DataUsageMonitor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'enabled': instance.enabled,
      'dailyLimitMb': instance.dailyLimitMb,
      'weeklyLimitMb': instance.weeklyLimitMb,
      'monthlyLimitMb': instance.monthlyLimitMb,
      'autoDisconnect': instance.autoDisconnect,
      'warningThreshold': instance.warningThreshold,
      'resetDay': instance.resetDay,
      'dailyUsageBytes': instance.dailyUsageBytes,
      'weeklyUsageBytes': instance.weeklyUsageBytes,
      'monthlyUsageBytes': instance.monthlyUsageBytes,
      'lastResetDaily': instance.lastResetDaily?.toIso8601String(),
      'lastResetWeekly': instance.lastResetWeekly?.toIso8601String(),
      'lastResetMonthly': instance.lastResetMonthly?.toIso8601String(),
      'notifications': instance.notifications,
      'excludedApps': instance.excludedApps,
      'priorityApps': instance.priorityApps,
      'appUsage': instance.appUsage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

NotificationSetting _$NotificationSettingFromJson(Map<String, dynamic> json) =>
    NotificationSetting(
      type: json['type'] as String,
      enabled: json['enabled'] as bool,
      threshold: (json['threshold'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotificationSettingToJson(
  NotificationSetting instance,
) => <String, dynamic>{
  'type': instance.type,
  'enabled': instance.enabled,
  'threshold': instance.threshold,
};

DataUsageRecord _$DataUsageRecordFromJson(Map<String, dynamic> json) =>
    DataUsageRecord(
      id: (json['id'] as num).toInt(),
      monitorId: (json['monitorId'] as num).toInt(),
      appName: json['appName'] as String,
      downloadBytes: (json['downloadBytes'] as num).toInt(),
      uploadBytes: (json['uploadBytes'] as num).toInt(),
      connectionType: json['connectionType'] as String,
      serverLocation: json['serverLocation'] as String?,
      sessionId: json['sessionId'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DataUsageRecordToJson(DataUsageRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'monitorId': instance.monitorId,
      'appName': instance.appName,
      'downloadBytes': instance.downloadBytes,
      'uploadBytes': instance.uploadBytes,
      'connectionType': instance.connectionType,
      'serverLocation': instance.serverLocation,
      'sessionId': instance.sessionId,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UsageStats _$UsageStatsFromJson(Map<String, dynamic> json) => UsageStats(
  currentUsage: UsagePeriodData.fromJson(
    json['currentUsage'] as Map<String, dynamic>,
  ),
  usageByPeriod: UsagePeriodData.fromJson(
    json['usageByPeriod'] as Map<String, dynamic>,
  ),
  topApps: (json['topApps'] as List<dynamic>)
      .map((e) => AppUsageData.fromJson(e as Map<String, dynamic>))
      .toList(),
  usageTimeline: (json['usageTimeline'] as List<dynamic>)
      .map((e) => UsageTimelineData.fromJson(e as Map<String, dynamic>))
      .toList(),
  serverUsage: (json['serverUsage'] as List<dynamic>)
      .map((e) => ServerUsageData.fromJson(e as Map<String, dynamic>))
      .toList(),
  connectionTypeUsage: (json['connectionTypeUsage'] as List<dynamic>)
      .map((e) => ConnectionTypeUsageData.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
  limits: UsageLimits.fromJson(json['limits'] as Map<String, dynamic>),
  remainingData: RemainingData.fromJson(
    json['remainingData'] as Map<String, dynamic>,
  ),
  usagePercentage: (json['usagePercentage'] as num).toDouble(),
);

Map<String, dynamic> _$UsageStatsToJson(UsageStats instance) =>
    <String, dynamic>{
      'currentUsage': instance.currentUsage,
      'usageByPeriod': instance.usageByPeriod,
      'topApps': instance.topApps,
      'usageTimeline': instance.usageTimeline,
      'serverUsage': instance.serverUsage,
      'connectionTypeUsage': instance.connectionTypeUsage,
      'status': instance.status,
      'limits': instance.limits,
      'remainingData': instance.remainingData,
      'usagePercentage': instance.usagePercentage,
    };

UsagePeriodData _$UsagePeriodDataFromJson(Map<String, dynamic> json) =>
    UsagePeriodData(
      totalDownload: (json['totalDownload'] as num).toInt(),
      totalUpload: (json['totalUpload'] as num).toInt(),
      totalUsage: (json['totalUsage'] as num).toInt(),
      recordCount: (json['recordCount'] as num).toInt(),
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$UsagePeriodDataToJson(UsagePeriodData instance) =>
    <String, dynamic>{
      'totalDownload': instance.totalDownload,
      'totalUpload': instance.totalUpload,
      'totalUsage': instance.totalUsage,
      'recordCount': instance.recordCount,
      'period': instance.period,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

AppUsageData _$AppUsageDataFromJson(Map<String, dynamic> json) => AppUsageData(
  appName: json['appName'] as String,
  totalUsage: (json['totalUsage'] as num).toInt(),
  formattedUsage: json['formattedUsage'] as String,
  sessionCount: (json['sessionCount'] as num).toInt(),
);

Map<String, dynamic> _$AppUsageDataToJson(AppUsageData instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'totalUsage': instance.totalUsage,
      'formattedUsage': instance.formattedUsage,
      'sessionCount': instance.sessionCount,
    };

UsageTimelineData _$UsageTimelineDataFromJson(Map<String, dynamic> json) =>
    UsageTimelineData(
      datetime: DateTime.parse(json['datetime'] as String),
      date: json['date'] as String,
      hour: (json['hour'] as num).toInt(),
      usage: (json['usage'] as num).toInt(),
      formattedUsage: json['formattedUsage'] as String,
    );

Map<String, dynamic> _$UsageTimelineDataToJson(UsageTimelineData instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'date': instance.date,
      'hour': instance.hour,
      'usage': instance.usage,
      'formattedUsage': instance.formattedUsage,
    };

ServerUsageData _$ServerUsageDataFromJson(Map<String, dynamic> json) =>
    ServerUsageData(
      serverLocation: json['serverLocation'] as String,
      totalUsage: (json['totalUsage'] as num).toInt(),
      formattedUsage: json['formattedUsage'] as String,
      connectionCount: (json['connectionCount'] as num).toInt(),
    );

Map<String, dynamic> _$ServerUsageDataToJson(ServerUsageData instance) =>
    <String, dynamic>{
      'serverLocation': instance.serverLocation,
      'totalUsage': instance.totalUsage,
      'formattedUsage': instance.formattedUsage,
      'connectionCount': instance.connectionCount,
    };

ConnectionTypeUsageData _$ConnectionTypeUsageDataFromJson(
  Map<String, dynamic> json,
) => ConnectionTypeUsageData(
  connectionType: json['connectionType'] as String,
  totalUsage: (json['totalUsage'] as num).toInt(),
  formattedUsage: json['formattedUsage'] as String,
  sessionCount: (json['sessionCount'] as num).toInt(),
);

Map<String, dynamic> _$ConnectionTypeUsageDataToJson(
  ConnectionTypeUsageData instance,
) => <String, dynamic>{
  'connectionType': instance.connectionType,
  'totalUsage': instance.totalUsage,
  'formattedUsage': instance.formattedUsage,
  'sessionCount': instance.sessionCount,
};

UsageLimits _$UsageLimitsFromJson(Map<String, dynamic> json) => UsageLimits(
  daily: (json['daily'] as num?)?.toInt(),
  weekly: (json['weekly'] as num?)?.toInt(),
  monthly: (json['monthly'] as num?)?.toInt(),
);

Map<String, dynamic> _$UsageLimitsToJson(UsageLimits instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'weekly': instance.weekly,
      'monthly': instance.monthly,
    };

RemainingData _$RemainingDataFromJson(Map<String, dynamic> json) =>
    RemainingData(
      daily: (json['daily'] as num?)?.toInt(),
      weekly: (json['weekly'] as num?)?.toInt(),
      monthly: (json['monthly'] as num?)?.toInt(),
      formattedDaily: json['formattedDaily'] as String?,
      formattedWeekly: json['formattedWeekly'] as String?,
      formattedMonthly: json['formattedMonthly'] as String?,
    );

Map<String, dynamic> _$RemainingDataToJson(RemainingData instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'weekly': instance.weekly,
      'monthly': instance.monthly,
      'formattedDaily': instance.formattedDaily,
      'formattedWeekly': instance.formattedWeekly,
      'formattedMonthly': instance.formattedMonthly,
    };

UsageAlert _$UsageAlertFromJson(Map<String, dynamic> json) => UsageAlert(
  type: json['type'] as String,
  message: json['message'] as String,
  severity: json['severity'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UsageAlertToJson(UsageAlert instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
    };

RealTimeUsageData _$RealTimeUsageDataFromJson(Map<String, dynamic> json) =>
    RealTimeUsageData(
      currentSession: CurrentSessionData.fromJson(
        json['currentSession'] as Map<String, dynamic>,
      ),
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => DataUsageRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeApps: (json['activeApps'] as List<dynamic>)
          .map((e) => ActiveAppData.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RealTimeUsageDataToJson(RealTimeUsageData instance) =>
    <String, dynamic>{
      'currentSession': instance.currentSession,
      'recentActivity': instance.recentActivity,
      'activeApps': instance.activeApps,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
    };

CurrentSessionData _$CurrentSessionDataFromJson(Map<String, dynamic> json) =>
    CurrentSessionData(
      downloadBytes: (json['downloadBytes'] as num).toInt(),
      uploadBytes: (json['uploadBytes'] as num).toInt(),
      totalBytes: (json['totalBytes'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$CurrentSessionDataToJson(CurrentSessionData instance) =>
    <String, dynamic>{
      'downloadBytes': instance.downloadBytes,
      'uploadBytes': instance.uploadBytes,
      'totalBytes': instance.totalBytes,
      'duration': instance.duration,
    };

ActiveAppData _$ActiveAppDataFromJson(Map<String, dynamic> json) =>
    ActiveAppData(
      appName: json['appName'] as String,
      usage: (json['usage'] as num).toInt(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );

Map<String, dynamic> _$ActiveAppDataToJson(ActiveAppData instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'usage': instance.usage,
      'lastActivity': instance.lastActivity.toIso8601String(),
    };
