import 'package:dbug_vpn/utils/my_helper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../utils/storage_helper.dart';
import '../utils/logger.dart';

class ApiService extends GetxService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late dio.Dio _dio;
  final Logger _logger = Logger('ApiService');
  static String get baseUrl => MyHelper.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(dio.BaseOptions(
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
        final token = await StorageHelper.getAuthToken();
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

  // Static methods for easy access
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _instance._dio.get(endpoint);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _instance._dio.post(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _instance._dio.put(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _instance._dio.delete(endpoint);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': response.data,
        'message': 'Request successful'
      };
    } else {
      return {
        'success': false,
        'data': null,
        'message': 'Request failed with status: ${response.statusCode}'
      };
    }
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    String message = 'Unknown error occurred';
    
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.sendTimeout:
          message = 'Connection timeout';
          break;
        case dio.DioExceptionType.badResponse:
          message = 'Server error: ${error.response?.statusCode}';
          break;
        case dio.DioExceptionType.cancel:
          message = 'Request cancelled';
          break;
        case dio.DioExceptionType.connectionError:
          message = 'Connection error';
          break;
        default:
          message = error.message ?? 'Network error';
      }
    }
    
    return {
      'success': false,
      'data': null,
      'message': message
    };
  }
}