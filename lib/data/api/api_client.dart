// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../model/error_response.dart';
import '../../utils/my_helper.dart';

class ApiClient {
  final String appBaseUrl;
  final GetStorage sharedPreferences;
  static const String noInternetMessage = 'connection_to_api_server_failed';
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.read(MyHelper.bToken);
    if (kDebugMode) {
      debugPrint('Token: $token');
    }
    updateHeader();
  }

  /// Getter for base URL to maintain compatibility
  String get baseUrl => appBaseUrl;

  void updateHeader({bool? multipart, bool? isUddokta, bool isToken = false}) {
    if (isToken) {
      token = sharedPreferences.read(MyHelper.bToken);
    }

    if (multipart ?? false) {
      _mainHeaders = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
    } else if (isUddokta ?? false) {
      _mainHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Rt-Uddoktapay-Api-Key': '982d381360a69d419689740d9f2e26ce36fb7a50'
      };
    } else {
      _mainHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
    }
  }

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    return await _makeRequestWithFallback(
      () async {
        if (kDebugMode) {
          debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
        }
        return await http
            .get(
              Uri.parse(MyHelper.baseUrl + uri),
              headers: headers ?? _mainHeaders,
            )
            .timeout(Duration(seconds: timeoutInSeconds));
      },
      uri,
    );
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool? isRaw, bool? isLogin}) async {
    // updateHeader(isToken: true);
    return await _makeRequestWithFallback(
      () async {
        if (kDebugMode) {
          debugPrint('====> API Call: ${MyHelper.baseUrl}$uri\nHeader: $_mainHeaders');
          debugPrint('====> API Body: $body');
        }
        return await http
            .post(
              Uri.parse(MyHelper.baseUrl + uri),
              body: isRaw ?? false ? body : jsonEncode(body),
              headers: headers ?? _mainHeaders,
            )
            .timeout(Duration(seconds: timeoutInSeconds));
      },
      uri,
      isLogin: isLogin ?? false,
    );
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    return await _makeRequestWithFallback(
      () async {
        if (kDebugMode) {
          debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
          debugPrint('====> API Body: $body');
        }
        return await http
            .put(
              Uri.parse(MyHelper.baseUrl + uri),
              body: jsonEncode(body),
              headers: headers ?? _mainHeaders,
            )
            .timeout(Duration(seconds: timeoutInSeconds));
      },
      uri,
    );
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers}) async {
    return await _makeRequestWithFallback(
      () async {
        if (kDebugMode) {
          debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
        }
        return await http
            .delete(
              Uri.parse(MyHelper.baseUrl + uri),
              headers: headers ?? _mainHeaders,
            )
            .timeout(Duration(seconds: timeoutInSeconds));
      },
      uri,
    );
  }

  /// Helper method to make requests with automatic fallback
  Future<Response> _makeRequestWithFallback(
    Future<http.Response> Function() requestFunction,
    String uri, {
    bool isLogin = false,
  }) async {
    try {
      // First attempt with current URL
      http.Response response = await requestFunction();
      return handleResponse(response, uri, isLogin: isLogin);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Request failed with current URL, attempting fallback: $e');
      }
      
      // Try to switch to fallback if needed
      bool fallbackAvailable = await MyHelper.switchToFallbackIfNeeded();
      
      if (fallbackAvailable && MyHelper.isUsingFallback) {
        try {
          // Retry with fallback URL
          http.Response response = await requestFunction();
          return handleResponse(response, uri, isLogin: isLogin);
        } catch (fallbackError) {
          if (kDebugMode) {
            debugPrint('Fallback request also failed: $fallbackError');
          }
          return Response(noInternetMessage, 0);
        }
      }
      
      return Response(noInternetMessage, 0);
    }
  }

  Response handleResponse(http.Response response, String uri, {bool? isLogin}) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      jsonEncode(body ?? response.body),
      response.statusCode,
    );

    if (response0.statusCode != 200 && response0.body != null) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse =
            ErrorResponse.fromJson(json.decode(response0.body));
        response0 =
            Response(errorResponse.errors!.email![0], response0.statusCode);
      } else if (response0.statusCode == 401) {
        response0 = Response(body["message"], response0.statusCode);
        if (isLogin ?? false) {
          return response0;
        }
        sharedPreferences.write(MyHelper.bToken, "");
      } else {
        response0 = Response(body["message"], response0.statusCode);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(
        noInternetMessage,
        0,
      );
    }
    if (kDebugMode) {
      debugPrint(
          '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    }
    return response0;
  }
}
