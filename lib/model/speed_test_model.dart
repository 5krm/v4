class SpeedTestModel {
  final String? status;
  final String? message;
  final SpeedTestResultData? data;

  SpeedTestModel({
    this.status,
    this.message,
    this.data,
  });

  factory SpeedTestModel.fromJson(Map<String, dynamic> json) => SpeedTestModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : SpeedTestResultData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class SpeedTestResultData {
  final int id;
  final int userId;
  final double downloadSpeed;
  final double uploadSpeed;
  final int ping;
  final String? serverName;
  final String? serverCountry;
  final String? clientIp;
  final String? clientLocation;
  final String? deviceType;
  final String? appVersion;
  final DateTime testTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpeedTestResultData({
    required this.id,
    required this.userId,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
    required this.serverName,
    required this.serverCountry,
    required this.clientIp,
    required this.clientLocation,
    required this.deviceType,
    required this.appVersion,
    required this.testTimestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpeedTestResultData.fromJson(Map<String, dynamic> json) =>
      SpeedTestResultData(
        id: json["id"],
        userId: json["user_id"],
        downloadSpeed: json["download_speed"] is int
            ? json["download_speed"].toDouble()
            : json["download_speed"],
        uploadSpeed: json["upload_speed"] is int
            ? json["upload_speed"].toDouble()
            : json["upload_speed"],
        ping: json["ping"],
        serverName: json["server_name"],
        serverCountry: json["server_country"],
        clientIp: json["client_ip"],
        clientLocation: json["client_location"],
        deviceType: json["device_type"],
        appVersion: json["app_version"],
        testTimestamp: DateTime.parse(json["test_timestamp"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "download_speed": downloadSpeed,
        "upload_speed": uploadSpeed,
        "ping": ping,
        "server_name": serverName,
        "server_country": serverCountry,
        "client_ip": clientIp,
        "client_location": clientLocation,
        "device_type": deviceType,
        "app_version": appVersion,
        "test_timestamp": testTimestamp.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class SpeedTestHistoryModel {
  final String? status;
  final String? message;
  final List<SpeedTestResultData>? data;
  final Pagination? pagination;

  SpeedTestHistoryModel({
    this.status,
    this.message,
    this.data,
    this.pagination,
  });

  factory SpeedTestHistoryModel.fromJson(Map<String, dynamic> json) =>
      SpeedTestHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SpeedTestResultData>.from(
                json["data"]!.map((x) => SpeedTestResultData.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class SpeedTestStatsModel {
  final String? status;
  final String? message;
  final SpeedTestStats? data;

  SpeedTestStatsModel({
    this.status,
    this.message,
    this.data,
  });

  factory SpeedTestStatsModel.fromJson(Map<String, dynamic> json) =>
      SpeedTestStatsModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null ? null : SpeedTestStats.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class SpeedTestStats {
  final int totalTests;
  final double averageDownload;
  final double averageUpload;
  final double averagePing;
  final double bestDownload;
  final double bestUpload;
  final int bestPing;
  final String timeframe;

  SpeedTestStats({
    required this.totalTests,
    required this.averageDownload,
    required this.averageUpload,
    required this.averagePing,
    required this.bestDownload,
    required this.bestUpload,
    required this.bestPing,
    required this.timeframe,
  });

  factory SpeedTestStats.fromJson(Map<String, dynamic> json) => SpeedTestStats(
        totalTests: json["total_tests"],
        averageDownload: json["average_download"] is int
            ? json["average_download"].toDouble()
            : json["average_download"],
        averageUpload: json["average_upload"] is int
            ? json["average_upload"].toDouble()
            : json["average_upload"],
        averagePing: json["average_ping"] is int
            ? json["average_ping"].toDouble()
            : json["average_ping"],
        bestDownload: json["best_download"] is int
            ? json["best_download"].toDouble()
            : json["best_download"],
        bestUpload: json["best_upload"] is int
            ? json["best_upload"].toDouble()
            : json["best_upload"],
        bestPing: json["best_ping"],
        timeframe: json["timeframe"],
      );

  Map<String, dynamic> toJson() => {
        "total_tests": totalTests,
        "average_download": averageDownload,
        "average_upload": averageUpload,
        "average_ping": averagePing,
        "best_download": bestDownload,
        "best_upload": bestUpload,
        "best_ping": bestPing,
        "timeframe": timeframe,
      };
}

class SpeedTestChartDataModel {
  final String? status;
  final String? message;
  final List<ChartData>? data;

  SpeedTestChartDataModel({
    this.status,
    this.message,
    this.data,
  });

  factory SpeedTestChartDataModel.fromJson(Map<String, dynamic> json) =>
      SpeedTestChartDataModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ChartData>.from(
                json["data"]!.map((x) => ChartData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ChartData {
  final DateTime date;
  final double avgDownload;
  final double avgUpload;
  final double avgPing;

  ChartData({
    required this.date,
    required this.avgDownload,
    required this.avgUpload,
    required this.avgPing,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
        date: DateTime.parse(json["date"]),
        avgDownload: json["avg_download"] is int
            ? json["avg_download"].toDouble()
            : json["avg_download"],
        avgUpload: json["avg_upload"] is int
            ? json["avg_upload"].toDouble()
            : json["avg_upload"],
        avgPing: json["avg_ping"] is int
            ? json["avg_ping"].toDouble()
            : json["avg_ping"],
      );

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "avg_download": avgDownload,
        "avg_upload": avgUpload,
        "avg_ping": avgPing,
      };
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["current_page"],
        perPage: json["per_page"],
        total: json["total"],
        lastPage: json["last_page"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "per_page": perPage,
        "total": total,
        "last_page": lastPage,
      };
}
