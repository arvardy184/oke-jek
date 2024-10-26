import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/deeplink_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/controller/login/login_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/login/login_page.dart';
import 'package:okejek_flutter/pages/register_page.dart';

class LandingPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final LandingController landingController = Get.put(LandingController());
  final DeeplinkController deeplinkController = Get.put(DeeplinkController());

  @override
  Widget build(BuildContext context) {
    if (landingController.isOutdated.value) showAlertUpdate();

    return Scaffold(
       backgroundColor: OkejekTheme.primary_color,
      
      body: DoubleBack(
        message: "Tap lagi untuk keluar",
        textStyle: TextStyle(fontSize: 12, color: Colors.white),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(
                height: Get.height * 0.1,
              ),
              Center(
                child: Container(
                  height: Get.height /7,
                  child: Image.asset(
                    'assets/images/ic_launcher.png',
                    // width: Get.height /4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.1,
              ),
              Text(
                'Selamat Datang'.tr,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockHorizontal * 6.5,
                    ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Selamat datang di Okejek App'.tr,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockHorizontal * 4,
                    ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 3,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OkejekTheme.button_rounded_corner),
                    ),
                  ),
                  // onPressed: () async {
                  //   // final authService = AuthService();
                  //   final user = await authService.signInWithGoogle();
                  //   if (user != null) {
                  //     print('Signed in: ${user.displayName}');
                  //     // Navigate to home screen or do something else
                  //   } else {
                  //     print('Sign in failed');
                  //     print('${user}');
                  //   }
                  // },
                  onPressed: () async {
                    try {
                      await loginController.getGoogleAccount();
                      // Jika berhasil login, lakukan navigasi atau tindakan lain
                    } catch (e) {
                      print('Error saat login: $e');
                      // Tampilkan pesan error ke pengguna
                    }
                    // loginController.getGoogleAccount();

                    // GoogleSignIn().signOut();
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          height: SizeConfig.blockSizeHorizontal * 5,
                          width: SizeConfig.blockSizeHorizontal * 5,
                          child: Image.asset('assets/images/google-logo-9808.png'),
                        ),
                        Text(
                          'action_login_with_google'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: OkejekTheme.primary_color, fontSize: SizeConfig.safeBlockHorizontal * 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OkejekTheme.primary_color,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 2),
                    side: BorderSide(width: 1.0, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OkejekTheme.button_rounded_corner),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => RegisterPage(), opaque: true, transition: Transition.fadeIn);
                  },
                  child: Center(
                    child: Text(
                      'Signup'.tr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white, fontSize: SizeConfig.safeBlockHorizontal * 4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2.5,
              ),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Sudah punya akun?'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white, fontSize: SizeConfig.safeBlockHorizontal * 3.5),
                      ),
                      TextSpan(
                        text: ' Sign in',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() => LoginPage(), opaque: true, transition: Transition.fadeIn);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2.5,
              ),
              Center(
                child: Text(
                  'Versi '.tr + '90000 build 7.0.0'.tr,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                      ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  'Ketentuan dan Kebijakan'.tr,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlertUpdate() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        // set up the button
        Widget okButton = TextButton(
          child: Text(
            "Update",
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            landingController.updateVersion();
          },
        );

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text(
            "Update",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Versi terbaru telah tersedia, Silakan update aplikasi Okejek di PlayStore",
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
          ),
          actions: [
            okButton,
          ],
        );

        // show the dialog
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return alert;
          },
        );
      },
    );
  }
}
