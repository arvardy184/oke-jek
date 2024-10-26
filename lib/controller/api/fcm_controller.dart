import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/pages/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMController extends GetxController {
  Dio dio = Dio();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Rx<String> _latestMessage = 'Welcome To Okejek'.obs;
  String get latestMessage => _latestMessage.value;

  final Rx<bool> _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
    _initNotification();
  }

  Future<void> _initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _initializeFCM() async {
    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission();
      await _setupFirebaseMessaging();
      await Future.delayed(Duration(seconds: 5));
      await refreshAndRegisterToken();
      await _createNotificationChannel();
      _isInitialized.value = true;
    } catch (e) {
      print('Error initializing FCM: $e');
      _isInitialized.value = false;
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened by clicking on notification: ${message.messageId}");
      _handleMessage(message);
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state by notification: ${initialMessage.messageId}");
      _handleMessage(initialMessage);
    }
  }


  Future<void> _createNotificationChannel() async {
    if (GetPlatform.isAndroid) {
      try {
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin == null) {
          print("Failed to get Android-specific notification plugin");
          return;
        }

        AndroidNotificationChannelGroup channelGroup = const AndroidNotificationChannelGroup(
          'high_importance_channel_group',
          'High Importance Notifications',
          description: 'This channel group is used for important notifications.',
          
        ); 
        await androidPlugin.createNotificationChannelGroup(channelGroup);

        const List<AndroidNotificationChannel> channels = [
          AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.max,
          ),
          AndroidNotificationChannel(
            'medium_importance_channel',
            'Medium Importance Notifications',
            description: 'This channel is used for medium priority notifications.',
            importance: Importance.defaultImportance,
          ),
          AndroidNotificationChannel(
            'low_importance_channel',
            'Low Importance Notifications',
            description: 'This channel is used for low priority notifications.',
            importance: Importance.low,
          ),
        ];

        for (final channel in channels) {
          await androidPlugin.createNotificationChannel(channel);
          print("Created notification channel: ${channel.id}");
        }

        print("All notification channels created successfully");
      } catch (e) {
        print("Error creating notification channels: $e");
      }
    } else {
      print("Notification channels are only applicable for Android devices");
    }
  }

  Future<void> _showNotification(RemoteNotification notification, AndroidNotification? android) async {
    String channelId = 'medium_importance_channel'; // Default channel

    // Determine the appropriate channel based on the notification content or type
    if (notification.title?.toLowerCase().contains('urgent') == true) {
      channelId = 'high_importance_channel';
    } else if (notification.title?.toLowerCase().contains('info') == true) {
      channelId = 'low_importance_channel';
    }

    print("Showing notification on channel: $channelId");

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').capitalize!,
          channelDescription: 'This channel is used for notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
    );
  }
  Future<void> _showDataNotification(Map<String, dynamic> data) async {
    String title = data['msg_title'] ?? 'New Message';
    String body = data['msg_body'] ?? 'You have a new message';

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );

    print("Showing data notification: Title - $title, Body - $body");
  }

  void _handleMessage(RemoteMessage message) {
    print("Handling message: ${message.messageId}");
    print("Message data: ${message.data}");
    print("Message notification: ${message.notification?.toMap()}");

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _showNotification(notification, android);
    } else if (message.data.isNotEmpty) {
      // Handle data message
      _showDataNotification(message.data);
    } else if (message.notification != null) {
      _showNotification(message.notification!, message.notification?.android);
    } else if (message.data['type'] == 'order_update') {
      print("Received order update notification");
      // _handleOrderUpdate(message.data);
    } else {
      print("Received empty message");
    }

    _latestMessage.value = "${message.data['msg_title'] ?? 'No Title'} : ${message.data['msg_body'] ?? 'No Body'}";
    print("Latest message: ${_latestMessage.value}");
  }

  Future<void> refreshAndRegisterToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("token $token");
      if (token != null) {
        print('FCM Token: $token');
        await _registerTokenWithAPI(token);
      } else {
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print("New FCM Token: $newToken");
          _registerTokenWithAPI(newToken);
        });
      }
    } catch (e) {
      print('Error refreshing or registering FCM token: $e');
    }
  }

  Future<void> _registerTokenWithAPI(String token) async {
    String url = OkejekBaseURL.apiUrl('fcm/register');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    print("session $session");
    if(session == null) {
      Get.off(() => LandingPage(), transition: Transition.fade);
    }
    
    try {
      var queryParams = {'api_token': session, 'token': token};
      var response = await dio.post(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );
      print("url $url");
      var responseBody = response.data;
      print("response body $responseBody");

      if (responseBody['success']) {
        print('Register FCM Token successful!');
        print('FCM Token: ${responseBody['data']}');
      } else {
        print('Failed to register FCM Token. Status code: ${response.statusCode} Message: ${responseBody['message']}');
      }
    } catch (e) {
      print('Error registering FCM token with API: $e');
    }
  }
}
