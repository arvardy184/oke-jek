import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/initial_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/pages/landing_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InitController initController = Get.put(InitController());
    print(Get.height * 0.5);
    print(Get.width * 0.5);
    return Scaffold(
      backgroundColor: OkejekTheme.primary_color,
      body: FutureBuilder(
        future: initController.getInitRequest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSplashLogo();
          } else if (snapshot.hasError) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Get.off(() => LandingPage());
            });
            return _buildSplashLogo();
          } else {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              initController.isLogin();
            });
            return _buildSplashLogo();
          }

        },
      ),
    );
  }
}

Widget _buildSplashLogo() {
  return Center(
    child: Container(
      height: Get.height * 0.5,
      width: Get.width * 0.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ic_launcher.png'),
        ),
      ),
    ),
  );
}
