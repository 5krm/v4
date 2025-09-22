import 'package:get/get.dart';
import 'dart:async';
import '../models/data_usage_model.dart';
import '../services/data_usage_api.dart';
import '../utils/logger.dart';
import '../utils/storage_helper.dart';

class DataUsageController extends GetxController {
  final DataUsageApi _api = DataUsageApi();
  final Logger _logger = Logger('DataUsageController');

  // Observables
  final Rx<DataUsageMonitor?> _monitor = Rx<DataUsageMonitor?>(null);
  final RxList<DataUsageRecord> _recentRecords = <DataUsageRecord>[].obs;
  final Rx<UsageStats?> _stats = Rx<UsageStats?>(null);
  final RxList<UsageAlert> _alerts = <UsageAlert>[].obs;
  final Rx<RealTimeUsageData?> _realTimeData = Rx<RealTimeUsageData?>(null);
  final RxList<AppUsageData> _topApps = <AppUsageData>[].obs;
  
  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingStats = false.obs;
  final RxBool _isLoadingRealTime = false.obs;
  final RxBool _isRecordingUsage = false.obs;
  
  // Error states
  final RxString _error = ''.obs;
  final RxString _statsError = ''.obs;
  
  // Settings
  final RxBool _autoRefresh = true.obs;
  final RxInt _refreshInterval = 30.obs; // seconds
  final RxString _selectedPeriod = 'daily'.obs;
  final RxInt _timelineDays = 7.obs;
  
  // Timers
  Timer? _refreshTimer;
  Timer? _realTimeTimer;
  
  // Current context
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  
  // Getters
  DataUsageMonitor? get monitor => _monitor.value;
  List<DataUsageRecord> get recentRecords => _recentRecords;
  UsageStats? get stats => _stats.value;
  List<UsageAlert> get alerts => _alerts;
  RealTimeUsageData? get realTimeData => _realTimeData.value;
  List<AppUsageData> get topApps => _topApps;
  
  bool get isLoading => _isLoading.value;
  bool get isLoadingStats => _isLoadingStats.value;
  bool get isLoadingRealTime => _isLoadingRealTime.value;
  bool get isRecordingUsage => _isRecordingUsage.value;
  
  String get error => _error.value;
  String get statsError => _statsError.value;
  
  bool get autoRefresh => _autoRefresh.value;
  int get refreshInterval => _refreshInterval.value;
  String get selectedPeriod => _selectedPeriod.value;
  int get timelineDays => _timelineDays.value;
  
  bool get isEnabled => monitor?.enabled ?? false;
  bool get hasAlerts => alerts.isNotEmpty;
  bool get shouldAutoDisconnect => monitor?.shouldAutoDisconnect ?? false;
  bool get isNearLimit => monitor?.shouldShowWarning ?? false;
  
  // Status getters
  String get statusText {
    if (monitor == null) return 'Not configured';
    if (!monitor!.enabled) return 'Disabled';
    if (monitor!.hasExceededDailyLimit) return 'Daily limit exceeded';
    if (monitor!.hasExceededWeeklyLimit) return 'Weekly limit exceeded';
    if (monitor!.hasExceededMonthlyLimit) return 'Monthly limit exceeded';
    if (monitor!.isNearDailyLimit) return 'Near daily limit';
    if (monitor!.isNearWeeklyLimit) return 'Near weekly limit';
    if (monitor!.isNearMonthlyLimit) return 'Near monthly limit';
    return 'Normal';
  }
  
  double get overallUsagePercentage {
    if (monitor == null) return 0.0;
    return [monitor!.dailyUsagePercentage, monitor!.weeklyUsagePercentage, monitor!.monthlyUsagePercentage]
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeFromStorage();
    _startAutoRefresh();
    _startRealTimeMonitoring();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _realTimeTimer?.cancel();
    super.onClose();
  }

  // Initialization
  Future<void> _initializeFromStorage() async {
    try {
      final cachedMonitor = await StorageHelper.getString('data_usage_monitor');
      if (cachedMonitor != null) {
        // Parse cached monitor if needed
      }
      
      await loadSettings();
    } catch (e) {
      _logger.error('Failed to initialize from storage: $e');
    }
  }

  // Auto-refresh management
  void _startAutoRefresh() {
    if (!_autoRefresh.value) return;
    
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: _refreshInterval.value), (timer) {
      if (_autoRefresh.value) {
        refreshData();
      }
    });
  }

  void _startRealTimeMonitoring() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isEnabled) {
        getRealTimeUsage();
      }
    });
  }

  // Settings management
  Future<void> loadSettings() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      final response = await _api.getSettings();
      
      if (response.isSuccess && response.data != null) {
        _monitor.value = response.data;
        await _saveToStorage();
        await loadAlerts();
        _logger.info('Data usage settings loaded successfully');
      } else {
        _error.value = response.message;
        _logger.error('Failed to load settings: ${response.message}');
      }
    } catch (e) {
      _error.value = 'Failed to load settings';
      _logger.error('Error loading settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateSettings({
    bool? enabled,
    int? dailyLimitMb,
    int? weeklyLimitMb,
    int? monthlyLimitMb,
    bool? autoDisconnect,
    int? warningThreshold,
    int? resetDay,
    List<NotificationSetting>? notifications,
    List<String>? excludedApps,
    List<String>? priorityApps,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      final response = await _api.updateSettings(
        enabled: enabled,
        dailyLimitMb: dailyLimitMb,
        weeklyLimitMb: weeklyLimitMb,
        monthlyLimitMb: monthlyLimitMb,
        autoDisconnect: autoDisconnect,
        warningThreshold: warningThreshold,
        resetDay: resetDay,
        notifications: notifications,
        excludedApps: excludedApps,
        priorityApps: priorityApps,
      );
      
      if (response.isSuccess && response.data != null) {
        _monitor.value = response.data;
        await _saveToStorage();
        _logger.info('Settings updated successfully');
        
        // Restart monitoring if enabled state changed
        if (enabled != null) {
          if (enabled) {
            _startRealTimeMonitoring();
          } else {
            _realTimeTimer?.cancel();
          }
        }
      } else {
        _error.value = response.message;
        _logger.error('Failed to update settings: ${response.message}');
      }
    } catch (e) {
      _error.value = 'Failed to update settings';
      _logger.error('Error updating settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Usage recording
  Future<void> recordUsage({
    required String appName,
    required int downloadBytes,
    required int uploadBytes,
    String connectionType = 'vpn',
    String? serverLocation,
    Map<String, dynamic>? metadata,
  }) async {
    if (!isEnabled) return;
    
    try {
      _isRecordingUsage.value = true;
      
      final sessionId = _currentSessionId ?? _generateSessionId();
      final enhancedMetadata = {
        ...?metadata,
        'session_start': _sessionStartTime?.toIso8601String(),
        'duration': _sessionStartTime != null 
            ? DateTime.now().difference(_sessionStartTime!).inSeconds 
            : 0,
      };
      
      final response = await _api.recordUsage(
        appName: appName,
        downloadBytes: downloadBytes,
        uploadBytes: uploadBytes,
        connectionType: connectionType,
        serverLocation: serverLocation,
        sessionId: sessionId,
        metadata: enhancedMetadata,
      );
      
      if (response.isSuccess && response.data != null) {
        _recentRecords.insert(0, response.data!);
        if (_recentRecords.length > 100) {
          _recentRecords.removeRange(100, _recentRecords.length);
        }
        
        // Update monitor data if provided in response
        // This would typically include updated usage counters
        await loadSettings(); // Refresh to get updated usage
        
        _logger.debug('Usage recorded: ${response.data!.formattedTotal}');
      } else {
        _logger.error('Failed to record usage: ${response.message}');
      }
    } catch (e) {
      _logger.error('Error recording usage: $e');
    } finally {
      _isRecordingUsage.value = false;
    }
  }

  // Statistics
  Future<void> loadStats({String? period, int? days}) async {
    try {
      _isLoadingStats.value = true;
      _statsError.value = '';
      
      final response = await _api.getStats(
        period: period ?? _selectedPeriod.value,
        days: days ?? _timelineDays.value,
      );
      
      if (response.isSuccess && response.data != null) {
        _stats.value = response.data;
        _topApps.assignAll(response.data!.topApps);
        _logger.info('Usage statistics loaded successfully');
      } else {
        _statsError.value = response.message;
        _logger.error('Failed to load stats: ${response.message}');
      }
    } catch (e) {
      _statsError.value = 'Failed to load statistics';
      _logger.error('Error loading stats: $e');
    } finally {
      _isLoadingStats.value = false;
    }
  }

  // Alerts
  Future<void> loadAlerts() async {
    try {
      final response = await _api.getAlerts();
      
      if (response.isSuccess && response.data != null) {
        _alerts.assignAll(response.data!);
        _logger.debug('Loaded ${response.data!.length} alerts');
      } else {
        _logger.error('Failed to load alerts: ${response.message}');
      }
    } catch (e) {
      _logger.error('Error loading alerts: $e');
    }
  }

  // Real-time data
  Future<void> getRealTimeUsage() async {
    if (!isEnabled) return;
    
    try {
      _isLoadingRealTime.value = true;
      
      final response = await _api.getRealTimeUsage();
      
      if (response.isSuccess && response.data != null) {
        _realTimeData.value = response.data;
      } else {
        _logger.debug('Failed to get real-time data: ${response.message}');
      }
    } catch (e) {
      _logger.debug('Error getting real-time data: $e');
    } finally {
      _isLoadingRealTime.value = false;
    }
  }

  // Reset operations
  Future<void> resetUsage(String resetType) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      final response = await _api.resetUsage(resetType);
      
      if (response.isSuccess && response.data != null) {
        _monitor.value = response.data;
        await _saveToStorage();
        await loadStats(); // Refresh stats
        _logger.info('Usage data reset successfully: $resetType');
      } else {
        _error.value = response.message;
        _logger.error('Failed to reset usage: ${response.message}');
      }
    } catch (e) {
      _error.value = 'Failed to reset usage data';
      _logger.error('Error resetting usage: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // App usage
  Future<void> getAppUsage({String? appName, String? period, int? limit}) async {
    try {
      final response = await _api.getAppUsage(
        appName: appName,
        period: period ?? _selectedPeriod.value,
        limit: limit ?? 20,
      );
      
      if (response.isSuccess && response.data != null) {
        // Handle app usage data
        _logger.info('App usage data loaded successfully');
      } else {
        _logger.error('Failed to load app usage: ${response.message}');
      }
    } catch (e) {
      _logger.error('Error loading app usage: $e');
    }
  }

  // Export
  Future<void> exportData({
    String format = 'json',
    String? period,
    bool includeRecords = false,
  }) async {
    try {
      final response = await _api.exportData(
        format: format,
        period: period ?? _selectedPeriod.value,
        includeRecords: includeRecords,
      );
      
      if (response.isSuccess && response.data != null) {
        // Handle export data
        _logger.info('Data exported successfully');
      } else {
        _logger.error('Failed to export data: ${response.message}');
      }
    } catch (e) {
      _logger.error('Error exporting data: $e');
    }
  }

  // Auto-disconnect check
  Future<bool> checkAutoDisconnect() async {
    try {
      final response = await _api.checkAutoDisconnect();
      
      if (response.isSuccess && response.data != null) {
        final shouldDisconnect = response.data!['should_disconnect'] as bool? ?? false;
        if (shouldDisconnect) {
          _logger.warning('Auto-disconnect triggered due to usage limits');
        }
        return shouldDisconnect;
      }
    } catch (e) {
      _logger.error('Error checking auto-disconnect: $e');
    }
    return false;
  }

  // Session management
  void startSession() {
    _currentSessionId = _generateSessionId();
    _sessionStartTime = DateTime.now();
    _logger.info('Started new usage session: $_currentSessionId');
  }

  void endSession() {
    _currentSessionId = null;
    _sessionStartTime = null;
    _logger.info('Ended usage session');
  }

  // Settings toggles
  Future<void> toggleEnabled() async {
    await updateSettings(enabled: !isEnabled);
  }

  Future<void> toggleAutoDisconnect() async {
    await updateSettings(autoDisconnect: !(monitor?.autoDisconnect ?? false));
  }

  Future<void> setAutoRefresh(bool enabled) async {
    _autoRefresh.value = enabled;
    await StorageHelper.setBool('data_usage_auto_refresh', enabled);
    
    if (enabled) {
      _startAutoRefresh();
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval.value = seconds;
    await StorageHelper.setInt('data_usage_refresh_interval', seconds);
    
    if (_autoRefresh.value) {
      _startAutoRefresh();
    }
  }

  void setPeriod(String period) {
    _selectedPeriod.value = period;
    loadStats(period: period);
  }

  void setTimelineDays(int days) {
    _timelineDays.value = days;
    loadStats(days: days);
  }

  // Data refresh
  Future<void> refreshData() async {
    await Future.wait([
      loadSettings(),
      loadStats(),
      loadAlerts(),
    ]);
  }

  // Helper methods
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveToStorage() async {
    try {
      if (_monitor.value != null) {
        await StorageHelper.setString('data_usage_monitor', _monitor.value!.toJson().toString());
      }
    } catch (e) {
      _logger.error('Failed to save to storage: $e');
    }
  }

  // UI helpers
  String formatUsageForDisplay(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  String getUsageColor(double percentage) {
    if (percentage >= 100) return 'red';
    if (percentage >= 80) return 'orange';
    if (percentage >= 60) return 'yellow';
    return 'green';
  }

  String getStatusIcon() {
    if (!isEnabled) return '⏸️';
    if (shouldAutoDisconnect) return '🚫';
    if (isNearLimit) return '⚠️';
    return '✅';
  }

  // Validation helpers
  bool isValidLimit(int? limitMb) {
    return limitMb == null || (limitMb > 0 && limitMb <= 1000000); // Max 1TB
  }

  bool isValidThreshold(int threshold) {
    return threshold >= 50 && threshold <= 95;
  }

  bool isValidResetDay(int day) {
    return day >= 1 && day <= 31;
  }

  // Notification helpers
  List<NotificationSetting> getDefaultNotifications() {
    return [
      NotificationSetting(type: 'warning', enabled: true, threshold: 80),
      NotificationSetting(type: 'limit_reached', enabled: true, threshold: 100),
      NotificationSetting(type: 'daily_summary', enabled: false),
    ];
  }

  // Error handling
  void clearError() {
    _error.value = '';
  }

  void clearStatsError() {
    _statsError.value = '';
  }

  // Debug helpers
  void logCurrentState() {
    _logger.debug('Current state:');
    _logger.debug('  Enabled: $isEnabled');
    _logger.debug('  Monitor: ${monitor?.id}');
    _logger.debug('  Alerts: ${alerts.length}');
    _logger.debug('  Auto-refresh: $autoRefresh');
    _logger.debug('  Session: $_currentSessionId');
  }
}