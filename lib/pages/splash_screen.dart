import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/initial_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/pages/landing_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final InitController initController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initController = Get.put(InitController());
    
    // // Inisialisasi animasi
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Memulai animasi
    _animationController.forward();
  }

  @override
  void dispose() {
     _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _buildSplashLogo() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: Get.height * 0.5,
          width: Get.width * 0.5,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ic_launcher.png'),
            ),
          ),
        ),
      ),
    );
  }
}
