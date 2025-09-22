import 'package:dbug_vpn/utils/my_helper.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../model/kill_switch_model.dart';
import '../utils/storage_helper.dart';
import '../utils/logger.dart';

class KillSwitchApi {
  static String get baseUrl => MyHelper.baseUrl;
  late final Dio _dio;
  final Logger _logger = Logger('KillSwitchApi');

  KillSwitchApi() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token
        final token = await StorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        _logger.info('${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.info(
            'Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.error('API Error: ${error.message}', error);
        handler.next(error);
      },
    ));
  }

  // Get Kill Switch settings
  Future<KillSwitchResponse> getSettings() async {
    try {
      final response = await _dio.get('/kill-switch/settings');
      return KillSwitchResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to get kill switch settings', e);
      return KillSwitchResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error getting kill switch settings', e);
      return KillSwitchResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Update Kill Switch settings
  Future<KillSwitchResponse> updateSettings(KillSwitchSettings settings) async {
    try {
      final response = await _dio.put(
        '/kill-switch/settings',
        data: settings.toJson(),
      );
      return KillSwitchResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to update kill switch settings', e);
      return KillSwitchResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error updating kill switch settings', e);
      return KillSwitchResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Toggle Kill Switch
  Future<KillSwitchResponse> toggle() async {
    try {
      final response = await _dio.post('/kill-switch/toggle');
      return KillSwitchResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to toggle kill switch', e);
      return KillSwitchResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error toggling kill switch', e);
      return KillSwitchResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Get Kill Switch status
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await _dio.get('/kill-switch/status');
      return response.data;
    } on DioException catch (e) {
      _logger.error('Failed to get kill switch status', e);
      return {
        'success': false,
        'message': _getErrorMessage(e),
        'error': e.message,
      };
    } catch (e) {
      _logger.error('Unexpected error getting kill switch status', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Record Kill Switch activation
  Future<Map<String, dynamic>> recordActivation() async {
    try {
      final response = await _dio.post('/kill-switch/activation');
      return response.data;
    } on DioException catch (e) {
      _logger.error('Failed to record kill switch activation', e);
      return {
        'success': false,
        'message': _getErrorMessage(e),
        'error': e.message,
      };
    } catch (e) {
      _logger.error('Unexpected error recording kill switch activation', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Helper method to extract error messages
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'];

        if (statusCode == 401) {
          return 'Authentication failed. Please log in again.';
        } else if (statusCode == 403) {
          return 'Access denied. You don\'t have permission to perform this action.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 422) {
          return message ?? 'Invalid data provided.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }

        return message ?? 'An error occurred. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _dio.close();
  }
}
