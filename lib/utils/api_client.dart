import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'my_helper.dart';

class ApiClient {
  static final Dio _dio = Dio();
  static final Map<String, dynamic> _memoryCache = {};
  static final GetStorage _storage = GetStorage();
  static String get baseUrl => MyHelper.baseUrl;
  
  static void initialize() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15); // Reduced timeout
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);
    
    // Connection pool configuration
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.maxConnectionsPerHost = 5;
      client.connectionTimeout = const Duration(seconds: 10);
      client.idleTimeout = const Duration(seconds: 30);
      return client;
    };
    
    // Add cache interceptor
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorCodes: [401, 403],
      maxStale: const Duration(minutes: 5),
      priority: CachePriority.normal,
      cipher: null,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );
    
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _storage.read('bearer_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        
        if (kDebugMode) {
          debugPrint('API ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('API ${response.requestOptions.method} ${response.requestOptions.uri} responded with ${response.statusCode}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('API Error: ${error.message}');
        }
        
        // Auto-retry with fallback URL on connection errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          
          bool switched = await MyHelper.switchToFallbackIfNeeded();
          if (switched && MyHelper.isUsingFallback) {
            // Update base URL and retry
            _dio.options.baseUrl = MyHelper.baseUrl;
            try {
              final retryResponse = await _dio.fetch(error.requestOptions);
              handler.resolve(retryResponse);
              return;
            } catch (retryError) {
              // If retry also fails, continue with original error
            }
          }
        }
        
        handler.next(error);
      },
    ));
  }
  
  // Memory cache for frequently accessed data
  static T? getCachedData<T>(String key) {
    return _memoryCache[key] as T?;
  }
  
  static void setCachedData<T>(String key, T data, {Duration? ttl}) {
    _memoryCache[key] = data;
    if (ttl != null) {
      Future.delayed(ttl, () => _memoryCache.remove(key));
    }
  }
  
  static void clearCache() {
    _memoryCache.clear();
  }
  
  static Future<Response> get(String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool useCache = true,
    Duration? cacheDuration,
  }) async {
    try {
      final options = Options();
      if (useCache && cacheDuration != null) {
        options.extra = {
          'dio_cache_refresh': false,
          'dio_cache_max_stale': cacheDuration,
        };
      }
      
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GET $endpoint failed: $e');
      }
      rethrow;
    }
  }
  
  static Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('POST $endpoint failed: $e');
      }
      rethrow;
    }
  }
  
  static Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PUT $endpoint failed: $e');
      }
      rethrow;
    }
  }
  
  static Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DELETE $endpoint failed: $e');
      }
      rethrow;
    }
  }
  
  static Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      return await _dio.patch(endpoint, data: data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PATCH $endpoint failed: $e');
      }
      rethrow;
    }
  }
  
  // Batch requests for better performance
  static Future<List<Response>> batchRequests(List<RequestOptions> requests) async {
    try {
      final futures = requests.map((request) => _dio.fetch(request)).toList();
      return await Future.wait(futures);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Batch requests failed: $e');
      }
      rethrow;
    }
  }
  
  // Cancel all pending requests
  static void cancelRequests() {
    _dio.close(force: true);
  }
}