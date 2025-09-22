// ignore_for_file: avoid_print, duplicate_ignore

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/api/api_client.dart';
import '../model/analytics_model.dart';
import '../utils/my_helper.dart';

class AnalyticsController extends GetxController {
  final ApiClient apiClient;
  final GetStorage userData = GetStorage();

  AnalyticsController({required this.apiClient});

  // Observable variables
  var isLoading = false.obs;
  var dashboardData = Rxn<AnalyticsDashboard>();
  var analyticsHistory = <UserAnalytics>[].obs;
  var statsSummary = Rxn<StatsSummary>();
  var selectedTimeframe = 'month'.obs;

  // Current session tracking
  var currentSessionId = ''.obs;
  var sessionStartTime = Rxn<DateTime>();
  var isSessionActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadStatsSummary();
  }

  /// Load dashboard analytics data
  Future<void> loadDashboardData({String timeframe = 'month'}) async {
    try {
      isLoading.value = true;
      selectedTimeframe.value = timeframe;

      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(
            '${apiClient.baseUrl}/api/analytics/dashboard?timeframe=$timeframe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          dashboardData.value = AnalyticsDashboard.fromJson(jsonData['data']);
        } else {
          throw Exception(
              jsonData['message'] ?? 'Failed to load dashboard data');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load analytics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load analytics history with pagination
  Future<void> loadAnalyticsHistory({int page = 1, int perPage = 20}) async {
    try {
      if (page == 1) {
        isLoading.value = true;
        analyticsHistory.clear();
      }

      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(
            '${apiClient.baseUrl}/api/analytics/history?page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final List<dynamic> data = jsonData['data'];
          final newAnalytics =
              data.map((item) => UserAnalytics.fromJson(item)).toList();

          if (page == 1) {
            analyticsHistory.assignAll(newAnalytics);
          } else {
            analyticsHistory.addAll(newAnalytics);
          }
        } else {
          throw Exception(
              jsonData['message'] ?? 'Failed to load analytics history');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      if (page == 1) {
        isLoading.value = false;
      }
    }
  }

  /// Load statistics summary
  Future<void> loadStatsSummary() async {
    try {
      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${apiClient.baseUrl}/api/analytics/stats-summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          statsSummary.value = StatsSummary.fromJson(jsonData['data']);
        } else {
          throw Exception(
              jsonData['message'] ?? 'Failed to load stats summary');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to load stats summary: $e');
    }
  }

  /// Start a new analytics session
  Future<void> startSession({
    required String serverCountry,
    required String serverName,
    String? userLocation,
  }) async {
    try {
      currentSessionId.value = const Uuid().v4();
      sessionStartTime.value = DateTime.now();
      isSessionActive.value = true;

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${apiClient.baseUrl}/api/analytics/record-session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'session_id': currentSessionId.value,
          'connection_start': sessionStartTime.value!.toIso8601String(),
          'server_country': serverCountry,
          'server_name': serverName,
          'user_location': userLocation,
          'device_type': deviceInfo,
          'app_version': packageInfo.version,
        }),
      );

      if (response.statusCode != 200) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Failed to start session');
      }
    } catch (e) {
      print('Failed to start analytics session: $e');
    }
  }

  /// End the current analytics session
  Future<void> endSession({
    int? dataUploaded,
    int? dataDownloaded,
    String connectionStatus = 'disconnected',
  }) async {
    try {
      if (!isSessionActive.value || currentSessionId.value.isEmpty) {
        return;
      }

      final endTime = DateTime.now();
      final duration = sessionStartTime.value != null
          ? endTime.difference(sessionStartTime.value!).inSeconds
          : 0;

      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${apiClient.baseUrl}/api/analytics/update-session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'session_id': currentSessionId.value,
          'connection_end': endTime.toIso8601String(),
          'duration_seconds': duration,
          'data_uploaded': dataUploaded ?? 0,
          'data_downloaded': dataDownloaded ?? 0,
          'connection_status': connectionStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Reset session variables
        isSessionActive.value = false;
        currentSessionId.value = '';
        sessionStartTime.value = null;

        // Refresh dashboard data to show updated statistics
        loadDashboardData(timeframe: selectedTimeframe.value);
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Failed to end session');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to end analytics session: $e');
    }
  }

  /// Refresh all analytics data
  Future<void> refreshData() async {
    await Future.wait([
      loadDashboardData(timeframe: selectedTimeframe.value),
      loadStatsSummary(),
      loadAnalyticsHistory(page: 1),
    ]);
  }

  /// Get device information for analytics
  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release} (${androidInfo.model})';
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion} (${iosInfo.model})';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get random data usage for demo purposes
  Map<String, int> getRandomDataUsage() {
    final random = Random();
    return {
      'uploaded': random.nextInt(1024 * 1024 * 100), // Up to 100MB
      'downloaded': random.nextInt(1024 * 1024 * 500), // Up to 500MB
    };
  }

  /// Format bytes to human readable format
  String formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// Format duration to human readable format
  String formatDuration(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  /// Get color for chart data based on index
  Color getChartColor(int index) {
    const colors = [
      Color(0xFF4285F4),
      Color(0xFF34A853),
      Color(0xFFEA4335),
      Color(0xFFFBBC05),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
      Color(0xFFFF9800),
      Color(0xFF795548),
    ];
    return colors[index % colors.length];
  }

  /// Fetch speed test statistics
  Future<Map<String, dynamic>?> getSpeedTestStats(
      {String timeframe = 'all'}) async {
    try {
      String? token = userData.read(MyHelper.bToken);
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(
            '${apiClient.baseUrl}${MyHelper.speedTestStatsUrl}?timeframe=$timeframe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return jsonData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch speed test stats: $e');
      return null;
    }
  }
}
