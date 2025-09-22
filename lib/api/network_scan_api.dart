import 'package:dio/dio.dart';
import '../model/network_scan_model.dart';
import '../utils/shared_preference.dart';

class NetworkScanApi {
  static const String baseUrl = 'https://eclipse.anfaan.com/public/api';
  static final Dio _dio = Dio();

  static Future<Map<String, String>> _getHeaders() async {
    final token = SharedPreference.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get current scan status and latest results
  static Future<NetworkScanResponse> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/network-scan/status',
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get scan status: $e');
    }
  }

  /// Start a new network security scan
  static Future<NetworkScanResponse> startScan(NetworkScanSettings settings) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/network-scan/start',
        data: settings.toJson(),
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to start scan: $e');
    }
  }

  /// Stop an ongoing network scan
  static Future<NetworkScanResponse> stopScan(int scanId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$baseUrl/network-scan/stop',
        data: {'scan_id': scanId},
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to stop scan: $e');
    }
  }

  /// Get scan history for the authenticated user
  static Future<NetworkScanResponse> getHistory({int limit = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/network-scan/history',
        queryParameters: {'limit': limit},
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get scan history: $e');
    }
  }

  /// Get detailed scan results
  static Future<NetworkScanResponse> getScanDetails(int scanId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/network-scan/details/$scanId',
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get scan details: $e');
    }
  }

  /// Delete a scan record
  static Future<NetworkScanResponse> deleteScan(int scanId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '$baseUrl/network-scan/delete/$scanId',
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to delete scan: $e');
    }
  }

  /// Get network information for scanning
  static Future<NetworkScanResponse> getNetworkInfo() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$baseUrl/network-scan/network-info',
        options: Options(headers: headers),
      );

      return NetworkScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get network info: $e');
    }
  }

  /// Handle Dio errors and convert them to meaningful messages
  static Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error occurred';
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Access forbidden: $message');
          case 404:
            return Exception('Resource not found: $message');
          case 409:
            return Exception('Conflict: $message');
          case 422:
            final errors = e.response?.data?['errors'];
            if (errors != null) {
              final errorMessages = <String>[];
              if (errors is Map) {
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
              }
              return Exception('Validation error: ${errorMessages.join(', ')}');
            }
            return Exception('Validation error: $message');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('HTTP $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error. Please check your connection security.');
      case DioExceptionType.unknown:
        return Exception('Network error: ${e.message}');
    }
  }

  /// Configure Dio with interceptors for logging and error handling
  static void configureDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // Only log in debug mode
          // print(object);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Retry logic for specific error types
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            
            // Retry once for timeout errors
            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
          
          handler.next(error);
        },
      ),
    );
  }
}