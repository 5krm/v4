import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/my_helper.dart';

/// Service to manage API connection and automatic fallback/recovery
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  Timer? _recoveryTimer;
  bool _isInitialized = false;
  
  /// Initialize the connection manager
  void initialize() {
    if (_isInitialized) return;
    
    _isInitialized = true;
    _startRecoveryTimer();
    
    if (kDebugMode) {
      debugPrint('ConnectionManager initialized');
    }
  }
  
  /// Start periodic check to recover to primary URL
  void _startRecoveryTimer() {
    _recoveryTimer?.cancel();
    
    // Check every 5 minutes if we can switch back to primary
    _recoveryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (MyHelper.isUsingFallback) {
        await MyHelper.resetToPrimaryIfAvailable();
      }
    });
  }
  
  /// Force check connection and switch if needed
  Future<bool> checkAndSwitchIfNeeded() async {
    return await MyHelper.switchToFallbackIfNeeded();
  }
  
  /// Get current connection status
  ConnectionStatus getConnectionStatus() {
    return ConnectionStatus(
      isUsingFallback: MyHelper.isUsingFallback,
      currentUrl: MyHelper.baseUrl,
    );
  }
  
  /// Manually force switch to fallback
  void forceUseFallback() {
    MyHelper.forceUseFallback();
  }
  
  /// Manually force switch to primary
  void forceUsePrimary() {
    MyHelper.forceUsePrimary();
  }
  
  /// Dispose resources
  void dispose() {
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _isInitialized = false;
  }
}

/// Connection status information
class ConnectionStatus {
  final bool isUsingFallback;
  final String currentUrl;
  
  ConnectionStatus({
    required this.isUsingFallback,
    required this.currentUrl,
  });
  
  @override
  String toString() {
    return 'ConnectionStatus(isUsingFallback: $isUsingFallback, currentUrl: $currentUrl)';
  }
}