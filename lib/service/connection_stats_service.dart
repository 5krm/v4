// ignore_for_file: unused_field, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:get_storage/get_storage.dart';

class ConnectionStatsService {
  static final GetStorage _storage = GetStorage();
  static Timer? _statsTimer;

  // Storage keys
  static const String _totalDataUsedKey = 'total_data_used';
  static const String _sessionDataUsedKey = 'session_data_used';
  static const String _connectionTimeKey = 'connection_time';
  static const String _totalConnectionTimeKey = 'total_connection_time';
  static const String _connectionCountKey = 'connection_count';
  static const String _lastResetDateKey = 'last_reset_date';

  // Connection stats
  static DateTime? _connectionStartTime;
  static double _sessionUpload = 0.0;
  static double _sessionDownload = 0.0;
  static StreamController<ConnectionStats> _statsController =
      StreamController.broadcast();

  static Stream<ConnectionStats> get statsStream => _statsController.stream;

  static void startSession() {
    _connectionStartTime = DateTime.now();
    _sessionUpload = 0.0;
    _sessionDownload = 0.0;

    // Increment connection count
    final currentCount = _storage.read(_connectionCountKey) ?? 0;
    _storage.write(_connectionCountKey, currentCount + 1);

    // Start periodic updates
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStats();
    });
  }

  static void endSession() {
    if (_connectionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_connectionStartTime!);
      final totalTime = getTotalConnectionTime() + sessionDuration.inSeconds;
      _storage.write(_totalConnectionTimeKey, totalTime);

      _connectionStartTime = null;
    }

    _statsTimer?.cancel();
    _statsTimer = null;
  }

  static void addDataUsage(double uploadBytes, double downloadBytes) {
    _sessionUpload += uploadBytes;
    _sessionDownload += downloadBytes;

    // Update total data usage
    final currentTotal = getTotalDataUsage();
    _storage.write(
        _totalDataUsedKey, currentTotal + uploadBytes + downloadBytes);
  }

  static void _updateStats() {
    if (!_statsController.isClosed) {
      _statsController.add(getCurrentStats());
    }
  }

  static ConnectionStats getCurrentStats() {
    final sessionDuration = _connectionStartTime != null
        ? DateTime.now().difference(_connectionStartTime!)
        : Duration.zero;

    return ConnectionStats(
      sessionUpload: _sessionUpload,
      sessionDownload: _sessionDownload,
      sessionDuration: sessionDuration,
      totalDataUsage: getTotalDataUsage(),
      totalConnectionTime: getTotalConnectionTime() + sessionDuration.inSeconds,
      connectionCount: getConnectionCount(),
      isConnected: _connectionStartTime != null,
    );
  }

  static double getTotalDataUsage() {
    return (_storage.read(_totalDataUsedKey) ?? 0.0).toDouble();
  }

  static int getTotalConnectionTime() {
    return _storage.read(_totalConnectionTimeKey) ?? 0;
  }

  static int getConnectionCount() {
    return _storage.read(_connectionCountKey) ?? 0;
  }

  static void resetStats() {
    _storage.remove(_totalDataUsedKey);
    _storage.remove(_totalConnectionTimeKey);
    _storage.remove(_connectionCountKey);
    _storage.write(_lastResetDateKey, DateTime.now().toIso8601String());

    _sessionUpload = 0.0;
    _sessionDownload = 0.0;
  }

  static DateTime? getLastResetDate() {
    final dateString = _storage.read(_lastResetDateKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  static void dispose() {
    _statsTimer?.cancel();
    _statsController.close();
    _statsController = StreamController.broadcast();
  }
}

class ConnectionStats {
  final double sessionUpload;
  final double sessionDownload;
  final Duration sessionDuration;
  final double totalDataUsage;
  final int totalConnectionTime;
  final int connectionCount;
  final bool isConnected;

  ConnectionStats({
    required this.sessionUpload,
    required this.sessionDownload,
    required this.sessionDuration,
    required this.totalDataUsage,
    required this.totalConnectionTime,
    required this.connectionCount,
    required this.isConnected,
  });

  double get sessionTotalData => sessionUpload + sessionDownload;

  String get sessionUploadFormatted => _formatBytes(sessionUpload);
  String get sessionDownloadFormatted => _formatBytes(sessionDownload);
  String get sessionTotalFormatted => _formatBytes(sessionTotalData);
  String get totalDataFormatted => _formatBytes(totalDataUsage);

  String get sessionDurationFormatted => _formatDuration(sessionDuration);
  String get totalConnectionTimeFormatted =>
      _formatDuration(Duration(seconds: totalConnectionTime));

  static String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
