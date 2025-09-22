// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:dio/dio.dart';
import '../models/data_usage_model.dart';
import '../utils/logger.dart';
import '../utils/storage_helper.dart';

class DataUsageApi {
  static final DataUsageApi _instance = DataUsageApi._internal();
  factory DataUsageApi() => _instance;
  DataUsageApi._internal();

  late Dio _dio;
  final Logger _logger = Logger('DataUsageApi');

  void initialize(String baseUrl) {
    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageHelper.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _logger.error('API Error: ${error.message}');
        handler.next(error);
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _logger.debug(obj.toString()),
    ));
  }

  // Get data usage monitor settings
  Future<ApiResponse<DataUsageMonitor>> getSettings() async {
    try {
      _logger.info('Getting data usage settings');
      
      final response = await _dio.get('/data-usage/settings');
      
      if (response.statusCode == 200 && response.data['success']) {
        final monitor = DataUsageMonitor.fromJson(response.data['data']['monitor']);
        return ApiResponse.success(monitor, response.data['message']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get settings');
      }
    } on DioException catch (e) {
      _logger.error('Failed to get data usage settings: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error getting settings: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Update data usage monitor settings
  Future<ApiResponse<DataUsageMonitor>> updateSettings({
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
      _logger.info('Updating data usage settings');
      
      final data = <String, dynamic>{};
      if (enabled != null) data['enabled'] = enabled;
      if (dailyLimitMb != null) data['daily_limit_mb'] = dailyLimitMb;
      if (weeklyLimitMb != null) data['weekly_limit_mb'] = weeklyLimitMb;
      if (monthlyLimitMb != null) data['monthly_limit_mb'] = monthlyLimitMb;
      if (autoDisconnect != null) data['auto_disconnect'] = autoDisconnect;
      if (warningThreshold != null) data['warning_threshold'] = warningThreshold;
      if (resetDay != null) data['reset_day'] = resetDay;
      if (notifications != null) {
        data['notifications'] = notifications.map((n) => n.toJson()).toList();
      }
      if (excludedApps != null) data['excluded_apps'] = excludedApps;
      if (priorityApps != null) data['priority_apps'] = priorityApps;
      
      final response = await _dio.post('/data-usage/settings', data: data);
      
      if (response.statusCode == 200 && response.data['success']) {
        final monitor = DataUsageMonitor.fromJson(response.data['data']);
        return ApiResponse.success(monitor, response.data['message']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update settings');
      }
    } on DioException catch (e) {
      _logger.error('Failed to update data usage settings: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error updating settings: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Record data usage
  Future<ApiResponse<DataUsageRecord>> recordUsage({
    required String appName,
    required int downloadBytes,
    required int uploadBytes,
    String connectionType = 'vpn',
    String? serverLocation,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.debug('Recording data usage for $appName: ${_formatBytes(downloadBytes + uploadBytes)}');
      
      final data = {
        'app_name': appName,
        'download_bytes': downloadBytes,
        'upload_bytes': uploadBytes,
        'connection_type': connectionType,
        if (serverLocation != null) 'server_location': serverLocation,
        if (sessionId != null) 'session_id': sessionId,
        if (metadata != null) 'metadata': metadata,
      };
      
      final response = await _dio.post('/data-usage/record', data: data);
      
      if (response.statusCode == 200 && response.data['success']) {
        final record = DataUsageRecord.fromJson(response.data['data']['record']);
        return ApiResponse.success(record, response.data['message']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to record usage');
      }
    } on DioException catch (e) {
      _logger.error('Failed to record data usage: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error recording usage: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Get usage statistics
  Future<ApiResponse<UsageStats>> getStats({
    String period = 'daily',
    int days = 7,
  }) async {
    try {
      _logger.info('Getting usage statistics for period: $period');
      
      final response = await _dio.get('/data-usage/stats', queryParameters: {
        'period': period,
        'days': days,
      });
      
      if (response.statusCode == 200 && response.data['success']) {
        final stats = UsageStats.fromJson(response.data['data']);
        return ApiResponse.success(stats, 'Statistics retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get statistics');
      }
    } on DioException catch (e) {
      _logger.error('Failed to get usage stats: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error getting stats: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Reset usage data
  Future<ApiResponse<DataUsageMonitor>> resetUsage(String resetType) async {
    try {
      _logger.info('Resetting usage data: $resetType');
      
      final response = await _dio.post('/data-usage/reset', data: {
        'reset_type': resetType,
      });
      
      if (response.statusCode == 200 && response.data['success']) {
        final monitor = DataUsageMonitor.fromJson(response.data['data']);
        return ApiResponse.success(monitor, response.data['message']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to reset usage');
      }
    } on DioException catch (e) {
      _logger.error('Failed to reset usage: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error resetting usage: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Get usage alerts
  Future<ApiResponse<List<UsageAlert>>> getAlerts() async {
    try {
      _logger.info('Getting usage alerts');
      
      final response = await _dio.get('/data-usage/alerts');
      
      if (response.statusCode == 200 && response.data['success']) {
        final alertsData = response.data['data']['alerts'] as List;
        final alerts = alertsData.map((alert) => UsageAlert.fromJson(alert)).toList();
        return ApiResponse.success(alerts, 'Alerts retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get alerts');
      }
    } on DioException catch (e) {
      _logger.error('Failed to get alerts: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error getting alerts: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Check auto-disconnect status
  Future<ApiResponse<Map<String, dynamic>>> checkAutoDisconnect() async {
    try {
      _logger.debug('Checking auto-disconnect status');
      
      final response = await _dio.get('/data-usage/auto-disconnect');
      
      if (response.statusCode == 200 && response.data['success']) {
        return ApiResponse.success(response.data['data'], 'Status checked successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to check status');
      }
    } on DioException catch (e) {
      _logger.error('Failed to check auto-disconnect: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error checking auto-disconnect: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Get app usage details
  Future<ApiResponse<dynamic>> getAppUsage({
    String? appName,
    String period = 'daily',
    int limit = 20,
  }) async {
    try {
      _logger.info('Getting app usage data');
      
      final queryParams = {
        'period': period,
        'limit': limit,
      };
      if (appName != null) queryParams['app_name'] = appName;
      
      final response = await _dio.get('/data-usage/apps', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data['success']) {
        return ApiResponse.success(response.data['data'], 'App usage retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get app usage');
      }
    } on DioException catch (e) {
      _logger.error('Failed to get app usage: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error getting app usage: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Export usage data
  Future<ApiResponse<Map<String, dynamic>>> exportData({
    String format = 'json',
    String period = 'monthly',
    bool includeRecords = false,
  }) async {
    try {
      _logger.info('Exporting usage data');
      
      final response = await _dio.get('/data-usage/export', queryParameters: {
        'format': format,
        'period': period,
        'include_records': includeRecords,
      });
      
      if (response.statusCode == 200 && response.data['success']) {
        return ApiResponse.success(response.data['data'], 'Data exported successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to export data');
      }
    } on DioException catch (e) {
      _logger.error('Failed to export data: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error exporting data: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Get real-time usage
  Future<ApiResponse<RealTimeUsageData>> getRealTimeUsage() async {
    try {
      _logger.debug('Getting real-time usage data');
      
      final response = await _dio.get('/data-usage/realtime');
      
      if (response.statusCode == 200 && response.data['success']) {
        final realTimeData = RealTimeUsageData.fromJson(response.data['data']);
        return ApiResponse.success(realTimeData, 'Real-time data retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get real-time data');
      }
    } on DioException catch (e) {
      _logger.error('Failed to get real-time usage: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      _logger.error('Unexpected error getting real-time usage: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  // Helper methods
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Authentication failed. Please log in again.';
        } else if (e.response?.statusCode == 403) {
          return 'Access denied. You do not have permission to perform this action.';
        } else if (e.response?.statusCode == 422) {
          return 'Invalid data provided. Please check your input.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return e.response?.data?['message'] ?? 'Request failed';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Validation helpers
  bool _isValidPeriod(String period) {
    return ['hourly', 'daily', 'weekly', 'monthly', 'yearly'].contains(period);
  }

  bool _isValidResetType(String resetType) {
    return ['daily', 'weekly', 'monthly', 'all'].contains(resetType);
  }

  bool _isValidFormat(String format) {
    return ['json', 'csv'].contains(format);
  }

  // Data processing helpers
  Map<String, dynamic> _processUsageData(Map<String, dynamic> data) {
    // Add any client-side processing if needed
    return data;
  }

  List<Map> _processTimelineData(List<dynamic> timeline) {
    return timeline.map((item) => {
      ...item,
      'formatted_datetime': _formatDateTime(DateTime.parse(item['datetime'])),
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Cache management
  static const String _cacheKeyPrefix = 'data_usage_';
  
  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    try {
      await StorageHelper.setString('${_cacheKeyPrefix}$key', data.toString());
    } catch (e) {
      _logger.warning('Failed to cache data: $e');
    }
  }

  Future<Map<String, dynamic>?> _getCachedData(String key) async {
    try {
      final cached = await StorageHelper.getString('${_cacheKeyPrefix}$key');
      if (cached != null) {
        // Parse cached data if needed
        return {}; // Implement proper parsing
      }
    } catch (e) {
      _logger.warning('Failed to get cached data: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      // Clear all cached data usage data
      _logger.info('Clearing data usage cache');
      // Implement cache clearing logic
    } catch (e) {
      _logger.error('Failed to clear cache: $e');
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? errors;

  ApiResponse.success(this.data, this.message)
      : success = true,
        errors = null;

  ApiResponse.error(this.message, [this.errors])
      : success = false,
        data = null;

  bool get isSuccess => success;
  bool get isError => !success;
}