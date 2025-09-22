import 'package:dbug_vpn/services/api_service.dart' as main_api;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/vpn_health_model.dart';
import '../services/api_service.dart';

class VpnHealthController extends GetxController {
  // Observables
  final RxList<VpnHealthMonitor> monitors = <VpnHealthMonitor>[].obs;
  final RxList<VpnHealthCheck> recentChecks = <VpnHealthCheck>[].obs;
  final RxList<VpnHealthAlert> activeAlerts = <VpnHealthAlert>[].obs;
  final Rx<VpnHealthSummary> healthSummary = VpnHealthSummary.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreatingMonitor = false.obs;
  final RxString error = ''.obs;
  final RxInt selectedMonitorIndex = 0.obs;
  final RxString selectedTimeRange = '24h'.obs;
  final RxBool autoRefresh = true.obs;
  final RxInt refreshInterval = 30.obs; // seconds

  // Performance metrics
  final RxList<PerformanceMetric> performanceHistory =
      <PerformanceMetric>[].obs;
  final RxList<UptimeMetric> uptimeHistory = <UptimeMetric>[].obs;
  final RxList<AlertTrend> alertTrends = <AlertTrend>[].obs;

  // UI State
  final RxBool showAdvancedSettings = false.obs;
  final RxBool showPerformanceChart = true.obs;
  final RxBool showUptimeChart = true.obs;
  final RxBool showAlertChart = false.obs;
  final RxString chartType = 'line'.obs; // line, bar, area

  // Filters
  final RxString statusFilter = 'all'.obs;
  final RxString severityFilter = 'all'.obs;
  final RxString monitorTypeFilter = 'all'.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    initializeHealthMonitoring();
    setupAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // Initialization
  Future<void> initializeHealthMonitoring() async {
    isLoading.value = true;
    error.value = '';

    try {
      await Future.wait([
        loadMonitors(),
        loadHealthSummary(),
        loadActiveAlerts(),
        loadPerformanceHistory(),
      ]);
    } catch (e) {
      error.value = 'Failed to initialize health monitoring: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Monitor Management
  Future<void> loadMonitors() async {
    try {
      final response = await ApiService.get('/vpn-health/monitors');
      if (response['success']) {
        monitors.value = (response['data'] as List)
            .map((json) => VpnHealthMonitor.fromJson(json))
            .toList();
      }
    } catch (e) {
      error.value = 'Failed to load monitors: $e';
    }
  }

  Future<void> createMonitor({
    required String name,
    required int serverId,
    required String monitorType,
    required Map<String, dynamic> configuration,
  }) async {
    isCreatingMonitor.value = true;

    try {
      final response = await ApiService.post('/vpn-health/monitors', {
        'monitor_name': name,
        'server_id': serverId,
        'monitor_type': monitorType,
        'configuration': configuration,
      });

      if (response['success']) {
        final newMonitor = VpnHealthMonitor.fromJson(response['data']);
        monitors.add(newMonitor);
        Get.snackbar(
          'Success',
          'Health monitor created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create monitor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingMonitor.value = false;
    }
  }

  Future<void> updateMonitor(
      int monitorId, Map<String, dynamic> updates) async {
    try {
      final response =
          await ApiService.put('/vpn-health/monitors/$monitorId', updates);

      if (response['success']) {
        final updatedMonitor = VpnHealthMonitor.fromJson(response['data']);
        final index = monitors.indexWhere((m) => m.id == monitorId);
        if (index != -1) {
          monitors[index] = updatedMonitor;
        }

        Get.snackbar(
          'Success',
          'Monitor updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update monitor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteMonitor(int monitorId) async {
    try {
      final response =
          await ApiService.delete('/vpn-health/monitors/$monitorId');

      if (response['success']) {
        monitors.removeWhere((m) => m.id == monitorId);
        Get.snackbar(
          'Success',
          'Monitor deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete monitor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleMonitor(int monitorId, bool isActive) async {
    try {
      final response =
          await ApiService.put('/vpn-health/monitors/$monitorId/toggle', {
        'is_active': isActive,
      });

      if (response['success']) {
        final index = monitors.indexWhere((m) => m.id == monitorId);
        if (index != -1) {
          monitors[index] = monitors[index].copyWith(isActive: isActive);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle monitor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Health Checks
  Future<void> runHealthCheck(int monitorId) async {
    try {
      final response =
          await ApiService.post('/vpn-health/monitors/$monitorId/check', {});

      if (response['success']) {
        final check = VpnHealthCheck.fromJson(response['data']);
        recentChecks.insert(0, check);

        // Update monitor status
        final index = monitors.indexWhere((m) => m.id == monitorId);
        if (index != -1) {
          monitors[index] = monitors[index].copyWith(
            lastCheckAt: DateTime.now(),
          );
        }

        Get.snackbar(
          'Success',
          'Health check completed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Health check failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadRecentChecks({int limit = 50}) async {
    try {
      final response = await ApiService.get('/vpn-health/checks?limit=$limit');

      if (response['success']) {
        recentChecks.value = (response['data'] as List)
            .map((json) => VpnHealthCheck.fromJson(json))
            .toList();
      }
    } catch (e) {
      error.value = 'Failed to load recent checks: $e';
    }
  }

  Future<void> loadActiveAlerts() async {
    try {
      final response = await ApiService.get('/vpn-health/alerts/active');

      if (response['success']) {
        activeAlerts.value = (response['data'] as List)
            .map((json) => VpnHealthAlert.fromJson(json))
            .toList();
      }
    } catch (e) {
      error.value = 'Failed to load active alerts: $e';
    }
  }

  Future<void> acknowledgeAlert(int alertId) async {
    try {
      final response =
          await ApiService.put('/vpn-health/alerts/$alertId/acknowledge', {});

      if (response['success']) {
        activeAlerts.removeWhere((alert) => alert.id == alertId);
        Get.snackbar(
          'Success',
          'Alert acknowledged',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to acknowledge alert: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resolveAlert(int alertId) async {
    try {
      final response =
          await ApiService.put('/vpn-health/alerts/$alertId/resolve', {});

      if (response['success']) {
        activeAlerts.removeWhere((alert) => alert.id == alertId);
        Get.snackbar(
          'Success',
          'Alert resolved',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resolve alert: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Health Summary
  Future<void> loadHealthSummary() async {
    try {
      final response = await ApiService.get('/vpn-health/summary');

      if (response['success']) {
        healthSummary.value = VpnHealthSummary.fromJson(response['data']);
      }
    } catch (e) {
      error.value = 'Failed to load health summary: $e';
    }
  }

  Future<void> refreshHealthSummary() async {
    isLoading.value = true;
    try {
      await loadHealthSummary();
      await loadMonitors();
      await loadActiveAlerts();
      await loadPerformanceHistory();
    } catch (e) {
      error.value = 'Failed to refresh health summary: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Performance Metrics
  Future<void> loadPerformanceHistory({String range = '24h'}) async {
    try {
      final response =
          await ApiService.get('/vpn-health/performance?range=$range');

      if (response['success']) {
        performanceHistory.value = (response['data']['metrics'] as List)
            .map((json) => PerformanceMetric.fromJson(json))
            .toList();

        uptimeHistory.value = (response['data']['uptime'] as List)
            .map((json) => UptimeMetric.fromJson(json))
            .toList();

        alertTrends.value = (response['data']['alerts'] as List)
            .map((json) => AlertTrend.fromJson(json))
            .toList();
      }
    } catch (e) {
      error.value = 'Failed to load performance history: $e';
    }
  }

  Future<void> loadDetailedMetrics(int monitorId) async {
    try {
      final response =
          await ApiService.get('/vpn-health/monitors/$monitorId/metrics');

      if (response['success']) {
        // Handle detailed metrics
        Get.snackbar(
          'Success',
          'Detailed metrics loaded',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load detailed metrics: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> generateHealthReport({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  }) async {
    try {
      final response = await ApiService.post('/vpn-health/reports', {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'format': format,
      });

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Health report generated and sent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate health report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> scheduleHealthCheck(
      int monitorId, DateTime scheduledTime) async {
    try {
      final response =
          await ApiService.post('/vpn-health/monitors/$monitorId/schedule', {
        'scheduled_time': scheduledTime.toIso8601String(),
      });

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Health check scheduled',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to schedule health check: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadHistoricalData(int monitorId, String range) async {
    try {
      final response = await ApiService.get(
          '/vpn-health/monitors/$monitorId/history?range=$range');

      if (response['success']) {
        // Handle historical data
        Get.snackbar(
          'Success',
          'Historical data loaded',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load historical data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadComparisonData(List<int> monitorIds) async {
    try {
      final response = await ApiService.post('/vpn-health/comparison', {
        'monitor_ids': monitorIds,
      });

      if (response['success']) {
        // Handle comparison data
        Get.snackbar(
          'Success',
          'Comparison data loaded',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load comparison data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> exportHealthData({
    required List<int> monitorIds,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.post('/vpn-health/export', {
        'monitor_ids': monitorIds,
        'format': format,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Health data exported successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export health data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> configureAlerting(
      int monitorId, Map<String, dynamic> alertConfig) async {
    try {
      final response = await ApiService.put(
          '/vpn-health/monitors/$monitorId/alerts', alertConfig);

      if (response['success']) {
        final updatedMonitor = VpnHealthMonitor.fromJson(response['data']);
        final index = monitors.indexWhere((m) => m.id == monitorId);
        if (index != -1) {
          monitors[index] = updatedMonitor;
        }

        Get.snackbar(
          'Success',
          'Alerting configuration updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update alerting configuration: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> testNotification(int monitorId) async {
    try {
      final response = await ApiService.post(
          '/vpn-health/monitors/$monitorId/test-notification', {});

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Test notification sent',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send test notification: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadRecommendations(int monitorId) async {
    try {
      final response = await ApiService.get(
          '/vpn-health/monitors/$monitorId/recommendations');

      if (response['success']) {
        // Handle recommendations
        Get.snackbar(
          'Success',
          'Recommendations loaded',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load recommendations: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> applyRecommendation(
      int monitorId, String recommendationId) async {
    try {
      final response = await ApiService.post(
          '/vpn-health/monitors/$monitorId/recommendations/$recommendationId/apply',
          {});

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Recommendation applied successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to apply recommendation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadIncidentHistory(int monitorId) async {
    try {
      final response =
          await ApiService.get('/vpn-health/monitors/$monitorId/incidents');

      if (response['success']) {
        // Handle incident history
        Get.snackbar(
          'Success',
          'Incident history loaded',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load incident history: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> createIncidentReport(
      int monitorId, Map<String, dynamic> reportData) async {
    try {
      final response = await ApiService.post(
          '/vpn-health/monitors/$monitorId/incidents', reportData);

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Incident report created',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create incident report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // UI State Management
  void setSelectedMonitor(int index) {
    selectedMonitorIndex.value = index;
  }

  void setTimeRange(String range) {
    selectedTimeRange.value = range;
    loadPerformanceHistory(range: range);
  }

  void toggleAutoRefresh() {
    autoRefresh.value = !autoRefresh.value;
    if (autoRefresh.value) {
      setupAutoRefresh();
    } else {
      _refreshTimer?.cancel();
    }
  }

  void setRefreshInterval(int seconds) {
    refreshInterval.value = seconds;
    if (autoRefresh.value) {
      setupAutoRefresh();
    }
  }

  void setupAutoRefresh() {
    _refreshTimer?.cancel();
    if (autoRefresh.value) {
      _refreshTimer =
          Timer.periodic(Duration(seconds: refreshInterval.value), (timer) {
        refreshHealthSummary();
      });
    }
  }

  void toggleAdvancedSettings() {
    showAdvancedSettings.value = !showAdvancedSettings.value;
  }

  void togglePerformanceChart() {
    showPerformanceChart.value = !showPerformanceChart.value;
  }

  void toggleUptimeChart() {
    showUptimeChart.value = !showUptimeChart.value;
  }

  void toggleAlertChart() {
    showAlertChart.value = !showAlertChart.value;
  }

  void setChartType(String type) {
    chartType.value = type;
  }

  void setStatusFilter(String filter) {
    statusFilter.value = filter;
  }

  void setSeverityFilter(String filter) {
    severityFilter.value = filter;
  }

  void setMonitorTypeFilter(String filter) {
    monitorTypeFilter.value = filter;
  }

  void clearError() {
    error.value = '';
  }

  // Add missing getters
  List<VpnHealthAlert> get filteredAlerts {
    return activeAlerts;
  }

  List<VpnHealthMonitor> get filteredMonitors {
    return monitors;
  }

  // Add missing methods
  Future<void> refreshData() async {
    await refreshHealthSummary();
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  void changeTimeRange(String range) {
    setTimeRange(range);
  }

  Future<void> performManualCheck(int monitorId) async {
    await runHealthCheck(monitorId);
  }

  void applyStatusFilter(String filter) {
    setStatusFilter(filter);
  }

  void applySeverityFilter(String filter) {
    setSeverityFilter(filter);
  }

  void applyMonitorTypeFilter(String filter) {
    setMonitorTypeFilter(filter);
  }

  void clearFilters() {
    setStatusFilter('all');
    setSeverityFilter('all');
    setMonitorTypeFilter('all');
  }

  void updateRefreshInterval(int seconds) {
    setRefreshInterval(seconds);
  }
}
