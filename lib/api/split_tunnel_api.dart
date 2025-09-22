import 'package:dio/dio.dart';
import '../model/split_tunnel_model.dart';
import '../controller/pref.dart';

class SplitTunnelApi {
  static const String baseUrl = 'https://eclipse.anfaan.com/public/api';
  static final Dio _dio = Dio();

  static Future<String?> _getAuthToken() async {
    return await Pref.getToken();
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get split tunnel settings
  static Future<SplitTunnelResponse> getSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/split-tunnel/settings',
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to get split tunnel settings',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update split tunnel settings
  static Future<SplitTunnelResponse> updateSettings(SplitTunnelSettings settings) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/settings',
        data: settings.toJson(),
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to update split tunnel settings',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Toggle split tunneling on/off
  static Future<SplitTunnelResponse> toggle() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/toggle',
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to toggle split tunneling',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Add app to split tunnel list
  static Future<SplitTunnelResponse> addApp(String appIdentifier) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/apps/add',
        data: {'app_identifier': appIdentifier},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to add app',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Remove app from split tunnel list
  static Future<SplitTunnelResponse> removeApp(String appIdentifier) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/apps/remove',
        data: {'app_identifier': appIdentifier},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to remove app',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Add domain to split tunnel list
  static Future<SplitTunnelResponse> addDomain(String domain) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/domains/add',
        data: {'domain': domain},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to add domain',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Remove domain from split tunnel list
  static Future<SplitTunnelResponse> removeDomain(String domain) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/domains/remove',
        data: {'domain': domain},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to remove domain',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Add IP range to split tunnel list
  static Future<SplitTunnelResponse> addIpRange(String ipRange) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/ip-ranges/add',
        data: {'ip_range': ipRange},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to add IP range',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Remove IP range from split tunnel list
  static Future<SplitTunnelResponse> removeIpRange(String ipRange) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/split-tunnel/ip-ranges/remove',
        data: {'ip_range': ipRange},
        options: Options(headers: headers),
      );

      return SplitTunnelResponse.fromJson(response.data);
    } on DioException catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to remove IP range',
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return SplitTunnelResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get installed apps for split tunneling
  static Future<InstalledAppsResponse> getInstalledApps() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/split-tunnel/installed-apps',
        options: Options(headers: headers),
      );

      return InstalledAppsResponse.fromJson(response.data);
    } on DioException catch (e) {
      return InstalledAppsResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to get installed apps',
        data: [],
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return InstalledAppsResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
        data: [],
      );
    }
  }
}