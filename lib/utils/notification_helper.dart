import 'package:flutter/foundation.dart';
import 'logger.dart';
import 'platform_imports.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _initialized = true;
      Logger.infoGlobal('NotificationHelper', 'Notification helper initialized');
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to initialize notifications: $e');
    }
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    Logger.infoGlobal('NotificationHelper', 'Notification tapped: ${response.payload}');
    // Handle notification tap
  }
  
  static Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.requestNotificationsPermission() ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }
      return true;
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to request notification permissions: $e');
      return false;
    }
  }
  
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'vpn_channel',
        'VPN Notifications',
        'Notifications for VPN status and alerts',
      );
      
      final details = NotificationDetails(
        android: androidDetails,
      );
      
      await _notifications.show(id, title, body, details);
      Logger.infoGlobal('NotificationHelper', 'Notification shown: $title');
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to show notification: $e');
    }
  }
  
  static Future<void> showKillSwitchNotification(bool enabled) async {
    await showNotification(
      id: 1001,
      title: 'Kill Switch ${enabled ? 'Enabled' : 'Disabled'}',
      body: enabled 
          ? 'Internet access blocked when VPN disconnects'
          : 'Internet access allowed when VPN disconnects',
      payload: 'kill_switch_$enabled',
    );
  }
  
  static Future<void> showVpnStatusNotification({
    required String status,
    String? serverName,
  }) async {
    await showNotification(
      id: 1002,
      title: 'VPN $status',
      body: serverName != null ? 'Connected to $serverName' : 'VPN status changed',
      payload: 'vpn_status_$status',
    );
  }
  
  static Future<void> showSecurityAlert(String message) async {
    await showNotification(
      id: 1003,
      title: 'Security Alert',
      body: message,
      payload: 'security_alert',
      priority: NotificationPriority.high,
    );
  }
  
  static Future<void> cancelNotification(int id) async {
    try {
      // Windows stub doesn't support individual cancellation, cancel all instead
      await _notifications.cancelAll();
      Logger.infoGlobal('NotificationHelper', 'All notifications cancelled (Windows limitation)');
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to cancel notifications: $e');
    }
  }
  
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      Logger.infoGlobal('NotificationHelper', 'All notifications cancelled');
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to cancel all notifications: $e');
    }
  }
  
  static Future<List<dynamic>> getPendingNotifications() async {
    try {
      // Windows stub doesn't support pending notification requests
      Logger.infoGlobal('NotificationHelper', 'Pending notifications not supported on Windows');
      return [];
    } catch (e) {
      Logger.errorGlobal('NotificationHelper', 'Failed to get pending notifications: $e');
      return [];
    }
  }
}

enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}