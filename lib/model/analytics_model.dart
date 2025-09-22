class UserAnalytics {
  final int? id;
  final int? userId;
  final String? sessionId;
  final DateTime? connectionStart;
  final DateTime? connectionEnd;
  final int? durationSeconds;
  final String? serverCountry;
  final String? serverName;
  final int? dataUploaded;
  final int? dataDownloaded;
  final String? userIp;
  final String? userLocation;
  final String? deviceType;
  final String? appVersion;
  final String? connectionStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserAnalytics({
    this.id,
    this.userId,
    this.sessionId,
    this.connectionStart,
    this.connectionEnd,
    this.durationSeconds,
    this.serverCountry,
    this.serverName,
    this.dataUploaded,
    this.dataDownloaded,
    this.userIp,
    this.userLocation,
    this.deviceType,
    this.appVersion,
    this.connectionStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) => UserAnalytics(
        id: json["id"],
        userId: json["user_id"],
        sessionId: json["session_id"],
        connectionStart: json["connection_start"] == null
            ? null
            : DateTime.parse(json["connection_start"]),
        connectionEnd: json["connection_end"] == null
            ? null
            : DateTime.parse(json["connection_end"]),
        durationSeconds: json["duration_seconds"],
        serverCountry: json["server_country"],
        serverName: json["server_name"],
        dataUploaded: json["data_uploaded"],
        dataDownloaded: json["data_downloaded"],
        userIp: json["user_ip"],
        userLocation: json["user_location"],
        deviceType: json["device_type"],
        appVersion: json["app_version"],
        connectionStatus: json["connection_status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "session_id": sessionId,
        "connection_start": connectionStart?.toIso8601String(),
        "connection_end": connectionEnd?.toIso8601String(),
        "duration_seconds": durationSeconds,
        "server_country": serverCountry,
        "server_name": serverName,
        "data_uploaded": dataUploaded,
        "data_downloaded": dataDownloaded,
        "user_ip": userIp,
        "user_location": userLocation,
        "device_type": deviceType,
        "app_version": appVersion,
        "connection_status": connectionStatus,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  // Helper getters
  int get totalDataUsage => (dataUploaded ?? 0) + (dataDownloaded ?? 0);

  String get formattedDuration {
    if (durationSeconds == null) return "00:00:00";

    final hours = (durationSeconds! / 3600).floor();
    final minutes = ((durationSeconds! % 3600) / 60).floor();
    final seconds = durationSeconds! % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDataUsage {
    final bytes = totalDataUsage.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    int unitIndex = 0;
    double size = bytes;

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}

class AnalyticsDashboard {
  final AnalyticsStatistics? statistics;
  final List<DailyUsage>? dailyUsage;
  final List<ServerUsage>? serverUsage;
  final String? timeframe;

  AnalyticsDashboard({
    this.statistics,
    this.dailyUsage,
    this.serverUsage,
    this.timeframe,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      AnalyticsDashboard(
        statistics: json["statistics"] == null
            ? null
            : AnalyticsStatistics.fromJson(json["statistics"]),
        dailyUsage: json["daily_usage"] == null
            ? []
            : List<DailyUsage>.from(
                json["daily_usage"].map((x) => DailyUsage.fromJson(x))),
        serverUsage: json["server_usage"] == null
            ? []
            : List<ServerUsage>.from(
                json["server_usage"].map((x) => ServerUsage.fromJson(x))),
        timeframe: json["timeframe"],
      );

  Map<String, dynamic> toJson() => {
        "statistics": statistics?.toJson(),
        "daily_usage": dailyUsage?.map((x) => x.toJson()).toList(),
        "server_usage": serverUsage?.map((x) => x.toJson()).toList(),
        "timeframe": timeframe,
      };
}

class AnalyticsStatistics {
  final int? totalSessions;
  final int? totalDuration;
  final int? totalDataUsage;
  final double? averageSessionDuration;
  final String? mostUsedServer;
  final double? connectionSuccessRate;

  AnalyticsStatistics({
    this.totalSessions,
    this.totalDuration,
    this.totalDataUsage,
    this.averageSessionDuration,
    this.mostUsedServer,
    this.connectionSuccessRate,
  });

  factory AnalyticsStatistics.fromJson(Map<String, dynamic> json) =>
      AnalyticsStatistics(
        totalSessions: json["total_sessions"],
        totalDuration: json["total_duration"],
        totalDataUsage: json["total_data_usage"],
        averageSessionDuration: json["average_session_duration"]?.toDouble(),
        mostUsedServer: json["most_used_server"],
        connectionSuccessRate: json["connection_success_rate"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "total_sessions": totalSessions,
        "total_duration": totalDuration,
        "total_data_usage": totalDataUsage,
        "average_session_duration": averageSessionDuration,
        "most_used_server": mostUsedServer,
        "connection_success_rate": connectionSuccessRate,
      };

  String get formattedTotalDuration {
    if (totalDuration == null) return "00:00:00";

    final hours = (totalDuration! / 3600).floor();
    final minutes = ((totalDuration! % 3600) / 60).floor();
    final seconds = totalDuration! % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDataUsage {
    if (totalDataUsage == null) return "0 B";

    final bytes = totalDataUsage!.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    int unitIndex = 0;
    double size = bytes;

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  String get formattedAverageSession {
    if (averageSessionDuration == null) return "00:00:00";

    final duration = averageSessionDuration!.round();
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).floor();
    final seconds = duration % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class DailyUsage {
  final String? date;
  final int? sessions;
  final int? totalDuration;
  final int? totalData;

  DailyUsage({
    this.date,
    this.sessions,
    this.totalDuration,
    this.totalData,
  });

  factory DailyUsage.fromJson(Map<String, dynamic> json) => DailyUsage(
        date: json["date"],
        sessions: json["sessions"],
        totalDuration: json["total_duration"],
        totalData: json["total_data"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "sessions": sessions,
        "total_duration": totalDuration,
        "total_data": totalData,
      };
}

class ServerUsage {
  final String? serverCountry;
  final int? sessions;
  final int? totalDuration;

  ServerUsage({
    this.serverCountry,
    this.sessions,
    this.totalDuration,
  });

  factory ServerUsage.fromJson(Map<String, dynamic> json) => ServerUsage(
        serverCountry: json["server_country"],
        sessions: json["sessions"],
        totalDuration: json["total_duration"],
      );

  Map<String, dynamic> toJson() => {
        "server_country": serverCountry,
        "sessions": sessions,
        "total_duration": totalDuration,
      };
}

class StatsSummary {
  final PeriodStats? today;
  final PeriodStats? thisWeek;
  final PeriodStats? thisMonth;
  final PeriodStats? allTime;

  StatsSummary({
    this.today,
    this.thisWeek,
    this.thisMonth,
    this.allTime,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) => StatsSummary(
        today:
            json["today"] == null ? null : PeriodStats.fromJson(json["today"]),
        thisWeek: json["this_week"] == null
            ? null
            : PeriodStats.fromJson(json["this_week"]),
        thisMonth: json["this_month"] == null
            ? null
            : PeriodStats.fromJson(json["this_month"]),
        allTime: json["all_time"] == null
            ? null
            : PeriodStats.fromJson(json["all_time"]),
      );

  Map<String, dynamic> toJson() => {
        "today": today?.toJson(),
        "this_week": thisWeek?.toJson(),
        "this_month": thisMonth?.toJson(),
        "all_time": allTime?.toJson(),
      };
}

class PeriodStats {
  final int? sessions;
  final int? duration;
  final int? dataUsage;

  PeriodStats({
    this.sessions,
    this.duration,
    this.dataUsage,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) => PeriodStats(
        sessions: json["sessions"],
        duration: json["duration"],
        dataUsage: json["data_usage"],
      );

  Map<String, dynamic> toJson() => {
        "sessions": sessions,
        "duration": duration,
        "data_usage": dataUsage,
      };

  String get formattedDuration {
    if (duration == null) return "00:00:00";

    final hours = (duration! / 3600).floor();
    final minutes = ((duration! % 3600) / 60).floor();
    final seconds = duration! % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDataUsage {
    if (dataUsage == null) return "0 B";

    final bytes = dataUsage!.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    int unitIndex = 0;
    double size = bytes;

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}
