import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  final String _tag;
  static bool _isEnabled = kDebugMode;
  static LogLevel _minLevel = LogLevel.debug;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  
  Logger(this._tag);
  
  // Configuration methods
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }
  
  static bool get isEnabled => _isEnabled;
  
  // Logging methods
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }
  
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }
  
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }
  
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }
  
  // Alias methods for compatibility
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    debug(message, error, stackTrace);
  }
  
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    info(message, error, stackTrace);
  }
  
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    warning(message, error, stackTrace);
  }
  
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    error(message, error, stackTrace);
  }
  
  // Core logging method
  void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled || level.index < _minLevel.index) {
      return;
    }
    
    final timestamp = _dateFormat.format(DateTime.now());
    final levelStr = _getLevelString(level);
    final logMessage = '[$timestamp] [$levelStr] [$_tag] $message';
    
    // Print to console based on level
    switch (level) {
      case LogLevel.debug:
        debugPrint(logMessage);
        break;
      case LogLevel.info:
        debugPrint(logMessage);
        break;
      case LogLevel.warning:
        debugPrint('⚠️ $logMessage');
        break;
      case LogLevel.error:
        debugPrint('❌ $logMessage');
        break;
    }
    
    // Print error details if provided
    if (error != null) {
      debugPrint('Error details: $error');
    }
    
    // Print stack trace if provided
    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }
  
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR';
    }
  }
  
  // Utility methods
  void logMethodEntry(String methodName, [Map<String, dynamic>? params]) {
    if (params != null && params.isNotEmpty) {
      debug('→ $methodName($params)');
    } else {
      debug('→ $methodName()');
    }
  }
  
  void logMethodExit(String methodName, [dynamic result]) {
    if (result != null) {
      debug('← $methodName() = $result');
    } else {
      debug('← $methodName()');
    }
  }
  
  void logApiCall(String method, String url, [Map<String, dynamic>? data]) {
    info('API $method $url${data != null ? ' with data: $data' : ''}');
  }
  
  void logApiResponse(String method, String url, int statusCode, [dynamic response]) {
    info('API $method $url responded with $statusCode${response != null ? ': $response' : ''}');
  }
  
  void logException(String context, dynamic exception, [StackTrace? stackTrace]) {
    error('Exception in $context', exception, stackTrace);
  }
  
  void logPerformance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }
  
  // Static convenience methods
  static void logGlobal(LogLevel level, String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    final logger = Logger(tag);
    logger._log(level, message, error, stackTrace);
  }
  
  static void debugGlobal(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    logGlobal(LogLevel.debug, tag, message, error, stackTrace);
  }
  
  static void infoGlobal(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    logGlobal(LogLevel.info, tag, message, error, stackTrace);
  }
  
  static void warningGlobal(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    logGlobal(LogLevel.warning, tag, message, error, stackTrace);
  }
  
  static void errorGlobal(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    logGlobal(LogLevel.error, tag, message, error, stackTrace);
  }
}