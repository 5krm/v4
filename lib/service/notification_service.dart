import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_imports.dart';

// Temporary compatibility classes for awesome_notifications
class ReceivedAction {
  final ActionType actionType;
  final Map<String, String?>? payload;

  ReceivedAction({required this.actionType, this.payload});
}

enum ActionType { Default }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static NotificationService get instance => _instance;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool isCallingScreenOpen = false;

  void setCallingScreenStatus(bool status) {
    isCallingScreenOpen = status;
  }

  static Future<void> startListeningNotificationEvents() async {
    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        final receivedAction = ReceivedAction(
          actionType: ActionType.Default,
          payload: response.payload != null
              ? {'ad_id': response.payload}
              : null,
        );
        await onActionReceivedMethod(receivedAction);
      },
    );
  }

  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.actionType == ActionType.Default) {
      return instance.onActionReceivedImplementationMethod(receivedAction);
    }
  }

  Future<void> onActionReceivedImplementationMethod(
    ReceivedAction receivedAction,
  ) async {
    String? adId = receivedAction.payload?['ad_id'];
    if (adId != null) {
      // FadeScreenTransition(
      //   routeName: Routes.postDetailsRoute,
      //   params: {"adsId": adId},
      // ).navigate();
    }
  }

  Future<void> ensureNotificationPermission({
    bool isForcePermission = false,
  }) async {
    var status = await Permission.notification.status;

    if (status.isDenied || status.isRestricted && isForcePermission) {
      var requestResult = await Permission.notification.request();
      if (requestResult.isPermanentlyDenied) {
        openAppSettings();
      } else {
        ensureNotificationPermission();
      }
    }
  }
}
