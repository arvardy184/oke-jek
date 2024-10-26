import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/fcm_controller.dart';
import 'package:okejek_flutter/defaults/messages.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/deeplink_page.dart';
import 'package:okejek_flutter/pages/splash_screen.dart';
import 'package:okejek_flutter/pages/status/payment_success_page.dart';



void main() async {
  await _initializeApp();
  
  runApp(OkejekApp());
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    
   );
  await _configureSystemUI();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Inisialisasi FCMController
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(FCMController());
}

Future<void> _configureSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification di main: ${message.notification?.toMap()}');
}

class OkejekApp extends StatelessWidget {
  OkejekApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GetMaterialApp(
      getPages: _routes,
      debugShowCheckedModeBanner: false,
      translations: Messages(),
      // themeMode: ThemeMode.dark,
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'US'),
      theme: _setupTheme(),
      home: SplashPage(),
    );
  }

  List<GetPage> get _routes =>  [
    GetPage(name: '/deeplink-page', page: () => DeeplinkPage()),
    GetPage(name: '/payment-success', page: () => PaymentSuccessPage()),
    GetPage(name: '/payment-failed', page: () => PaymentFailedPage()),
    GetPage(name: '/payment-canceled', page: () => PaymentCanceledPage()),
    GetPage(name: '/payment-unknown', page: () => PaymentUnknownPage()),
  ];

  ThemeData _setupTheme() {
    return ThemeData(
      useMaterial3: true,
      textTheme: _textTheme,
      snackBarTheme: _snackBarTheme,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange)
          .copyWith(surface: OkejekTheme.bg_color),
    );
  }
  
  TextTheme get _textTheme => TextTheme(
    labelLarge: TextStyle(fontFamily: OkejekTheme.font_family, fontSize: OkejekTheme.font_size),
    displayLarge: TextStyle(fontFamily: OkejekTheme.font_family),
    displaySmall: TextStyle(fontFamily: OkejekTheme.font_family),
    headlineMedium: TextStyle(fontFamily: OkejekTheme.font_family, color: Colors.black),
    bodyLarge: TextStyle(fontFamily: OkejekTheme.font_family),
    bodyMedium: TextStyle(fontFamily: OkejekTheme.font_family, fontSize: OkejekTheme.font_size),
    titleMedium: TextStyle(fontFamily: OkejekTheme.font_family),
    titleSmall: TextStyle(fontFamily: OkejekTheme.font_family),
    bodySmall: TextStyle(fontFamily: OkejekTheme.font_family),
  );

  SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    contentTextStyle: TextStyle(
      fontFamily: OkejekTheme.font_family,
      fontSize: OkejekTheme.font_size
    )
  );
}