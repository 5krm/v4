// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart';
import '../model/analytics_model.dart';
import '../data/api/api_client.dart';

class APIs {
  static Future<String> getPublicIpAddress() async {
    try {
      final response = await get(Uri.parse('http://ip-api.com/json/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String ipAddress = data['query'] ?? '';
        return ipAddress;
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  // Analytics API methods
  static Future<AnalyticsDashboard?> getDashboardData({
    required String token,
    required String baseUrl,
    String timeframe = 'month',
  }) async {
    try {
      final response = await get(
        Uri.parse('$baseUrl/api/analytics/dashboard?timeframe=$timeframe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return AnalyticsDashboard.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }

  static Future<List<UserAnalytics>> getAnalyticsHistory({
    required String token,
    required String baseUrl,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await get(
        Uri.parse(
            '$baseUrl/api/analytics/history?page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => UserAnalytics.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching analytics history: $e');
      return [];
    }
  }

  static Future<StatsSummary?> getStatsSummary({
    required String token,
    required String baseUrl,
  }) async {
    try {
      final response = await get(
        Uri.parse('$baseUrl/api/analytics/stats-summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return StatsSummary.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching stats summary: $e');
      return null;
    }
  }

  static Future<bool> recordSession({
    required String token,
    required String baseUrl,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      final response = await post(
        Uri.parse('$baseUrl/api/analytics/record-session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sessionData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error recording session: $e');
      return false;
    }
  }

  static Future<bool> updateSession({
    required String token,
    required String baseUrl,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      final response = await post(
        Uri.parse('$baseUrl/api/analytics/update-session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sessionData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating session: $e');
      return false;
    }
  }
}
