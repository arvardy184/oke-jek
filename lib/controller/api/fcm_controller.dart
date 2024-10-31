import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/pages/auth/order/chat_page.dart';
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

  void _navigateToChatPage(String orderId) {
  Get.to(() => ChatPage(orderId: orderId));
}

void _handleChatNotification(Map<String, dynamic> data) async{
  String orderId = data['order_id'] ?? '';
  if(orderId != ''){
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_id', orderId);
    _navigateToChatPage(orderId
    );
    
  }

  print("Handle chat notification: $data");
}


  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");
      _handleMessage(message);
    });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("App opened by clicking on notification: ${message.messageId}");
    if (message.data['__type'] == 'chat') {
      String? orderId = message.data['order_id'];
      if (orderId != null) {
        _navigateToChatPage(orderId);
      }
    }
  });

   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App opened from terminated state by notification: ${initialMessage.messageId}");
    if (initialMessage.data['__type'] == 'chat') {
      String? orderId = initialMessage.data['order_id'];
      if (orderId != null) {
        _navigateToChatPage(orderId);
      }
    }
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

        // Create Channel Groups
        final List<AndroidNotificationChannelGroup> channelGroups = [
          const AndroidNotificationChannelGroup(
            'group_order',
            'Order Notifications',
            description: 'Notifications related to orders and deliveries',
          ),
          const AndroidNotificationChannelGroup(
            'group_news',
            'News Notifications',
            description: 'Notifications about news and updates',
          ),
        ];

        for (final group in channelGroups) {
          await androidPlugin.createNotificationChannelGroup(group);
          print("NOTIFICATION: Create android notification channel group: ${group.id}");
        }

        // Create Notification Channels
        const List<AndroidNotificationChannel> channels = [
          AndroidNotificationChannel(
            'order',
            'Order Updates',
            description: 'Notifications about your orders and deliveries',
            importance: Importance.high,
            groupId: 'group_order',
          ),
          AndroidNotificationChannel(
            'chat',
            'Chat Messages',
            description: 'Messages from drivers and customer service',
            importance: Importance.high,
            groupId: 'group_order',
          ),
          AndroidNotificationChannel(
            'news',
            'News Updates',
            description: 'Latest news and promotions',
            importance: Importance.defaultImportance,
            groupId: 'group_news',
          ),
          AndroidNotificationChannel(
            'etc',
            'Other Notifications',
            description: 'Other general notifications',
            importance: Importance.low,
          ),
        ];

        for (final channel in channels) {
          await androidPlugin.createNotificationChannel(channel);
          print("NOTIFICATION: Create android notification channel: ${channel.id}");
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
    // Determine appropriate channel based on notification type
    String channelId = 'etc'; // Default channel

    // Logic to determine channel based on notification content or type
    if (notification.title?.toLowerCase().contains('order') == true || 
        notification.body?.toLowerCase().contains('order') == true) {
      channelId = 'order';
    } else if (notification.title?.toLowerCase().contains('chat') == true || 
               notification.body?.toLowerCase().contains('chat') == true) {
      channelId = 'chat';
    } else if (notification.title?.toLowerCase().contains('news') == true || 
               notification.body?.toLowerCase().contains('news') == true) {
      channelId = 'news';
    }

    print("Showing notification on channel: $channelId");

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.capitalize!,
          channelDescription: 'This channel is used for notifications.',
          importance: channelId == 'order' || channelId == 'chat' 
              ? Importance.high 
              : Importance.defaultImportance,
          priority: channelId == 'order' || channelId == 'chat'
              ? Priority.high
              : Priority.defaultPriority,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> _showDataNotification(Map<String, dynamic> data) async {
    String title = data['msg_title'] ?? 'New Message';
    String body = data['msg_body'] ?? 'You have a new message';
    String type = data['__type'] ?? 'etc';

    // Determine channel based on notification type
    String channelId = 'etc';
    if (type == 'order_update') {
      channelId = 'order';
    } else if (type == 'chat') {
      channelId = 'chat';
    } else if (type == 'news') {
      channelId = 'news';
    }

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.capitalize!,
          channelDescription: 'This channel is used for notifications.',
          importance: channelId == 'order' || channelId == 'chat' 
              ? Importance.high 
              : Importance.defaultImportance,
          priority: channelId == 'order' || channelId == 'chat'
              ? Priority.high
              : Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );

    print("Showing data notification: Title - $title, Body - $body, Channel - $channelId");
  }

 void _handleMessage(RemoteMessage message) {
  print("Handling message: ${message.messageId}");
  print("Message data: ${message.data}");
  print("Message data type ${message.data['type']}");
  print("Message data --type ${message.data['__type']}");
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
  } else if (message.data['__type'] == 'order_update') {
    print("Received order update notification");
    // _handleOrderUpdate(message.data);
  } else {
    print("Received empty message");
  }

//  if (message.data['__type'] == 'chat') {
//     print("Received chat message notification");
//     _handleChatNotification(message.data);
//   }
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
