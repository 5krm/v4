// ignore_for_file: unused_field, avoid_print

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpeedTestService {
  static const String _testUrl = 'https://httpbin.org/bytes/';
  static const int _testDurationSeconds = 10;
  static const int _warmupBytes = 1024 * 100; // 100KB for warmup
  static const int _downloadTestBytes = 1024 * 1024 * 10; // 10MB
  static const int _uploadTestBytes = 1024 * 1024 * 5; // 5MB

  // Download speed test
  static Future<double> testDownloadSpeed() async {
    try {
      // Warmup
      await http.get(Uri.parse('$_testUrl$_warmupBytes'));

      final stopwatch = Stopwatch()..start();
      final response =
          await http.get(Uri.parse('$_testUrl$_downloadTestBytes'));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000.0;
        final mbps = (bytes * 8) / (seconds * 1000000); // Convert to Mbps
        return mbps;
      }
    } catch (e) {
      print('Download test error: $e');
    }
    return 0.0;
  }

  // Upload speed test
  static Future<double> testUploadSpeed() async {
    try {
      // Generate random data for upload
      final random = Random();
      final data = List.generate(_uploadTestBytes, (_) => random.nextInt(256));

      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse('https://httpbin.org/post'),
        body: data,
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = data.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000.0;
        final mbps = (bytes * 8) / (seconds * 1000000); // Convert to Mbps
        return mbps;
      }
    } catch (e) {
      print('Upload test error: $e');
    }
    return 0.0;
  }

  // Ping test
  static Future<int> testPing() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.head(Uri.parse('https://google.com'));
      stopwatch.stop();

      if (response.statusCode == 200 || response.statusCode == 301) {
        return stopwatch.elapsedMilliseconds;
      }
    } catch (e) {
      print('Ping test error: $e');
    }
    return -1;
  }

  // Get server location (mock implementation)
  static Future<String> getServerLocation() async {
    try {
      final response = await http.get(Uri.parse('https://httpbin.org/ip'));
      if (response.statusCode == 200) {
        return 'Global Server'; // Mock location
      }
    } catch (e) {
      print('Server location error: $e');
    }
    return 'Unknown';
  }
}

class SpeedTestResult {
  final double downloadSpeed;
  final double uploadSpeed;
  final int ping;
  final String serverLocation;
  final DateTime timestamp;

  SpeedTestResult({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
    required this.serverLocation,
    required this.timestamp,
  });

  String get downloadSpeedFormatted =>
      '${downloadSpeed.toStringAsFixed(2)} Mbps';
  String get uploadSpeedFormatted => '${uploadSpeed.toStringAsFixed(2)} Mbps';
  String get pingFormatted => ping > 0 ? '${ping}ms' : 'N/A';
}
