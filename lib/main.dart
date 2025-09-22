import 'dart:io';
import 'package:dbug_vpn/view/screens/new_splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'ads/ads_callback.dart';
import 'controller/auth_controller.dart';
import 'controller/home_controller.dart';
import 'controller/pref.dart';
import 'data/api/api_client.dart';
import 'service/notification_service.dart';
import 'utils/my_color.dart';
import 'utils/my_helper.dart';
import 'view/screens/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data.isNotEmpty) {}
}

NotificationService notificationService = NotificationService();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  GetStorage storage = GetStorage();

  // Initialize notifications
  notificationService.ensureNotificationPermission();
  await NotificationService.startListeningNotificationEvents();

  const firebaseOptionsAndroid = FirebaseOptions(
    apiKey: 'AIzaSyDnwCCnjp5JYZnfYagLC2_oBwOTaB2ujZA',
    appId: '1:571191391011:android:917714ceca636f4224d296',
    messagingSenderId: '571191391011',
    projectId: 'dbug-codecanyon',
  );

  const firebaseOptionsIOS = FirebaseOptions(
    apiKey: 'AIzaSyDnwCCnjp5JYZnfYagLC2_oBwOTaB2ujZA',
    appId: '1:571191391011:android:917714ceca636f4224d296',
    messagingSenderId: '571191391011',
    projectId: 'eclipsecrm-264ca',
  );

  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(options: firebaseOptionsAndroid);
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(options: firebaseOptionsIOS);
    } else {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {}
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (storage.read(MyHelper.notification) ?? true) {
      _showNotification(message);
    }
  });

  MobileAds.instance.initialize();
  await UnityAds.init(
    gameId: storage.read(MyHelper.unityAdsAppId) ?? '',
    onComplete: () {},
    onFailed: (error, message) {},
  );
  FacebookAudienceNetwork.init(iOSAdvertiserTrackingEnabled: true);
  await Pref.initializeHive();

  ApiClient myApiClient =
      ApiClient(appBaseUrl: MyHelper.baseUrl, sharedPreferences: storage);

  Get.lazyPut<AdsCallBack>(() => AdsCallBack(), fenix: true);
  Get.lazyPut<HomeController>(() => HomeController(apiClient: myApiClient),
      fenix: true);
  Get.lazyPut<AuthController>(() => AuthController(apiClient: myApiClient),
      fenix: true);

  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

int generateNotificationId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
}

void _showNotification(RemoteMessage message) async {
  final Map<String, dynamic> data = message.data;

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel',
    'Push Notifications',
    channelDescription: 'Notify updated news and information',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    generateNotificationId(),
    message.notification?.title ?? 'New Notification',
    message.notification?.body ??
        'You have a new message from ${MyHelper.appname}.',
    platformChannelSpecifics,
    payload: data['ad_id']?.toString(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: MyColor.bg),
      home: const NewSplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Builder(
            builder: (context) {
              return child!;
            },
          ),
        );
      },
    );
  }
}
