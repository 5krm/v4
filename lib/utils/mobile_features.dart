// import 'package:flutter/foundation.dart';
// import 'package:get_storage/get_storage.dart';
// import '../utils/my_helper.dart';
// import 'platform_imports.dart';

// const firebaseOptionsAndroid = FirebaseOptions(
//   apiKey: 'AIzaSyBERuGBROMGgb87cXibocTGI8OPLjTiBTo',
//   appId: '1:787804813632:android:2be09fb7add5544a89e2a5',
//   messagingSenderId: '787804813632',
//   projectId: 'dbug-codecanyon',
// );

// const firebaseOptionsIOS = FirebaseOptions(
//   apiKey: 'AIzaSyB7FjoE4NU667n7VCyvW_QsezaH46MvGoA',
//   appId: '1:787804813632:ios:20cc5b303617dae789e2a5',
//   messagingSenderId: '787804813632',
//   projectId: 'dbug-codecanyon',
// );

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (message.data?.isNotEmpty == true) {}
// }

// int generateNotificationId() {
//   return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
// }

// void _showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   final Map<String, dynamic> data = message.data ?? {};

//   final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'default_channel',
//     'Push Notifications',
//     'Notify updated news and information',
//     importance: Importance.defaultImportance,
//     priority: Priority.defaultPriority,
//     showWhen: false,
//   );

//   final platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await flutterLocalNotificationsPlugin.show(
//     generateNotificationId(),
//     message.notification?.title ?? 'New Notification',
//     message.notification?.body ??
//         'You have a new message from ${MyHelper.appname}.',
//     platformChannelSpecifics,
//     payload: data['ad_id']?.toString(),
//   );
// }

// Future<void> importMobileFeatures() async {

//   GetStorage storage = GetStorage();

//   try {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       await Firebase.initializeApp(options: firebaseOptionsAndroid);
//     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//       await Firebase.initializeApp(options: firebaseOptionsIOS);
//     } else {
//       await Firebase.initializeApp();
//     }

//     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
//     // Initialize Firebase Messaging
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//       if (message != null) {}
//     });
    
//     final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (storage.read(MyHelper.notification) ?? true) {
//         _showNotification(message, flutterLocalNotificationsPlugin);
//       }
//     });
    
//     // Initialize mobile ads
//     MobileAds.instance.initialize();
//     await UnityAds.init(
//       gameId: storage.read(MyHelper.unityAdsAppId) ?? '',
//       onComplete: () {},
//       onFailed: (error, message) {},
//     );
//     FacebookAudienceNetwork.init(iOSAdvertiserTrackingEnabled: true);
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error initializing mobile features: $e');
//     }
//   }
// }