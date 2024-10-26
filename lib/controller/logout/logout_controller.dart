import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:okejek_flutter/pages/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutController extends GetxController {
  void logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print("Error signing out from google sign in $e");
    }

    // GoogleSignIn().signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_data');
    await prefs.remove('user_session');

    Get.offAll(() => LandingPage());
  }
}
