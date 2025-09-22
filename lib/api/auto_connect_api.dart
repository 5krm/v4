import 'package:dbug_vpn/utils/my_helper.dart';
import 'package:dio/dio.dart';
import '../model/auto_connect_model.dart';
import '../utils/storage_helper.dart';
import '../utils/logger.dart';

class AutoConnectApi {
  static String get baseUrl => MyHelper.baseUrl;
  late final Dio _dio;
  final Logger _logger = Logger('AutoConnectApi');

  AutoConnectApi() {
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
        _logger.info('Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.error('API Error: ${error.message}', error);
        handler.next(error);
      },
    ));
  }

  // Get auto-connect settings
  Future<AutoConnectResponse> getSettings() async {
    try {
      final response = await _dio.get('/auto-connect/settings');
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to get auto-connect settings', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error getting auto-connect settings', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Update auto-connect settings
  Future<AutoConnectResponse> updateSettings(AutoConnectSettings settings) async {
    try {
      final response = await _dio.put(
        '/auto-connect/settings',
        data: settings.toJson(),
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to update auto-connect settings', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error updating auto-connect settings', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Toggle auto-connect feature
  Future<AutoConnectResponse> toggleAutoConnect(bool enabled) async {
    try {
      final response = await _dio.post(
        '/auto-connect/toggle',
        data: {'enabled': enabled},
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to toggle auto-connect', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error toggling auto-connect', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Add trusted network
  Future<AutoConnectResponse> addTrustedNetwork({
    required String ssid,
    required String bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/auto-connect/trusted-networks',
        data: {
          'ssid': ssid,
          'bssid': bssid,
          'security_type': securityType,
          'signal_strength': signalStrength,
          'frequency': frequency,
          'description': description,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to add trusted network', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error adding trusted network', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Remove trusted network
  Future<AutoConnectResponse> removeTrustedNetwork(String ssid, String bssid) async {
    try {
      final response = await _dio.delete(
        '/auto-connect/trusted-networks',
        data: {
          'ssid': ssid,
          'bssid': bssid,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to remove trusted network', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error removing trusted network', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Add untrusted network
  Future<AutoConnectResponse> addUntrustedNetwork({
    required String ssid,
    required String bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/auto-connect/untrusted-networks',
        data: {
          'ssid': ssid,
          'bssid': bssid,
          'security_type': securityType,
          'signal_strength': signalStrength,
          'frequency': frequency,
          'reason': reason,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to add untrusted network', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error adding untrusted network', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Remove untrusted network
  Future<AutoConnectResponse> removeUntrustedNetwork(String ssid, String bssid) async {
    try {
      final response = await _dio.delete(
        '/auto-connect/untrusted-networks',
        data: {
          'ssid': ssid,
          'bssid': bssid,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to remove untrusted network', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error removing untrusted network', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Check network recommendations
  Future<AutoConnectResponse> checkNetwork({
    required String ssid,
    required String bssid,
    String? securityType,
    int? signalStrength,
    int? frequency,
  }) async {
    try {
      final response = await _dio.post(
        '/auto-connect/check-network',
        data: {
          'ssid': ssid,
          'bssid': bssid,
          'security_type': securityType,
          'signal_strength': signalStrength,
          'frequency': frequency,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to check network', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error checking network', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Get available networks
  Future<AutoConnectResponse> getAvailableNetworks() async {
    try {
      final response = await _dio.get('/auto-connect/available-networks');
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to get available networks', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error getting available networks', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Record auto-connect action
  Future<AutoConnectResponse> recordAction({
    required String action,
    required String networkSsid,
    String? networkBssid,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/auto-connect/record-action',
        data: {
          'action': action,
          'network_ssid': networkSsid,
          'network_bssid': networkBssid,
          'metadata': metadata,
        },
      );
      return AutoConnectResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('Failed to record action', e);
      return AutoConnectResponse(
        success: false,
        message: _getErrorMessage(e),
        error: e.message,
      );
    } catch (e) {
      _logger.error('Unexpected error recording action', e);
      return AutoConnectResponse(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
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

  // Get available servers
  Future<ServersResponse> getAvailableServers() async {
    try {
      final response = await _dio.get('/servers');
      return ServersResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ServersResponse(
        success: false,
        message: _getErrorMessage(e),
        servers: [],
      );
    } catch (e) {
      return ServersResponse(
        success: false,
        message: 'Failed to get available servers: $e',
        servers: [],
      );
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _dio.close();
  }
}