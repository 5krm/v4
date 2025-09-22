import 'package:dio/dio.dart';
import '../models/vpn_protocol_model.dart';
import '../utils/storage_helper.dart';

class VpnProtocolApi {
  static final VpnProtocolApi _instance = VpnProtocolApi._internal();
  factory VpnProtocolApi() => _instance;
  VpnProtocolApi._internal();

  late Dio _dio;
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
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
        final token = await StorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[VPN Protocol API] $obj'),
    ));
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('VPN Protocol API Timeout: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        print('VPN Protocol API Error ${error.response?.statusCode}: ${error.response?.data}');
        break;
      case DioExceptionType.cancel:
        print('VPN Protocol API Request cancelled');
        break;
      case DioExceptionType.unknown:
        print('VPN Protocol API Unknown error: ${error.message}');
        break;
      default:
        print('VPN Protocol API Error: ${error.message}');
    }
  }

  // Get VPN protocol settings
  Future<VpnProtocolResponse> getSettings() async {
    try {
      final response = await _dio.get('/vpn-protocol/settings');
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to get protocol settings: $e',
      );
    }
  }

  // Update VPN protocol settings
  Future<VpnProtocolResponse> updateSettings({
    required String selectedProtocol,
    bool? autoSelectionEnabled,
    bool? optimizationEnabled,
    Map<String, int>? protocolPreferences,
    Map<String, dynamic>? connectionSettings,
    List<String>? fallbackProtocols,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      final data = <String, dynamic>{
        'selected_protocol': selectedProtocol,
      };

      if (autoSelectionEnabled != null) {
        data['auto_selection_enabled'] = autoSelectionEnabled;
      }
      if (optimizationEnabled != null) {
        data['optimization_enabled'] = optimizationEnabled;
      }
      if (protocolPreferences != null) {
        data['protocol_preferences'] = protocolPreferences;
      }
      if (connectionSettings != null) {
        data['connection_settings'] = connectionSettings;
      }
      if (fallbackProtocols != null) {
        data['fallback_protocols'] = fallbackProtocols;
      }
      if (customSettings != null) {
        data['custom_settings'] = customSettings;
      }

      final response = await _dio.post('/vpn-protocol/settings', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to update protocol settings: $e',
      );
    }
  }

  // Switch to a specific protocol
  Future<VpnProtocolResponse> switchProtocol({
    required String protocol,
    String? reason,
    ProtocolContext? context,
  }) async {
    try {
      final data = <String, dynamic>{
        'protocol': protocol,
      };

      if (reason != null) {
        data['reason'] = reason;
      }
      if (context != null) {
        data['context'] = context.toJson();
      }

      final response = await _dio.post('/vpn-protocol/switch', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to switch protocol: $e',
      );
    }
  }

  // Get protocol recommendations
  Future<VpnProtocolResponse> getRecommendations({
    ProtocolContext? context,
  }) async {
    try {
      final data = context?.toJson() ?? {};
      final response = await _dio.post('/vpn-protocol/recommendations', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to get recommendations: $e',
      );
    }
  }

  // Get available protocols
  Future<VpnProtocolResponse> getAvailableProtocols({
    String platform = 'android',
  }) async {
    try {
      final response = await _dio.get(
        '/vpn-protocol/available',
        queryParameters: {'platform': platform},
      );
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to get available protocols: $e',
      );
    }
  }

  // Update performance metrics
  Future<VpnProtocolResponse> updatePerformanceMetrics({
    required String protocol,
    required Map<String, dynamic> metrics,
  }) async {
    try {
      final data = {
        'protocol': protocol,
        'metrics': metrics,
      };

      final response = await _dio.post('/vpn-protocol/metrics', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to update performance metrics: $e',
      );
    }
  }

  // Get protocol statistics
  Future<VpnProtocolResponse> getProtocolStats() async {
    try {
      final response = await _dio.get('/vpn-protocol/stats');
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to get protocol statistics: $e',
      );
    }
  }

  // Reset protocol statistics
  Future<VpnProtocolResponse> resetStats() async {
    try {
      final response = await _dio.post('/vpn-protocol/reset-stats');
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to reset statistics: $e',
      );
    }
  }

  // Test protocol connectivity
  Future<VpnProtocolResponse> testProtocol({
    required String protocol,
    String? serverId,
    int timeout = 30,
  }) async {
    try {
      final data = <String, dynamic>{
        'protocol': protocol,
        'timeout': timeout,
      };

      if (serverId != null) {
        data['server_id'] = serverId;
      }

      final response = await _dio.post('/vpn-protocol/test', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to test protocol: $e',
      );
    }
  }

  // Compare protocols
  Future<VpnProtocolResponse> compareProtocols({
    required List<String> protocols,
    List<String>? criteria,
  }) async {
    try {
      final data = <String, dynamic>{
        'protocols': protocols,
      };

      if (criteria != null && criteria.isNotEmpty) {
        data['criteria'] = criteria;
      }

      final response = await _dio.post('/vpn-protocol/compare', data: data);
      return VpnProtocolResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: _getErrorMessage(e),
        errors: _getValidationErrors(e),
      );
    } catch (e) {
      return VpnProtocolResponse(
        success: false,
        message: 'Failed to compare protocols: $e',
      );
    }
  }

  // Helper method to get error message from DioException
  String _getErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error (${error.response?.statusCode}). Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  // Helper method to get validation errors from DioException
  Map<String, dynamic>? _getValidationErrors(DioException error) {
    if (error.response?.statusCode == 422 && error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('errors')) {
        return data['errors'];
      }
    }
    return null;
  }

  // Helper method to get current device context
  static ProtocolContext getCurrentContext({
    String? customUseCase,
    String? customNetworkType,
    int? batteryLevel,
  }) {
    return ProtocolContext(
      deviceType: 'mobile', // Default for Flutter app
      networkType: customNetworkType ?? 'wifi',
      useCase: customUseCase ?? 'general',
      batteryLevel: batteryLevel,
      networkStability: 'stable',
      platform: 'android', // Can be determined dynamically
    );
  }

  // Helper method to get protocol display name
  static String getProtocolDisplayName(String protocol) {
    switch (protocol) {
      case 'auto':
        return 'Auto';
      case 'openvpn_udp':
        return 'OpenVPN UDP';
      case 'openvpn_tcp':
        return 'OpenVPN TCP';
      case 'ikev2':
        return 'IKEv2/IPSec';
      case 'wireguard':
        return 'WireGuard';
      case 'l2tp':
        return 'L2TP/IPSec';
      default:
        return protocol.toUpperCase();
    }
  }

  // Helper method to get protocol icon
  static String getProtocolIcon(String protocol) {
    switch (protocol) {
      case 'auto':
        return '🤖';
      case 'openvpn_udp':
        return '🚀';
      case 'openvpn_tcp':
        return '🔒';
      case 'ikev2':
        return '📱';
      case 'wireguard':
        return '⚡';
      case 'l2tp':
        return '🔧';
      default:
        return '🔐';
    }
  }

  // Helper method to get protocol color
  static String getProtocolColor(String protocol) {
    switch (protocol) {
      case 'auto':
        return '#6366F1'; // Indigo
      case 'openvpn_udp':
        return '#10B981'; // Emerald
      case 'openvpn_tcp':
        return '#3B82F6'; // Blue
      case 'ikev2':
        return '#8B5CF6'; // Violet
      case 'wireguard':
        return '#F59E0B'; // Amber
      case 'l2tp':
        return '#6B7280'; // Gray
      default:
        return '#374151'; // Gray
    }
  }

  // Helper method to format speed
  static String formatSpeed(double speed) {
    if (speed >= 1000) {
      return '${(speed / 1000).toStringAsFixed(1)} Gbps';
    }
    return '${speed.toStringAsFixed(1)} Mbps';
  }

  // Helper method to format duration
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  // Helper method to format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  // Helper method to get recommendation level color
  static String getRecommendationColor(int score) {
    if (score >= 80) return '#10B981'; // Green
    if (score >= 60) return '#F59E0B'; // Amber
    if (score >= 40) return '#EF4444'; // Red
    return '#6B7280'; // Gray
  }

  // Helper method to get recommendation level text
  static String getRecommendationLevel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Not Recommended';
  }

  // Helper method to validate protocol
  static bool isValidProtocol(String protocol) {
    const validProtocols = [
      'auto',
      'openvpn_udp',
      'openvpn_tcp',
      'ikev2',
      'wireguard',
      'l2tp',
    ];
    return validProtocols.contains(protocol);
  }

  // Helper method to get default fallback protocols
  static List<String> getDefaultFallbackProtocols() {
    return ['openvpn_udp', 'openvpn_tcp', 'ikev2'];
  }

  // Helper method to get protocol priority order
  static List<String> getProtocolPriorityOrder() {
    return ['wireguard', 'ikev2', 'openvpn_udp', 'openvpn_tcp', 'l2tp'];
  }

  // Helper method to get use case options
  static List<String> getUseCaseOptions() {
    return ['general', 'streaming', 'gaming', 'security', 'torrenting'];
  }

  // Helper method to get network type options
  static List<String> getNetworkTypeOptions() {
    return ['wifi', 'cellular', 'ethernet', 'restricted'];
  }

  // Helper method to get device type options
  static List<String> getDeviceTypeOptions() {
    return ['mobile', 'desktop', 'tablet'];
  }

  // Helper method to get platform options
  static List<String> getPlatformOptions() {
    return ['android', 'ios', 'windows', 'macos', 'linux'];
  }
}